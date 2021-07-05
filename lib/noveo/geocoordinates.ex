defmodule Noveo.Geocoordinates do
  @lat_eur [ 90, 90, 42.5, 42.5, 40.79, 41, 40.55, 40.40, 40.05, 39.17, 35.46, 33, 38, 35.42, 28.25, 15, 57.5, 78.13 ]
  @lon_eur [ -10, 77.5, 48.8, 30, 28.81, 29, 27.31, 26.75, 26.36, 25.19, 27.91, 27.5, 10, -10, -13, -30, -37.5, -10 ]
  @lat_as1 [ 90, 42.5, 42.5, 40.79, 41, 40.55, 40.4, 40.05, 39.17, 35.46, 33, 31.74, 29.54, 27.78, 11.3, 12.5, -60, -60, -31.88, -11.88, -10.27, 33.13, 51, 60, 90 ]
  @lon_as1 [ 77.5, 48.8, 30, 28.81, 29, 27.31, 26.75, 26.36, 25.19, 27.91, 27.5, 34.58, 34.92, 34.46, 44.3, 52, 75, 110, 110, 110, 140, 140, 166.6, 180, 180 ]
  @lat_as2 [90, 90, 60, 60]
  @lon_as2 [-180, -168.75, -168.75, -180]


  @earth_radius 6_371_000
  @pi :math.pi()

  defp europe_polygon() do
    coordinates = Enum.zip(@lat_eur, @lon_eur)
    %Geo.Polygon{coordinates: [coordinates]}
  end

  defp asia_main_polygon() do
    coordinates = Enum.zip(@lat_as1, @lon_as1)
    %Geo.Polygon{coordinates: [coordinates]}
  end
  defp asia_add_polygon() do
    coordinates = Enum.zip(@lat_as2, @lon_as2)
    %Geo.Polygon{coordinates: [coordinates]}
  end

  @spec detect_continent({integer, map()}) :: :europe | :asia | :world
  def detect_continent({_, %{"office_longitude" => _, "office_latitude" => nil}}), do: "World"
  def detect_continent({_, %{"office_longitude" => nil, "office_latitude" => _}}), do: "World"
  def detect_continent({_, %{"office_longitude" => office_longitude, "office_latitude" => office_latitude}}) do
    point = %Geo.Point{coordinates: {office_latitude, office_longitude}}
    cond do
      Topo.contains?(europe_polygon(), point) ->
        "Europe"
      Topo.contains?(asia_main_polygon(), point) ->
        "Asia"
      Topo.contains?(asia_add_polygon(), point) ->
        "Asia"
      true ->
        "World"
    end
  end
  #it is not optimized but it works
  @spec within?(float(),float(),float(),float(), integer) :: {float, boolean()}
  def within?(_lat_center, _long_center, _lat_point, long_point, _radius) when long_point in ["", nil], do: {0, false}
  def within?(_lat_center, _long_center, lat_point, _long_point, _radius) when lat_point in ["", nil], do: {0, false}
  def within?(_lat_center, _long_center, _lat_point, _long_point, radius) when radius < 0, do: {0, false}
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
        :math.cos(rad_center) * :math.cos(rad_point) * :math.sin(diff_long / 2) * :math.sin(diff_long / 2)

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
