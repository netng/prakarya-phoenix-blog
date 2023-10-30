defmodule BlogWeb.PostController do
  use BlogWeb, :controller

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
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Posts.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    comment_changeset = Comments.change_comment(%Comment{})
    post = Posts.get_post!(id)
    render(conn, :show, post: post, comment_changeset: comment_changeset)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    changeset = Posts.change_post(post)
    render(conn, :edit, post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end

  def create_comment(conn, %{"post_id" => post_id, "comment" => comment_params}) do
    post = Posts.get_post!(post_id)
    case Comments.create_comment(Map.put(comment_params, "post_id", post_id)) do
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
    {:ok, _comment} = Comments.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully")
    |> redirect(to: ~p"/posts/#{post_id}")
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

end
