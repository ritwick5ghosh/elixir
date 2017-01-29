defmodule First.Repo do
  use Ecto.Repo,
    otp_app: :my_app
end
end

defmodule First.Config do
  use Ecto.Schema

  schema "cca_config" do
    field :NAME     # Defaults to type :string
    field :DESCRIPTION
    field :VALUE
  end
end

defmodule First.App do
  import Ecto.Query
  alias First.Config
  alias First.Repo

  def keyword_query do
    query = from c in Config,
         select: c
    Repo.all(query)
  end

  def pipe_query do
    Config
    |> limit(10)
    |> Repo.all
  end
end
