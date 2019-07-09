defmodule FailoverTest.Helper do
  def tear_down(name) do
    case Registry.lookup(Failover.StateRegistry, name) do
      [{pid, nil}] ->
        DynamicSupervisor.terminate_child(Failover.StateSupervisor, pid)

      [] ->
        :noop
    end

    Registry.unregister(Failover.StateRegistry, name)
  end
end
