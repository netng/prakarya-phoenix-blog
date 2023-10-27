defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content 1",
        published_on: ~D"2023-10-27",
        visible: true,
        title: "some title 1"
      })
      |> Blog.Posts.create_post()

    post
  end
end


[
  %{title: "post 1", published_on: Date.utc_today(), visible: :true, content: "content 1", inserted_at: NaiveDateTime.local_now(), updated_at: NaiveDateTime.local_now()},
  %{title: "post 2", published_on: Date.utc_today(), visible: :true, content: "content 2", inserted_at: NaiveDateTime.local_now(), updated_at: NaiveDateTime.local_now()}
]
