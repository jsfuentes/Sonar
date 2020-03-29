defmodule SonarWeb.ApiController do
  use SonarWeb, :controller

  def test(conn, _params) do
    users = [
      %{name: "Joe",
        email: "joe@example.com",
        password: "topsecret",
        stooge: "moe"},
      %{name: "Anne",
        email: "anne@example.com",
        password: "guessme",
        stooge: "larry"},
      %{name: "Franklin",
        email: "franklin@example.com",
        password: "guessme",
        stooge: "curly"},
    ]

    rawPayload = %{
      requests: [
        %{
          image: %{
            source: %{
              imageUri: "https://www.slingshow.com/static/media/alextapper.486a84fa.png"
            }
          },
          features: [
            %{
              type: "LABEL_DETECTION",
              maxResults: 1
            },
            %{
              type: "FACE_DETECTION",
              maxResults: 3
            }
          ]
        }
      ]
    }
    IO.inspect rawPayload
    {status, payload} = JSON.encode(payload)
    token = "some_token_from_another_request"
    url = "https://vision.googleapis.com/v1/images:annotate"
    headers = ["Authorization": "Bearer #{token}", "Accept": "Application/json; Charset=utf-8", "Content-Type": "Application/json; charset=utf-8"]
    
    case HTTPoison.post url, payload, headers do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        json conn, body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        json conn, "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        json conn, reason
    end
  end
end
