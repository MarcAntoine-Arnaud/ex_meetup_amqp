defmodule ExMeetupAmqpWeb.JobView do
  use ExMeetupAmqpWeb, :view
  alias ExMeetupAmqpWeb.JobView

  def render("index.json", %{jobs: jobs}) do
    %{data: render_many(jobs, JobView, "job.json")}
  end

  def render("show.json", %{job: job}) do
    %{data: render_one(job, JobView, "job.json")}
  end

  def render("job.json", %{job: job}) do
    %{id: job.id,
      name: job.name,
      params: job.params}
  end
end
