module TheComments
  # Base functionality of Comments Controller
  #
  # class CommentsController < ApplicationController
  #   include TheComments::Controller
  # end
  module Controller
    extend ActiveSupport::Concern

    included do
      before_action -> { @errors = {} }, only: :create

      include TheComments::ViewToken
      include TheComments::ManageActions
      include TheComments::SpamProtectionTraps

      before_action :define_commentable, only: :create

      # Attention! We should not set TheComments cookie before create
      skip_before_action :set_the_comments_cookies, only: :create

      # Raise an errors
      before_action -> { return render(json: { errors: @errors }, status: 422) unless @errors.blank? }, only: :create
    end

    # PUBLIC METHOD
    def create
      @comment = @commentable.comments.new comment_params

      if @comment.save
        render template: view_context.comment_template('create.success')
      else
        render template: view_context.comment_template('create.errors'), status: 422
      end
    end

    private

    def define_commentable
      commentable_klass = params[:comment][:commentable_type].constantize
      commentable_id    = params[:comment][:commentable_id]

      @commentable = commentable_klass.find(commentable_id)

      unless @commentable
        k = t('the_comments.undefined_commentable')
        v = t('the_comments.undefined_commentable')
        @errors[ k ] = [ v ]
      end
    end

    def denormalized_fields
      {
        commentable_url:   @commentable.commentable_url,
        commentable_title: @commentable.commentable_title
      }
    end

    def request_data_for_comment
      {
        ip:         request.ip,
        referer:    CGI::unescape(request.referer || 'direct_visit'),
        user_agent: request.user_agent
      }
    end

    def comment_params
      params
        .require(:comment)
        .permit(:title, :contacts, :raw_content, :parent_id)
        .merge(denormalized_fields)
        .merge(request_data_for_comment)
        .merge(tolerance_time: params[:tolerance_time].to_i)
        .merge(user: current_user, view_token: comments_view_token)
    end

    def patch_comment_params
      params
        .require(:comment)
        .permit(:title, :contacts, :raw_content, :parent_id)
    end
  end
end
