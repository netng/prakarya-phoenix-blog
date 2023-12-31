defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Tags
  alias Blog.Comments.Comment
  alias Blog.Comments
  alias Blog.Posts
  alias Blog.Posts.Post

  def index(conn, params) do
    case params do
      %{"title" => title} ->
        posts = Posts.list_posts(title)
        render(conn, :index, posts: posts)
      %{} ->
        posts = Posts.list_posts()
        render(conn, :index, posts: posts)
    end
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, :new, changeset: changeset, tag_options: tag_options())
  end

  def create(conn, %{"post" => post_params}) do
    tags = Map.get(post_params, "tag_ids", []) |> Enum.map(&Tags.get_tag!/1)
    case Posts.create_post(post_params, tags) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset, tag_options: tag_options(Enum.map(tags, &(&1.id))))
    end
  end

  def show(conn, %{"id" => id}) do
    comment_changeset = Comments.change_comment(%Comment{})
    post = Posts.get_post!(id)
    comments = Comments.list_comments_by_post(post)
    IO.inspect(comments)
    render(conn, :show, post: post, comment_changeset: comment_changeset, comments: comments)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    changeset = Posts.change_post(post)
    render(conn, :edit,
      post: post,
      changeset: changeset,
      tag_options: tag_options(Enum.map(post.tags, &(&1.id))))
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)
    tags = Map.get(post_params, "tag_ids", []) |> Enum.map(&Tags.get_tag!/1)

    case Posts.update_post(post, post_params, tags) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          post: post,
          changeset: changeset,
          tag_options: Enum.map(tags, &(&1.id)))
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    if post.user_id == conn.assigns[:current_user].id do
      {:ok, _post} = Posts.delete_post(post)

      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: ~p"/posts")
    else
      conn
      |> put_flash(:error, "You can only delete your own posts.")
      |> redirect(to: ~p"/posts")
      |> halt()
    end
  end

  def create_comment(conn, %{"post_id" => post_id, "comment" => comment_params}) do
    post = Posts.get_post!(post_id)
    current_user = conn.assigns[:current_user]
    case Comments.create_comment(Map.put(comment_params, "post_id", post_id) |> Map.put("user_id", current_user.id)) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: ~p"/posts/#{post_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
       render(conn, :show, post: post, comment_changeset: changeset)
    end
  end

  def delete_comment(conn, %{"post_id" => post_id, "comment_id" => comment_id}) do
    comment = Comments.get_comment!(comment_id)
    if comment.user_id == conn.assigns[:current_user].id do
      {:ok, _comment} = Comments.delete_comment(comment)

      conn
      |> put_flash(:info, "Comment deleted successfully")
      |> redirect(to: ~p"/posts/#{post_id}")
    else
      conn
      |> put_flash(:error, "You can only delete your own comments.")
      |> redirect(to: ~p"/posts/#{post_id}")
      |> halt()
    end
  end

  def edit_comment(conn, %{"post_id" => post_id, "comment_id" => comment_id}) do
    comment = Comments.get_comment!(comment_id)
    changeset = Comments.change_comment(comment)
    render(conn, :edit_comment, changeset: changeset, comment: comment, post_id: post_id)
  end

  def update_comment(conn, %{"comment_id" => comment_id, "comment" => comment_params}) do
    comment = Comments.get_comment!(comment_id)

    case Comments.update_comment(comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully")
        |> redirect(to: ~p"/posts/#{comment.post}")
    end
  end

  defp tag_options(selected_ids \\ []) do
    Tags.list_tags()
    |> Enum.map(fn tag -> [key: tag.name, value: tag.id, selected: tag.id in selected_ids] end)
  end

end
