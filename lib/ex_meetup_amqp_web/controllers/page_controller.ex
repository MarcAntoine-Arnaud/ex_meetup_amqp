defmodule ExMeetupAmqpWeb.PageController do
  use ExMeetupAmqpWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
