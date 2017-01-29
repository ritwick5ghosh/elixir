defmodule SecondWebapp.Router do
  use SecondWebapp.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SecondWebapp do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
  end
end
