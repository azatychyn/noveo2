defmodule Noveo.Geocoordinates do
  @lat_eur [
    90.0,
    90.0,
    42.5,
    42.5,
    40.79,
    41.0,
    40.55,
    40.40,
    40.05,
    39.17,
    35.46,
    33.0,
    38.0,
    35.42,
    28.25,
    15.0,
    57.5,
    78.13
  ]
  @lon_eur [
    -10.0,
    77.5,
    48.8,
    30.0,
    28.81,
    29.0,
    27.31,
    26.75,
    26.36,
    25.19,
    27.91,
    27.5,
    10.0,
    -10.0,
    -13.0,
    -30.0,
    -37.5,
    -10.0
  ]
  @lat_as1 [
    90.0,
    42.5,
    42.5,
    40.79,
    41.0,
    40.55,
    40.4,
    40.05,
    39.17,
    35.46,
    33.0,
    31.74,
    29.54,
    27.78,
    11.3,
    12.5,
    -60.0,
    -60.0,
    -31.88,
    -11.88,
    -10.27,
    33.13,
    51.0,
    60.0,
    90.0
  ]
  @lon_as1 [
    77.5,
    48.8,
    30.0,
    28.81,
    29.0,
    27.31,
    26.75,
    26.36,
    25.19,
    27.91,
    27.5,
    34.58,
    34.92,
    34.46,
    44.3,
    52.0,
    75.0,
    110.0,
    110.0,
    110.0,
    140.0,
    140.0,
    166.6,
    180.0,
    180.0
  ]

  @lat_afr [15.0, 28.25, 35.42, 38.0, 33.0, 31.74, 29.54, 27.78, 11.3, 12.5, -60.0, -60.0]
  @lon_afr [-30.0, -13.0, -10.0, 10.0, 27.5, 34.58, 34.92, 34.46, 44.3, 52, 75.0, -30.0];

  @lat_as2 [90.0, 90.0, 60.0, 60.0]
  @lon_as2 [-180.0, -168.75, -168.75, -180.0]

  @lat_aus [-11.88, -10.27, -10.0, -30.0, -52.5, -31.88]
  @lon_aus [110.0, 140.0, 145.0, 161.25, 142.5, 110.0]

  @lat_south_am [1.25, 1.25, 15.0, 15.0, -60.0, -60.0]
  @lon_south_am [-105.0, -82.5,  -75.0, -30.0, -30.0, -105.0]

  @lat_north_am [90.0, 90.0, 78.13, 57.5, 15.0, 15.0, 1.25, 1.25, 51.0, 60.0, 60.0]
  @lon_north_am [-168.75, -10.0, -10.0, -37.5, -30.0, -75.0, -82.5, -105.0, -180.0, -180.0, -168.75]

  @earth_radius 6_371_000
  @pi :math.pi()

  @spec detect_continent({integer, map()}) :: String.t()
  def detect_continent({_, %{"office_longitude" => _, "office_latitude" => nil}}), do: "World"
  def detect_continent({_, %{"office_longitude" => nil, "office_latitude" => _}}), do: "World"

  def detect_continent(
        {_, %{"office_longitude" => office_longitude, "office_latitude" => office_latitude}}
      ) do
    point = [office_latitude, office_longitude]

    cond do
      Geocalc.within?(europe_polygon(), point) ->
        "Europe"

      Geocalc.within?(asia_main_polygon(), point) ->
        "Asia"

      Geocalc.within?(asia_add_polygon(), point) ->
        "Asia"

      Geocalc.within?(africa_polygon(), point) ->
        "Africa"

      Geocalc.within?(australia_polygon(), point) ->
        "Australia"

      Geocalc.within?(south_america_polygon(), point) ->
        "South America"

      Geocalc.within?(north_america_polygon(), point) ->
        "Noth America"

      true ->
        "World"
    end
  end

  defp europe_polygon() do
    Enum.zip_with([@lat_eur, @lon_eur], fn [x, y] -> [x, y] end)
  end

  defp asia_main_polygon() do
    Enum.zip_reduce(@lat_as1, @lon_as1, [], fn x, y, acc -> [[x, y] | acc] end)
  end

  defp asia_add_polygon() do
    Enum.zip_reduce(@lat_as2, @lon_as2, [], fn x, y, acc -> [[x, y] | acc] end)
  end

  defp africa_polygon() do
    Enum.zip_reduce(@lat_afr, @lon_afr, [], fn x, y, acc -> [[x, y] | acc] end)
  end

  defp australia_polygon() do
    Enum.zip_reduce(@lat_aus, @lon_aus, [], fn x, y, acc -> [[x, y] | acc] end)
  end

  defp south_america_polygon() do
    Enum.zip_reduce(@lat_south_am, @lon_south_am, [], fn x, y, acc -> [[x, y] | acc] end)
  end

  defp north_america_polygon() do
    Enum.zip_reduce(@lat_north_am, @lon_north_am, [], fn x, y, acc -> [[x, y] | acc] end)
  end
end
