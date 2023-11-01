defmodule Blog.CoverImages.CoverImage do
  alias Blog.Posts.Post
  use Ecto.Schema
  import Ecto.Changeset

  schema "cover_images" do
    field :url, :string

    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(cover_image, attrs) do
    cover_image
    |> cast(attrs, [:url])
    |> validate_required([:url])
    |> foreign_key_constraint(:post_id)
  end
end
