defmodule BoomboxExperimentsWeb.LogoStreamController do
  use BoomboxExperimentsWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
