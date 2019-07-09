defmodule Failover do
  @moduledoc """
  Documentation for Failover.
  """

  @spec call(map(), fun(), map()) :: {:ok | :error, any(), map(), map()}
  def call(state, fun, state_error \\ %{})
      when is_map(state) and is_function(fun, 1) and is_map(state_error) do
    empty_state = Enum.find(state, &Enum.empty?(elem(&1, 1)))

    if empty_state do
      {:error, elem(empty_state, 0), state, state_error}
    else
      fun_params = Enum.reduce(state, %{}, fn {key, [h | _]}, acc -> Map.put(acc, key, h) end)
      tail_state_by_key = Enum.map(state, fn {key, [_ | t]} -> {key, t} end)

      case fun.(fun_params) do
        {:ok, resp} ->
          {:ok, resp, state, state_error}

        {:error, {key, error}} ->
          state_error = update_state_error(state_error, fun_params, key, error)
          tail_state = Map.put(state, key, tail_state_by_key[key])

          response = call(tail_state, fun, state_error)

          resulted_state = elem(response, 2)

          new_state =
            case elem(response, 0) do
              :ok ->
                Map.put(resulted_state, key, List.insert_at(resulted_state[key], 1, fun_params[key]))

              :error ->
                Map.put(resulted_state, key, List.insert_at(resulted_state[key], 0, fun_params[key]))
            end

          response |> put_elem(2, new_state)
      end
    end
  end

  def statefull_call(base_state \\ %{}, fun, state_error \\ %{}, name, force \\ false)
      when is_atom(name) and is_function(fun, 1) and is_map(state_error) and is_map(base_state) and is_boolean(force) do
    if length(Registry.lookup(Failover.StateRegistry, name)) == 0 do
      create_agent(name, base_state)
    end

    state =
      case force do
        true ->
          base_state

        false ->
          get_state_from_agent(name)
      end

    response = call(state, fun, state_error)

    set_state_to_agent(name, elem(response, 2))

    response
  end

  defp get_state_from_agent(name) when is_atom(name) do
    Agent.get({:via, Registry, {Failover.StateRegistry, name}}, fn state -> state end)
  end

  defp create_agent(name, state) do
    {:ok, _} =
      DynamicSupervisor.start_child(Failover.StateSupervisor, %{
        id: "",
        start: {Agent, :start_link, [fn -> state end, [name: {:via, Registry, {Failover.StateRegistry, name}}]]}
      })
  end

  defp set_state_to_agent(name, state) do
    Agent.update({:via, Registry, {Failover.StateRegistry, name}}, fn _ -> state end)
  end

  defp update_state_error(state_error, fun_params, key, error) do
    {_, state_error} =
      Map.get_and_update(state_error, key, fn current_value ->
        new_value =
          case current_value do
            nil ->
              [{fun_params[key], error}]

            _ ->
              [{fun_params[key], error} | current_value]
          end

        {current_value, new_value}
      end)

    state_error
  end
end
