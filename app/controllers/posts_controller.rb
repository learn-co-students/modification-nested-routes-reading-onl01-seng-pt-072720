class PostsController < ApplicationController

  def index
    if params[:author_id]
      @posts = Author.find(params[:author_id]).posts
    else
      @posts = Post.all
    end
  end

  def show
    if params[:author_id]
      @post = Author.find(params[:author_id]).posts.find(params[:id])
    else
      @post = Post.find(params[:id])
    end
  end

  def new
    if params[:author_id] && !Author.exists?(params[:author_id]) # Here we check for params[:author_id] and then for Author.exists? to see if the author is real. Why aren't we doing a find_by and getting the author instance? Because we don't need a whole author instance for Post.new; we just need the author_id. And we don't need to check against the posts of the author because we're just creating a new one. So we use exists? to quickly check the database in the most efficient way.
      redirect_to authors_path, alert: "Author not found."
    else
      @post = Post.new(author_id: params[:author_id])
    end
  end

  def create
    @post = Post.new(post_params)
    @post.save
    redirect_to post_path(@post)
  end

  def update
    @post = Post.find(params[:id])
    @post.update(post_params)
    redirect_to post_path(@post)
  end

  def edit # What we should do is check to make sure that 1) the author_id is valid and 2) the post matches the author.
    if params[:author_id] # Here we're looking for the existence of params[:author_id], which we know would come from our nested route.
      author = Author.find_by(id: params[:author_id]) 
      if author.nil? # If it's there, we want to make sure that we find a valid author.
        redirect_to authors_path, alert: "Author not found." # If we can't, we redirect them to the authors_path with a flash[:alert].
      else
        @post = author.posts.find_by(id: params[:id]) # If we do find the author, we next want to find the post by params[:id], but, instead of directly looking for Post.find(), we need to filter the query through our author.posts collection to make sure we find it in that author's posts. It may be a valid post id, but it might not belong to that author, which makes this an invalid request.
        redirect_to author_posts_path(author), alert: "Post not found." if @post.nil?
      end
    else
      @post = Post.find(params[:id])
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :description, :author_id)
  end
end
