defmodule BoomboxExperiments.LogoStreamWebsocket do
  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {Task, :start_link, [fn ->
        overlay =
          Req.get!("https://avatars.githubusercontent.com/u/5748289?v=4").body
          |> Vix.Vips.Image.new_from_buffer()
          |> then(fn {:ok, img} -> img end)
          |> Image.trim!()
          |> Image.thumbnail!(100)

        bg = Image.new!(640, 480, color: :light_gray)
        max_x = Image.width(bg) - Image.width(overlay)
        max_y = Image.height(bg) - Image.height(overlay)

        Stream.iterate({_x = 300, _y = 0, _dx = 1, _dy = 2, _pts = 0}, fn {x, y, dx, dy, pts} ->
          dx = if (x + dx) in 0..max_x, do: dx, else: -dx
          dy = if (y + dy) in 0..max_y, do: dy, else: -dy
          pts = pts + div(Membrane.Time.seconds(1), _fps = 60)
          {x + dx, y + dy, dx, dy, pts}
        end)
        |> Stream.map(fn {x, y, _dx, _dy, pts} ->
          img = Image.compose!(bg, overlay, x: x, y: y)
          %Boombox.Packet{kind: :video, payload: img, pts: pts}
        end)
        |> Boombox.run(
          input: {:stream, video: :image, audio: false},
          output: {:webrtc, "ws://localhost:8830"}
        )
      end]},
      restart: :permanent
    }
  end
end
