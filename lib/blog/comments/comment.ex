defmodule Blog.Comments.Comment do
  alias Blog.Accounts.User
  alias Blog.Posts.Post
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string

    belongs_to :post, Post
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :post_id, :user_id])
    |> validate_required([:content, :post_id, :user_id])
    |> validate_fk_constraint()
  end

  def validate_fk_constraint(changeset) do
    changeset
    |> foreign_key_constraint(:post_id)
    |> foreign_key_constraint(:user_id)
  end
end
