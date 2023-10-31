defmodule Blog.Posts.Post do
  alias Blog.Comments.Comment
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
    field :published_on, :date
    field :visible, :boolean, default: :true

    has_many :comments, Comment

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :published_on, :visible, :content])
    |> validate_required([:title, :content])
    |> unique_constraint(:title)
  end
end
