defmodule ExMeetupAmqp.CommonConsumer do

  @doc false
  defmacro __using__(opts) do
    quote do

      use GenServer
      use AMQP

      def start_link do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
      end

      def init(:ok) do
        hostname = Application.get_env(:amqp, :hostname)
        username = Application.get_env(:amqp, :username)
        password = Application.get_env(:amqp, :password)

        url = "amqp://" <> username <> ":" <> password <> "@" <> hostname
        {:ok, connection} = AMQP.Connection.open(url)
        {:ok, channel} = AMQP.Channel.open(connection)

        queue = unquote(opts).queue
        exchange = unquote(opts).exchange

        AMQP.Queue.declare(channel, queue, durable: false)
        AMQP.Exchange.fanout(channel, exchange, durable: false)
        AMQP.Queue.bind(channel, queue, exchange)

        {:ok, _consumer_tag} = AMQP.Basic.consume(channel, queue)
        {:ok, channel}
      end

      # Confirmation sent by the broker after registering this process as a consumer
      def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, channel) do
        {:noreply, channel}
      end

      # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
      def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, channel) do
        {:stop, :normal, channel}
      end

      # Confirmation sent by the broker to the consumer process after a Basic.cancel
      def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, channel) do
        {:noreply, channel}
      end

      def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, channel) do
        data =
          payload
          |> Poison.Parser.parse!

        %{"job_id" => job_id} = data
        Logger.info "#{__MODULE__}: receive message for job #{job_id}"

        spawn fn -> unquote(opts).consumer.(channel, tag, redelivered, data) end
        {:noreply, channel}
      end

      def terminate(_reason, state) do
        AMQP.Connection.close(state.connection)
      end
    end
  end
end
