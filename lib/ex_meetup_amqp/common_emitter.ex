defmodule ExMeetupAmqp.CommonEmitter do

  @doc false
  defmacro __using__(opts) do
    quote do

      use GenServer

      def start_link do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
      end

      def publish(message) do
        GenServer.cast(__MODULE__, {:publish, message})
      end

      def publish_json(message) do
        message
        |> Poison.encode!
        |> publish
      end

      def init(:ok) do
        hostname = Application.get_env(:amqp, :hostname)
        username = Application.get_env(:amqp, :username)
        password = Application.get_env(:amqp, :password)

        url = "amqp://" <> username <> ":" <> password <> "@" <> hostname
        {:ok, connection} = AMQP.Connection.open(url)
        {:ok, channel} = AMQP.Channel.open(connection)
        AMQP.Queue.declare(channel, unquote(opts).queue)
        {:ok, %{channel: channel, connection: connection} }
      end

      def handle_cast({:publish, message}, state) do
        AMQP.Basic.publish(state.channel, "", unquote(opts).queue, message)
        {:noreply, state}
      end

      def terminate(_reason, state) do
        AMQP.Connection.close(state.connection)
      end
    end
  end
end
