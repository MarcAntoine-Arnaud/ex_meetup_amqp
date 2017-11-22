defmodule ExMeetupAmqp.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExMeetupAmqp.Jobs.Job
  alias ExMeetupAmqp.Jobs.Status


  schema "jobs" do
    field :name, :string
    field :params, :map
    has_many :status, Status, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, [:name, :params])
    |> validate_required([:name, :params])
  end
end
