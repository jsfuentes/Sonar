defmodule SonarWeb.ApiController do
  use SonarWeb, :controller

  def image(conn, %{"image" => image}) do
    rawPayload = %{
      requests: [
        %{
          image: %{
            content: image
          },
          features: [
            %{
              type: "LABEL_DETECTION",
              maxResults: 1
            }
          ]
        }
      ]
    }
    IO.inspect rawPayload
    {status, payload} = JSON.encode(rawPayload)
    url = "https://vision.googleapis.com/v1/images:annotate?key=#{Application.fetch_env!(:sonar, :google)}"
    headers = ["Accept": "Application/json; Charset=utf-8", "Content-Type": "Application/json; charset=utf-8"]
    
    case HTTPoison.post url, payload, headers do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        topObject = bodyToText(body)
        audio = textToAudio(topObject)
        json conn, audio
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        json conn, "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        json conn, reason
    end
  end

  def bodyToText(body) do
    {status, myBody} = JSON.decode(body)
    IO.inspect myBody
    resp = List.first(myBody["responses"])
    List.first(resp["labelAnnotations"])["description"]
  end

  def textToAudio(text) do 
    rawPayload = %{
      "input": %{
        "text": text
      },
      "voice": %{
        "languageCode": "en-gb",
        "name": "en-GB-Standard-A",
        "ssmlGender": "FEMALE"
      },
      "audioConfig": %{
        "audioEncoding": "MP3"
      }
    }
    IO.inspect rawPayload
    {status, payload} = JSON.encode(rawPayload)
    url = "https://texttospeech.googleapis.com/v1/text:synthesize?key=#{Application.fetch_env!(:sonar, :google)}"
    headers = ["Accept": "Application/json; Charset=utf-8", "Content-Type": "Application/json; charset=utf-8"]
    
    case HTTPoison.post url, payload, headers do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {status, myBody} = JSON.decode(body)
        myBody
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        reason
    end
  end
end
