defmodule ExMeetupAmqp.JobConsumer do
  require Logger
  use AMQP

  use ExMeetupAmqp.CommonConsumer, %{
    queue: "job_result",
    exchange: "/",
    consumer: &ExMeetupAmqp.JobConsumer.consume/4,
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id} = payload) do
    job_id = Map.get(payload, "job_id")
    status = Map.get(payload, "status")

    ExMeetupAmqp.Jobs.Status.set_job_status(job_id, status)

    Basic.ack channel, tag
  end
end