class PostsController < ApplicationController
  def index
    @posts = Post.all
    @recent_comments = Comment.with_state(:published)
                       .where(commentable_state: [:published])
                       .recent.page(params[:page])
  end

  def show
    @post     = Post.find params[:id]
    @comments = @post.comments.with_state([:draft, :published]).nested_set
  end
end