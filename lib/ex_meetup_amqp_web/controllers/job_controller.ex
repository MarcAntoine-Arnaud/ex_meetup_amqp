defmodule ExMeetupAmqpWeb.JobController do
  use ExMeetupAmqpWeb, :controller

  alias ExMeetupAmqp.Jobs
  alias ExMeetupAmqp.Jobs.Job
  alias ExMeetupAmqp.JobEmitter

  action_fallback ExMeetupAmqpWeb.FallbackController

  def index(conn, _params) do
    jobs = Jobs.list_jobs()
    render(conn, "index.json", jobs: jobs)
  end

  def create(conn, %{"job" => job_params}) do
    iterations =
      job_params
      |> Map.get("params")
      |> Map.get("iterations", 1)

    jobs =
      for _index <- 1..iterations do
        with {:ok, %Job{} = job} <- Jobs.create_job(job_params) do

          params = %{
            job_id: job.id,
            params: job.params
          }
          JobEmitter.publish_json(params)
          job
        end
      end

    conn
    |> put_status(:created)
    |> render("index.json", jobs: jobs)
  end

  def show(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    render(conn, "show.json", job: job)
  end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Jobs.get_job!(id)

    with {:ok, %Job{} = job} <- Jobs.update_job(job, job_params) do
      render(conn, "show.json", job: job)
    end
  end

  def delete(conn, %{"id" => _id}) do
    # job = Jobs.get_job!(id)
    # with {:ok, %Job{}} <- Jobs.delete_job(job) do
    #   send_resp(conn, :no_content, "")
    # end

    for job <- Jobs.list_jobs() do
      Jobs.delete_job(job)
    end
    send_resp(conn, :no_content, "")
  end
end
