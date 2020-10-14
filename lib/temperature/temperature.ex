defmodule Temperature do
  # server
  def loop(state) do
    receive do
      {:define_temp, _from, {sensor_name, sensor_temperature}} ->
        new_state =
          state
          |> Map.update(
            sensor_name,
            [sensor_temperature],
            fn list_of_values ->
              [sensor_temperature | list_of_values]
            end
          )

        loop(new_state)

      {:query_history, from, sensor_name} ->
        list_of_temperatures =
          state
          |> Map.get(sensor_name)

        send(from, {:ok, list_of_temperatures})
        loop(state)

      {:query_temp, from, sensor_name} ->
        value =
          state
          |> Map.get(sensor_name, [])
          |> List.first()

        send(from, {:ok, value})
        loop(state)
    end
  end

  # client

  def init() do
    %{
      "sensor1" => []
    }
  end

  def start(init_arg \\ :ignored) do
    spawn(__MODULE__, :loop, [init()])
    |> Process.register(__MODULE__)

    :ok
  end

  def define_temp(sensor_name, sensor_temperature) do
    send(__MODULE__, {:define_temp, self(), {sensor_name, sensor_temperature}})
  end

  def query_history(sensor_name) do
    send(__MODULE__, {:query_history, self(), sensor_name})

    receive do
      {:ok, list_of_temeperatures} ->
        list_of_temeperatures
    end
  end

  def query_temp(sensor_name) do
    send(__MODULE__, {:query_temp, self(), sensor_name})

    receive do
      {:ok, value} ->
        value
    end
  end
end
