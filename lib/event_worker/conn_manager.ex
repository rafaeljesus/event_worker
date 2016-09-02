defmodule EventWorker.ConnManager do

  alias AMQP.{Channel, Connection}

  def create_conn(opts) do
    options = conn_opts ++ opts
    {:ok, conn} = Connection.open(options)
    Process.monitor(conn.pid)
    handle_chan(Channel.open(conn), opts)
  end

  defp handle_chan({:ok, chan}, _), do: {:ok, chan}
  defp handle_chan({:error, opts}, opts) do
    :timer.sleep(10000)
    create_conn(opts)
  end

  defp conn_opts do
    [heartbeat: 60,
     connection_timeout: 60000,
     host: System.get_env("MESSAGE_BROKER_HOST")]
  end
end
