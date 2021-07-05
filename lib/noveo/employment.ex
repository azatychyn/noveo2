defmodule Noveo.Employment do
  import Ecto.Query, warn: false

  @spec parse_professions() :: :ok
  def parse_professions() do
    File.cwd!()
    |> Path.join("csv/professions.csv")
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Enum.each(fn {_, params} ->
      id = String.to_integer(params["id"])
      params = Map.put(params, "id", id)
      ConCache.put(:professions, id, params)
    end)
  end

  @spec parse_jobs() :: :ok
  def parse_jobs() do
    File.cwd!()
    |> Path.join("csv/jobs.csv")
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Enum.reduce(0, fn {_, params}, index ->
      profession_id =
        if params["profession_id"] not in ["", nil] do
          String.to_integer(params["profession_id"])
        else
          nil
        end

      office_longitude =
        if params["office_longitude"] not in ["", nil] do
          String.to_float(params["office_longitude"])
        else
          nil
        end

      office_latitude =
        if params["office_latitude"] not in ["", nil] do
          String.to_float(params["office_latitude"])
        else
          nil
        end

      params =
        params
        |> Map.put("profession_id", profession_id)
        |> Map.put("office_longitude", office_longitude)
        |> Map.put("office_latitude", office_latitude)

      ConCache.put(:jobs, index, params)
      index + 1
    end)
  end
end
