defmodule EventWorker do
  use Application

  def start(_type, _args) do
    EventWorker.Supervisor.start_link
  end
end
