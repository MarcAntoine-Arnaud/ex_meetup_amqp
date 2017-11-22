defmodule ExMeetupAmqpWeb.StatusView do
  use ExMeetupAmqpWeb, :view
  alias ExMeetupAmqpWeb.StatusView

  def render("index.json", %{status: status}) do
    %{data: render_many(status, StatusView, "state.json")}
  end

  def render("show.json", %{status: status}) do
    %{data: render_one(status, StatusView, "state.json")}
  end

  def render("state.json", %{status: status}) do
    %{
      id: status.id,
      state: status.state,
      inserted_at: status.inserted_at,
    }
  end
end
