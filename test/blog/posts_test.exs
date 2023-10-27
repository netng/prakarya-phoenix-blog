defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts
  import Ecto.Query, warn: false

  describe "posts" do
    alias Blog.Posts.Post

    import Blog.PostsFixtures

    @invalid_attrs %{title: nil, published_on: nil, visible: nil, content: nil}

    test "list_posts/0 returns all posts are displayed from newest -> oldest" do
      post_attrs = [
        %{
          title: "some title 1",
          published_on: ~D"2023-10-26",
          visible: true,
          content: "some content 1",
          inserted_at: NaiveDateTime.local_now(),
          updated_at: NaiveDateTime.local_now()
        },
        %{
          title: "some title 2",
          published_on: ~D"2023-10-27",
          visible: true,
          content: "some content 2",
          inserted_at: NaiveDateTime.local_now(),
          updated_at: NaiveDateTime.local_now()
        }
      ]


      Repo.insert_all(Post, post_attrs)
      posts = Posts.list_posts()

      assert posts
      |> Enum.at(0)
      |> Map.get(:published_on) ==  ~D"2023-10-27"

    end

    test "list_posts/0 ensure posts with a published date in the future are filtered from the list of posts" do
      post_attrs = %{
        title: "end of life",
        published_on: ~D"9999-10-27",
        visible: :true,
        content: "end of life content"
      }

      {:ok, _} = Posts.create_post(post_attrs)
      posts = Posts.list_posts()

      assert posts == []
    end

    test "list_posts/0 ensure posts with visible: :false are filtered from the list of posts" do
      post_attrs = %{
        title: "some title 2",
        published_on: ~D"2023-10-27",
        visible: :false,
        content: "some content 2"
      }

      Posts.create_post(post_attrs)
      posts = Posts.list_posts()

      assert posts == []
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{
        title: "some title",
        published_on: ~D"2023-10-27",
        visible: :true,
        content: "some content"
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.title == "some title"
      assert post.published_on == ~D"2023-10-27"
      assert post.visible == true
      assert post.content == "some content"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{title: "some updated title", published_on: ~D"2023-10-27", visible: true, content: "some updated content"}

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.title == "some updated title"
      assert post.published_on == Date.utc_today()
      assert post.visible == true
      assert post.content == "some updated content"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end

    test "list_posts/1 filters posts by partial and case-insensitive title" do
      post = post_fixture(title: "Title")

      # non-matching
      assert Posts.list_posts("Non-Matching") == []

      # exact match
      assert Posts.list_posts("Title") == [post]

      # partial match end
      assert Posts.list_posts("tle") == [post]

      # partial match front
      assert Posts.list_posts("tit") == [post]

      # partial match middle
      assert Posts.list_posts("itl") == [post]

      # case insensitive lower
      assert Posts.list_posts("title") == [post]

      # case insensitive upper
      assert Posts.list_posts("TITLE") == [post]

      # case insensitive and partial match
      assert Posts.list_posts("TIT") == [post]

      # empty
      assert Posts.list_posts("") == [post]

    end
  end
end
