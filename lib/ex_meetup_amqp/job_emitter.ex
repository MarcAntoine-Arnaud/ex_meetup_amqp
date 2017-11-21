defmodule ExMeetupAmqp.JobEmitter do
  use ExMeetupAmqp.CommonEmitter, %{
    queue: "job"
  }
end
