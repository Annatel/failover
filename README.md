# Failover

Elixir failover library.  
Support failover through multiple proxy servers.  
Support supervised and not supervised state of redudant servers per client.

## Installation

The package can be installed
by adding `failover` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:failover, git: "git@github.com:annatel/failover.git", tag: "0.2.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/failover](https://hexdocs.pm/failover).

## Example (not supervised state)

```elixir
fun = fn %{upstream: url} ->
  response = do_action(url)

  case response do
    {:ok, response} -> {:ok, response}
    {:error, error} -> {:error, %{:upstream, error}}
  end
end

response =
  Failover.call(%{upstream: ["https://master-url.com/api", "https://slave-url.com/api"]}, fun)

case response do
  {:ok, response, updated_state, _state_error} ->
    IO.inspect(response)

  {:error, :upstream, state, state_error} ->
    IO.inspect("All upstream servers are down")
    IO.inspect("Last error is:")
    error = state_error[:upstream] |> List.first
    IO.inspect(elem(error, 1))
end
```