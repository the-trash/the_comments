class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post     = Post.find params[:id]
    @comments = @post.comments.with_state([:draft, :published]).nested_set
  end
end