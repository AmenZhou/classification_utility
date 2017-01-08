defmodule Efl.HtmlParsers.Dadi.Post do
  alias Efl.HtmlParsers.Dadi.Post, as: PostParser
  alias Efl.PhoneUtil
  require IEx

  defstruct [:url, :phone, :content]

  @http_config [
    ibrowse: [proxy_host: '70.248.28.23', proxy_port: 800],
    timeout: 50_000
  ]
  @http_interval 20_000

  def parse_posts(urls) do
    urls
    |> Enum.map(&parse_post(&1))
  end

  def async_parse_posts(urls) do
    urls
    |> Enum.map(fn(url) ->
      :timer.sleep(10_000)
      Task.async(PostParser, :parse_post, [url])
    end)
    |> Enum.map(fn(task) ->
      Task.await(task)
    end)
  end

  def parse_post(url) do
    :timer.sleep(@http_interval)
    case html(url) do
      { :ok, body } ->
        IO.puts("Post parsed one url: #{url}")
        content = body
                  |> Floki.find(".postbody")
                  |> Floki.text
                  |> String.strip

        phone = PhoneUtil.find_phone_from_content(content)

        %PostParser{
          content: content,
          url: url,
          phone: phone
        }
      { :error, message } ->
        IO.puts("Error PostParser.Dadi.Post HTML parse error, #{message}")
    end
  end
    
  defp html(url) do
    case HTTPotion.get(url, @http_config) do
      %{ body: body } ->
        { :ok, body }
      %{ message: message } ->
        { :error, message }
    end
  end
end
