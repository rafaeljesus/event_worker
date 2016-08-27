defmodule EventWorker.HandlerTest do
  use ExUnit.Case

  alias EventWorker.Handler

  setup do
    payload = %{name: "event_name", status: "success", payload: %{}}
    {:ok, payload: payload}
  end

  test "handle event message payload", %{payload: payload} do
    {:ok, event} = Handler.handle_message(payload)
    assert nil != event.id
  end
end
