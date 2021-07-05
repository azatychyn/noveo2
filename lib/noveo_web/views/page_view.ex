defmodule NoveoWeb.PageView do
  use NoveoWeb, :view

  def render("index.json", %{jobs: jobs}) do
    Enum.map(jobs, fn job ->
      %{
        "profession_id" => job["profession_id"],
        "contract_type" => job["contract_type"],
        "name" => job["name"],
        "office_latitude" => job["office_latitude"],
        "office_longitude" => job["office_longitude"],
        "distance" => job["distance"],
      }
    end)
  end
end
