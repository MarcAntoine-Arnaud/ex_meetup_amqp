defmodule ExMeetupAmqp.Status do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExMeetupAmqp.Status


  schema "status" do
    field :state, :string
    field :job_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Status{} = status, attrs) do
    status
    |> cast(attrs, [:state])
    |> validate_required([:state])
  end
end
