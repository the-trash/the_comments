module TheCommentsController
  extend ActiveSupport::Concern

  included do
    include TheCommentViewToken
    # include ActionView::Helpers::UrlHelper
    # include Rails.application.routes.url_helpers
    # include UrlFor

    before_action :define_commentable, only: [:create]

    def create
      @comment = @commentable.comments.new comment_params
      if @comment.valid?
        @comment.save
        return render(layout: false, template: "comments/comment")
      end
      render json: @comment.errors
    end

    private

    def denormalized_fields
      title = @commentable.title
      url   = url_for(controller: :posts, action: :show, id: @commentable, only_path: true)
      @commentable ? { commentable_title: title, commentable_url: url } : {}
    end

    def define_commentable
      commentable_klass = params[:comment][:commentable_type].constantize
      commentable_id    = params[:comment][:commentable_id]

      @commentable = commentable_klass.where(id: commentable_id).first
      return render(nothing: :true) unless @commentable
    end

    def comment_params
      params
        .require(:comment)
        .permit(:title, :contacts, :raw_content)
        .merge(user: current_user, view_token: comments_view_token)
        .merge(denormalized_fields)
    end

  end
end