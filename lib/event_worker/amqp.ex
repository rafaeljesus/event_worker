defmodule EventWorker.Amqp do
  use GenServer
  use AMQP

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange "event_exchange"
  @queue "event_queue"
  @queue_error "#{@queue}_error"

  def init(_opts) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = Channel.open(conn)

    Basic.qos(chan, prefetch_count: 10)
    Queue.declare(chan, @queue_error, durable: true)
    Queue.declare(chan, @queue, durable: true, arguments: [
      {"x-dead-letter-exchange", :longstr, ""},
      {"x-dead-letter-routing-key", :longstr, @queue_error}
    ])

    Exchange.fanout(chan, @exchange, durable: true)
    Queue.bind(chan, @queue, @exchange)

    {:ok, _consumer_tag} = Basic.consume(chan, @queue)
    {:ok, chan}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, chan), do: {:noreply, chan}
  def handle_info({:basic_cancel, %{consumer_tag: consumer_tag}}, chan), do: {:stop, :normal, chan}
  def handle_info({:basic_cancel_ok, %{consumer_tag: consumer_tag}}, chan), do: {:noreply, chan}

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    spawn fn -> Consumer.consume(chan, tag, redelivered, payload) end
    {:noreply, chan}
  end
end
