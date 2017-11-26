defmodule ExMeetupAmqp.Jobs.Status do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExMeetupAmqp.Jobs.Status
  alias ExMeetupAmqp.Jobs.Job
  alias ExMeetupAmqp.Repo

  schema "status" do
    field :state, :string
    belongs_to :job, Job, foreign_key: :job_id

    timestamps()
  end

  @doc false
  def changeset(%Status{} = job, attrs) do
    job
    |> cast(attrs, [:state, :job_id])
    |> foreign_key_constraint(:job_id)
    |> validate_required([:state, :job_id])
  end

  def set_job_status(job_id, status) do
    %Status{}
    |> Status.changeset(%{job_id: job_id, state: status})
    |> Repo.insert()
  end
end
