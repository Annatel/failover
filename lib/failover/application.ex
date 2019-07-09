defmodule Failover.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Failover.StateRegistry},
      {DynamicSupervisor, name: Failover.StateSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: Failover.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
