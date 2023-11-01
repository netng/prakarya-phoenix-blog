defmodule Blog.CoverImages.CoverImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cover_images" do
    field :url, :string
    field :post_id, :id

    timestamps()
  end

  @doc false
  def changeset(cover_image, attrs) do
    cover_image
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
