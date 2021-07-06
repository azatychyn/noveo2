defmodule NoveoWeb.PageControllerTest do
  use NoveoWeb.ConnCase

  test "GET /", %{conn: conn} do
    latitude = -25.340921461827673
    longitude = 133.7374681517328
    redius = 3000
    encoded_params =
      %{"latitude" => latitude, "longitude" => longitude, "radius" => redius}
      |> URI.encode_query()
    query = "?#{encoded_params}"

    conn = get(conn,  Routes.page_path(conn, :get_jobs) <> query)
    assert json_response(conn, 200) == [
      %{
        "contract_type" => "FULL_TIME",
        "distance" => 1744872.8792098926,
        "name" => "[TAG Heuer Australia] Boutique Manager - Melbourne",
        "office_latitude" => -37.814479,
        "office_longitude" => 144.965794,
        "profession_id" => 31
      }
    ]
  end

  test "GET / with invalid params", %{conn: conn} do
    latitude = "latitude"
    longitude = 133.7374681517328
    redius = 3000
    encoded_params =
      %{"latitude" => latitude, "longitude" => longitude, "radius" => redius}
      |> URI.encode_query()
    query = "?#{encoded_params}"

    conn = get(conn,  Routes.page_path(conn, :get_jobs) <> query)
    assert json_response(conn, 400) ==
      %{
        "latitude" => "nust be float",
        "longitude" => "nust be float",
        "radius" => "nust be integer"
      }
  end
end
