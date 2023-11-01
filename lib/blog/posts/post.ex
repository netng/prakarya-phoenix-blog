defmodule Blog.Posts.Post do
  alias Blog.Tags.Tag
  alias Blog.Accounts.User
  alias Blog.Comments.Comment
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
    field :published_on, :date
    field :visible, :boolean, default: :true

    has_many :comments, Comment

    belongs_to :user, User

    many_to_many :tags, Tag, join_through: "posts_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(post, attrs, tags \\ []) do
    post
    |> cast(attrs, [:title, :published_on, :visible, :content, :user_id])
    |> validate_required([:title, :content, :user_id])
    |> unique_constraint(:title)
    |> foreign_key_constraint(:user_id)
    |> put_assoc(:tags, tags)
  end
end
