defmodule Empty do
  immport Enum
  @moduledoc false

  def empty() do
    each
  end
end