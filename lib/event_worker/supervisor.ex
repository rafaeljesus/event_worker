defmodule EventWorker.Supervisor do
  use Supervisor

  @name __MODULE__

  def init([]) do
    [
      worker(EventWorker.Repo, []),
      worker(EventWorker.Amqp, [amqp_opts])
    ] |> supervise(strategy: :one_for_one)
  end

  def start_link do
    Supervisor.start_link(@name, [], name: @name)
  end

  defp amqp_opts do
    [virtual_host: System.get_env("MESSAGE_BROKER_VHOST"),
      exchange: "events",
      queue_name: "event.trace",
      routing_key: "event.created",
      handler: EventWorker.Handler]
  end
end

