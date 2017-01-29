defmodule SecondWebapp.UserView do
  use SecondWebapp.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, SecondWebapp.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, SecondWebapp.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      email: user.email,
      bio: user.bio,
      number_of_pets: user.number_of_pets}
  end
end
