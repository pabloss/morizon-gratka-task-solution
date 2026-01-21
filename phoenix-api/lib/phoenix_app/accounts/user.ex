defmodule PhoenixApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :birthdate, :date
    # Mapujemy string z bazy na atomy w Elixirze
    field :gender, Ecto.Enum, values: [:male, :female]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :birthdate, :gender])
    |> validate_required([:first_name, :last_name, :birthdate, :gender])
    # Zabezpieczenie enuma jest automatyczne dzięki Ecto.Enum,
    # ale można dodać dodatkowe reguły biznesowe tutaj.
  end
end
