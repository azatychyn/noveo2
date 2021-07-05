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

  @spec get_jobs_in_radius_of_point(number(), number(), number()) :: [map(), ...]
  def get_jobs_in_radius_of_point(lat_center, long_center, radius) do
    center_point = [lat_center, long_center]
    :jobs
    |> ConCache.ets()
    |> :ets.tab2list()
    |> Enum.reduce([], fn {_, job}, acc ->
      point = [job["office_latitude"], job["office_longitude"]]

      with  false <- is_nil(List.first(point)),
            false <- is_nil(List.last(point)),
            true <- Geocalc.within?(radius, center_point, point)
      do
        distance = Geocalc.distance_between(center_point, point)
        [ Map.put(job, "distance", distance) | acc]
      else
        _ ->
          acc
      end
    end)
  end

  @spec print_table_of_jobs() :: :ok
  def print_table_of_jobs() do
    results = get_all_jobs_grouped_by_category_and_continent()
    headers =
      Enum.reduce(results, %{}, fn map, acc ->
        Map.merge(acc, map)
      end)
      |> Map.keys()

    Scribe.print(results, [data: headers])
  end

  defp get_all_jobs_grouped_by_category_and_continent() do
    statistic_grouped_by_category_and_continent =
      :jobs
      |> ConCache.ets()
      |> :ets.tab2list()
      |> Enum.group_by(&Noveo.Geocoordinates.detect_continent/1)
      |> Enum.map(fn {continent, jobs} ->
        jobs
        |> group_by_category()
        |> Map.put("continent", continent)
      end)
    total_statistic =
      statistic_grouped_by_category_and_continent
      |> Enum.reduce(%{}, fn map, acc ->
        Map.merge(acc, map, fn key, v1, v2 ->
          if key == "continent" do
            "Total"
          else
            v1 + v2
          end
        end)
      end)

    [total_statistic | statistic_grouped_by_category_and_continent]
  end

  defp group_by_category(jobs) do
    grouped_jobs =
      jobs
      |> Enum.group_by(&get_professions_category_from_dict/1)
      |> Enum.filter(fn {category, _jobs} -> category end)
      |> Enum.map(fn {category, jobs} -> {category, length(jobs)} end)
      |> Map.new()

    total =
      grouped_jobs
      |> Map.values()
      |> Enum.sum()
    Map.put(grouped_jobs, "Total", total)
  end

  defp get_professions_category_from_dict({_,%{"profession_id" => profession_id}}) do
    professions_dict()[profession_id]["category_name"]
  end

  defp professions_dict() do
    :professions
    |> ConCache.ets()
    |> :ets.tab2list()
    |> Map.new()
  end
end
