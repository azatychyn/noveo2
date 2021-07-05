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
  @lat_as2 [90.0, 90.0, 60.0, 60.0]
  @lon_as2 [-180.0, -168.75, -168.75, -180.0]

  @earth_radius 6_371_000
  @pi :math.pi()

  def europe_polygon() do
    Enum.zip_with([@lat_eur, @lon_eur], fn [x, y] -> [x, y] end)
  end

  defp asia_main_polygon() do
    Enum.zip_reduce(@lat_as1, @lon_as1, [], fn x, y, acc -> [[x, y] | acc] end)
  end

  defp asia_add_polygon() do
    Enum.zip_reduce(@lat_as2, @lon_as2, [], fn x, y, acc -> [[x, y] | acc] end)
  end

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

      true ->
        "World"
    end
  end

  # it is not optimized but it works
  @spec within?(float(), float(), float(), float(), integer) :: {float, boolean()}
  def within?(_lat_center, _long_center, _lat_point, long_point, _radius)
      when long_point in ["", nil],
      do: {0, false}

  def within?(_lat_center, _long_center, lat_point, _long_point, _radius)
      when lat_point in ["", nil],
      do: {0, false}

  def within?(_lat_center, _long_center, _lat_point, _long_point, radius) when radius < 0,
    do: {0, false}

  def within?(lat_center, long_center, lat_point, long_point, radius \\ 10_0000) do
    distance = distance_between(lat_center, long_center, lat_point, long_point)
    {distance, distance <= radius}
  end

  defp distance_between(lat_center, long_center, lat_point, long_point, radius \\ @earth_radius) do
    rad_center = degrees_to_radians(lat_center)
    rad_point = degrees_to_radians(lat_point)
    diff_lat = degrees_to_radians(lat_point - lat_center)
    diff_long = degrees_to_radians(long_point - long_center)

    a =
      :math.sin(diff_lat / 2) * :math.sin(diff_lat / 2) +
        :math.cos(rad_center) * :math.cos(rad_point) * :math.sin(diff_long / 2) *
          :math.sin(diff_long / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    radius * c
  end

  defp degrees_to_radians(degrees) do
    normalize_degrees(degrees) * @pi / 180
  end

  defp normalize_degrees(degrees) when degrees < -180 do
    normalize_degrees(degrees + 360)
  end

  defp normalize_degrees(degrees) when degrees > 180 do
    normalize_degrees(degrees - 360)
  end

  defp normalize_degrees(degrees) do
    degrees
  end
end
