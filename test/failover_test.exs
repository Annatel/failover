defmodule FailoverTest do
  use ExUnit.Case

  import FailoverTest.Helper

  describe "one key list of redundant" do
    test "returns an error when all redudants fail" do
      assert {:error, :upstream, %{upstream: [4]}, %{upstream: [{4, "server down"}]}} =
               Failover.call(%{upstream: [4]}, &one_key_list_fun/1)

      assert {:error, :upstream, %{upstream: [4, 5]}, %{upstream: [{5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{upstream: [4, 5]}, &one_key_list_fun/1)

      assert {:error, :upstream, %{upstream: [4, 5, 6]},
              %{upstream: [{6, "server down"}, {5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{upstream: [4, 5, 6]}, &one_key_list_fun/1)
    end

    test "returns a response when ONE of the redudant success" do
      assert {:ok, 1, %{upstream: [1]}, %{}} = Failover.call(%{upstream: [1]}, &one_key_list_fun/1)

      assert {:ok, 2, %{upstream: [2, 4]}, %{upstream: [{4, "server down"}]}} =
               Failover.call(%{upstream: [4, 2]}, &one_key_list_fun/1)

      assert {:ok, 2, %{upstream: [2, 4, 1]}, %{upstream: [{4, "server down"}]}} =
               Failover.call(%{upstream: [4, 2, 1]}, &one_key_list_fun/1)

      assert {:ok, 1, %{upstream: [1, 4, 5]}, %{upstream: [{5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{upstream: [4, 5, 1]}, &one_key_list_fun/1)
    end
  end

  describe "two key list of redundant" do
    test "returns an error when all redudants fail" do
      assert {:error, :proxy, %{proxy: [4], upstream: [1]}, %{proxy: [{4, "server down"}]}} =
               Failover.call(%{proxy: [4], upstream: [1]}, &two_key_list_fun/1)

      assert {:error, :proxy, %{proxy: [4, 5], upstream: [1]}, %{proxy: [{5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy: [4, 5], upstream: [1]}, &two_key_list_fun/1)

      assert {:error, :proxy, %{proxy: [4, 5, 6], upstream: [1]},
              %{proxy: [{6, "server down"}, {5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy: [4, 5, 6], upstream: [1]}, &two_key_list_fun/1)

      assert {:error, :upstream, %{proxy: [4, 1], upstream: [4]}, %{proxy: [{4, "server down"}], upstream: [{4, "server down"}]}} =
               Failover.call(%{proxy: [4, 1], upstream: [4]}, &two_key_list_fun/1)

      assert {:error, :upstream, %{proxy: [4, 1], upstream: [4, 5]},
              %{proxy: [{4, "server down"}], upstream: [{5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy: [4, 1], upstream: [4, 5]}, &two_key_list_fun/1)

      assert {:error, :upstream, %{proxy: [4, 1], upstream: [4, 5, 6]},
              %{proxy: [{4, "server down"}], upstream: [{6, "server down"}, {5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy: [4, 1], upstream: [4, 5, 6]}, &two_key_list_fun/1)
    end

    test "returns a response when ONE of the redudant success" do
      assert {:ok, [1, 2], %{proxy: [1], upstream: [2]}, %{}} = Failover.call(%{proxy: [1], upstream: [2]}, &two_key_list_fun/1)

      assert {:ok, [1, 2], %{proxy: [1, 2], upstream: [2, 4]}, %{}} =
               Failover.call(%{proxy: [1, 2], upstream: [4, 2]}, &two_key_list_fun/1)

      assert {:ok, [2, 2], %{proxy: [2, 4], upstream: [2, 4]}, %{proxy: [{4, "server down"}], upstream: [{4, "server down"}]}} =
               Failover.call(%{proxy: [4, 2], upstream: [4, 2]}, &two_key_list_fun/1)

      assert {:ok, [1, 1], %{proxy: [1, 4, 1], upstream: [1, 4, 5]}, %{upstream: [{5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy: [1, 4, 1], upstream: [4, 5, 1]}, &two_key_list_fun/1)

      assert {:ok, [1, 1], %{proxy: [1, 4, 5], upstream: [1, 4, 5]},
              %{proxy: [{4, "server down"}], upstream: [{5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy: [4, 1, 5], upstream: [4, 5, 1]}, &two_key_list_fun/1)

      assert {:ok, [1, 1], %{proxy: [1, 4, 5], upstream: [1, 4, 5]},
              %{proxy: [{5, "server down"}, {4, "server down"}], upstream: [{5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy: [4, 5, 1], upstream: [4, 5, 1]}, &two_key_list_fun/1)

      assert {:ok, [1, 1], %{proxy: [1, 5, 4], upstream: [1, 4, 5, 6]},
              %{
                proxy: [{4, "server down"}, {5, "server down"}],
                upstream: [{6, "server down"}, {5, "server down"}, {4, "server down"}]
              }} = Failover.call(%{proxy: [5, 4, 1], upstream: [4, 5, 6, 1]}, &two_key_list_fun/1)
    end
  end

  describe "three key list of redundant" do
    test "returns an error when all redudants fail" do
      assert {:error, :proxy_one, %{proxy_one: [4], proxy_two: [1], upstream: [1]}, %{proxy_one: [{4, "server down"}]}} =
               Failover.call(%{proxy_one: [4], proxy_two: [1], upstream: [1]}, &three_key_list_fun/1)

      assert {:error, :proxy_one, %{proxy_one: [4, 5], proxy_two: [1], upstream: [1]},
              %{proxy_one: [{5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy_one: [4, 5], proxy_two: [1], upstream: [1]}, &three_key_list_fun/1)

      assert {:error, :proxy_one, %{proxy_one: [4, 5, 6], proxy_two: [1], upstream: [1]},
              %{proxy_one: [{6, "server down"}, {5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy_one: [4, 5, 6], proxy_two: [1], upstream: [1]}, &three_key_list_fun/1)

      assert {:error, :proxy_two, %{proxy_one: [1], proxy_two: [4], upstream: [1]}, %{proxy_two: [{4, "server down"}]}} =
               Failover.call(%{proxy_one: [1], proxy_two: [4], upstream: [1]}, &three_key_list_fun/1)

      assert {:error, :proxy_two, %{proxy_one: [1], proxy_two: [4, 5], upstream: [1]},
              %{proxy_two: [{5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy_one: [1], proxy_two: [4, 5], upstream: [1]}, &three_key_list_fun/1)

      assert {:error, :upstream, %{proxy_one: [1], proxy_two: [1], upstream: [4]}, %{upstream: [{4, "server down"}]}} =
               Failover.call(%{proxy_one: [1], proxy_two: [1], upstream: [4]}, &three_key_list_fun/1)

      assert {:error, :upstream, %{proxy_one: [4, 1], proxy_two: [4, 1], upstream: [4, 5]},
              %{
                proxy_one: [{4, "server down"}],
                proxy_two: [{4, "server down"}],
                upstream: [{5, "server down"}, {4, "server down"}]
              }} = Failover.call(%{proxy_one: [4, 1], proxy_two: [4, 1], upstream: [4, 5]}, &three_key_list_fun/1)

      assert {:error, :upstream, %{proxy_one: [1], proxy_two: [1], upstream: [4, 5, 6]},
              %{upstream: [{6, "server down"}, {5, "server down"}, {4, "server down"}]}} =
               Failover.call(%{proxy_one: [1], proxy_two: [1], upstream: [4, 5, 6]}, &three_key_list_fun/1)
    end

    test "returns a response when ONE of the redudant success" do
      assert {:ok, [1, 1, 1], %{proxy_one: [1], proxy_two: [1], upstream: [1]}, %{}} =
               Failover.call(%{proxy_one: [1], proxy_two: [1], upstream: [1]}, &three_key_list_fun/1)

      assert {:ok, [2, 1, 1], %{proxy_one: [2, 4], proxy_two: [1], upstream: [1]}, %{proxy_one: [{4, "server down"}]}} =
               Failover.call(%{proxy_one: [4, 2], proxy_two: [1], upstream: [1]}, &three_key_list_fun/1)

      assert {:ok, [1, 2, 1], %{proxy_one: [1], proxy_two: [2, 4], upstream: [1]}, %{proxy_two: [{4, "server down"}]}} =
               Failover.call(%{proxy_one: [1], proxy_two: [4, 2], upstream: [1]}, &three_key_list_fun/1)

      assert {:ok, [1, 1, 2], %{proxy_one: [1], proxy_two: [1], upstream: [2, 4]}, %{upstream: [{4, "server down"}]}} =
               Failover.call(%{proxy_one: [1], proxy_two: [1], upstream: [4, 2]}, &three_key_list_fun/1)

      assert {:ok, [1, 1, 2], %{proxy_one: [1, 4], proxy_two: [1, 4], upstream: [2, 4, 5]},
              %{
                proxy_one: [{4, "server down"}],
                proxy_two: [{4, "server down"}],
                upstream: [{5, "server down"}, {4, "server down"}]
              }} = Failover.call(%{proxy_one: [4, 1], proxy_two: [4, 1], upstream: [4, 5, 2]}, &three_key_list_fun/1)
    end
  end

  describe "statefull call" do
    test "create a state agent when no agent exist" do
      name = :client
      on_exit(fn -> tear_down(name) end)

      tear_down(name)

      assert {:error, :proxy_one, %{proxy_one: [4], proxy_two: [1], upstream: [1]}, %{proxy_one: [{4, "server down"}]}} =
               Failover.statefull_call(%{proxy_one: [4], proxy_two: [1], upstream: [1]}, &three_key_list_fun/1, name)

      assert %{proxy_one: [4], proxy_two: [1], upstream: [1]} =
               Agent.get({:via, Registry, {Failover.StateRegistry, name}}, fn state -> state end)
    end

    test "create a state agent per client" do
      name1 = :client1
      name2 = :client2
      on_exit(fn -> tear_down(name1) end)
      on_exit(fn -> tear_down(name2) end)

      tear_down(name1)
      tear_down(name2)

      assert {:ok, [1, 1], %{proxy: [1, 4, 5], upstream: [1, 4, 5]},
              %{proxy: [{5, "server down"}, {4, "server down"}], upstream: [{5, "server down"}, {4, "server down"}]}} =
               Failover.statefull_call(%{proxy: [4, 5, 1], upstream: [4, 5, 1]}, &two_key_list_fun/1, name1)

      assert {:ok, 2, %{upstream: [2, 4, 1]}, %{upstream: [{4, "server down"}]}} =
               Failover.statefull_call(%{upstream: [4, 2, 1]}, &one_key_list_fun/1, name2)

      assert %{proxy: [1, 4, 5], upstream: [1, 4, 5]} =
               Agent.get({:via, Registry, {Failover.StateRegistry, name1}}, fn state -> state end)

      assert %{upstream: [2, 4, 1]} = Agent.get({:via, Registry, {Failover.StateRegistry, name2}}, fn state -> state end)
    end

    test "state agent is updated with the new state" do
      name = :client
      on_exit(fn -> tear_down(name) end)

      tear_down(name)

      assert {:ok, 2, %{upstream: [2, 4]}, %{upstream: [{4, "server down"}]}} =
               Failover.statefull_call(%{upstream: [4, 2]}, &one_key_list_fun/1, name)

      assert %{upstream: [2, 4]} = Agent.get({:via, Registry, {Failover.StateRegistry, name}}, fn state -> state end)
    end

    test "the same state agent is used when force is false" do
      name = :client
      on_exit(fn -> tear_down(name) end)

      tear_down(name)

      assert {:ok, 2, %{upstream: [2, 4]}, %{upstream: [{4, "server down"}]}} =
               Failover.statefull_call(%{upstream: [4, 2]}, &one_key_list_fun/1, name)

      assert %{upstream: [2, 4]} = Agent.get({:via, Registry, {Failover.StateRegistry, name}}, fn state -> state end)

      assert {:ok, 2, %{upstream: [2, 4]}, %{}} = Failover.statefull_call(%{upstream: [4, 2, 1]}, &one_key_list_fun/1, name)
      assert %{upstream: [2, 4]} = Agent.get({:via, Registry, {Failover.StateRegistry, name}}, fn state -> state end)
    end

    test "the new state passed as argument is used when force is true" do
      name = :client
      on_exit(fn -> tear_down(name) end)

      tear_down(name)

      assert {:ok, 2, %{upstream: [2, 4]}, %{upstream: [{4, "server down"}]}} =
               Failover.statefull_call(%{upstream: [4, 2]}, &one_key_list_fun/1, name)

      assert %{upstream: [2, 4]} = Agent.get({:via, Registry, {Failover.StateRegistry, name}}, fn state -> state end)

      assert {:ok, 2, %{upstream: [2, 4, 1]}, %{upstream: [{4, "server down"}]}} =
               Failover.statefull_call(%{upstream: [4, 2, 1]}, &one_key_list_fun/1, %{}, name, true)

      assert %{upstream: [2, 4, 1]} = Agent.get({:via, Registry, {Failover.StateRegistry, name}}, fn state -> state end)
    end
  end

  def one_key_list_fun(param) do
    case param do
      %{upstream: value} when value in 1..3 and map_size(param) == 1 ->
        {:ok, value}

      %{upstream: _} ->
        {:error, {:upstream, "server down"}}
    end
  end

  def two_key_list_fun(param) do
    case param do
      %{proxy: pvalue, upstream: uvalue} when pvalue in 1..3 and uvalue in 1..3 ->
        {:ok, [pvalue, uvalue]}

      %{proxy: pvalue, upstream: _} when pvalue not in 1..3 ->
        {:error, {:proxy, "server down"}}

      %{proxy: _, upstream: uvalue} when uvalue not in 1..3 ->
        {:error, {:upstream, "server down"}}

      %{proxy: _, upstream: _} ->
        {:error, {:proxy, "server down"}}
    end
  end

  def three_key_list_fun(param) do
    case param do
      %{proxy_one: p1value, proxy_two: p2value, upstream: uvalue}
      when p1value in 1..3 and p2value in 1..3 and uvalue in 1..3 ->
        {:ok, [p1value, p2value, uvalue]}

      %{proxy_one: p1value, proxy_two: _, upstream: _} when p1value not in 1..3 ->
        {:error, {:proxy_one, "server down"}}

      %{proxy_one: _, proxy_two: p2value, upstream: _} when p2value not in 1..3 ->
        {:error, {:proxy_two, "server down"}}

      %{proxy_one: _, proxy_two: _, upstream: uvalue} when uvalue not in 1..3 ->
        {:error, {:upstream, "server down"}}

      %{proxy_one: _, proxy_two: _, upstream: _} ->
        {:error, {:proxy_one, "server down"}}
    end
  end
end
