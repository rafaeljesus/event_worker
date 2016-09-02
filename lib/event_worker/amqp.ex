defmodule EventWorker.Amqp do
  use GenServer
  use AMQP

  alias EventWorker.ConnManager

  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: opts[:handler])
  end

  def init(opts) do
    queue_error = "#{opts[:queue_name]}.errors"
    queue_name = opts[:queue_name]
    exchange = opts[:exchange]
    routing_key = opts[:routing_key]

    {:ok, chan} = create_conn(virtual_host: opts[:virtual_host])
    {:ok, _consumer_tag} =
      chan
      |> create_queue(queue_error)
      |> create_topic(exchange)
      |> create_queue(queue_name, dead_letter_opts(queue_error))
      |> bind_queue(queue_name, exchange, routing_key: routing_key)
      |> subscribe(queue_name)
    {:ok, [chan, opts]}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}},
                                            [chan, opts] = state) do
    spawn fn ->
      try do
        opts[:handler].handle_message(payload)
        Basic.ack(chan, tag)
      rescue
        _ -> Basic.reject(chan, tag, requeue: not redelivered)
      end
    end
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, _pid, _reason}, [_, opts]) do
    {:ok, chan} = create_conn(opts)
    {:noreply, [chan, opts]}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp create_conn(opts), do: ConnManager.create_conn(opts)

  defp create_queue(chan, queue_name, opts \\ []) do
    options = opts ++ [durable: true]
    Queue.declare(chan, queue_name, options)
    chan
  end

  defp create_topic(chan, exchange, opts \\ []) do
    options = opts ++ [durable: true]
    Exchange.topic(chan, exchange, options)
    chan
  end

  defp bind_queue(chan, queue_name, exchange, opts) do
    Queue.bind(chan, queue_name, exchange, opts)
    chan
  end

  defp subscribe(chan, queue_name), do: Basic.consume(chan, queue_name)

  defp dead_letter_opts(queue_error) do
    [arguments: [
      {"x-dead-letter-exchange", :longstr, ""},
      {"x-dead-letter-routing-key", :longstr, queue_error}]]
  end
end
