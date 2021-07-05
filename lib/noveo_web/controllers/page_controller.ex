defmodule NoveoWeb.PageController do
  use NoveoWeb, :controller

  def get_jobs(conn, %{"latitude" => latitude, "longitude" => longitude, "radius" => radius}) do
    with  {latitude, _} <- Float.parse(latitude),
          {longitude, _} <- Float.parse(longitude),
          {radius, _} <- Integer.parse(radius)
    do
      jobs = Noveo.Employment.get_jobs_in_radius_of_point(latitude, longitude, radius * 1000)
      render(conn, "index.json", jobs: jobs)
    else
      _ ->
        error_message =
        %{
          "latitude" => "nust be float",
          "longitude" => "nust be float",
          "radius" => "nust be integer"
        }
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(error_message))
    end
  end
end
