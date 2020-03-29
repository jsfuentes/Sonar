defmodule SonarWeb.PageController do
  use SonarWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
