defmodule Efl.Dadi.Post do
  alias Efl.Repo
  alias Efl.Dadi.Main, as: Dadi
  alias Efl.HtmlParsers.Dadi.Post, as: HtmlParser
  import Ecto.Query, only: [from: 2] 

  def update_contents do
    get_all_blank_records
    |> Enum.map(fn(d) -> d.url end)
    |> HtmlParser.async_parse_posts
    |> Enum.map(fn(p) ->
      Map.get(p, :url)
      |> find_dadi_by_url
      |> update(p)
    end)
  end

  def get_all_blank_records do
    query = from d in Dadi,
      where: is_nil(d.content),
      limit: 120
    Repo.all(query)
  end

  def find_dadi_by_url(url) do
    query = from d in Dadi,
      where: (d.url == ^url),
      limit: 1
    Repo.one(query)
  end

  def update(dadi, params) do
    set = Dadi.update_changeset(dadi, params)
    case Repo.update(set) do
      {:ok, struct} -> IO.puts("Insert one record successfully #{Map.get(struct, :content)}")
      {:error, changeset} -> IO.inspect(Map.get(changeset, :errors))
    end
  end
end
