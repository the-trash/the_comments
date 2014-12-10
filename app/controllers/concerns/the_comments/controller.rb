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

      include ::TheComments::ViewToken
      include ::TheComments::SpamTraps
      include ::TheComments::ManageActions

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
        comment_after_create_actions
        render template: view_context.comment_template('create.success')
      else
        render template: view_context.comment_template('create.errors'), status: 422
      end
    end

    private

    def comment_after_create_actions
      # Something happened. They should know
      # ::Async::
      @comment.send_notifications_to_subscribers

      # app/models/concerns/the_comments/anti_spam.rb
      # Check with anti-spam services
      # ::Async::
      @comment.antispam_services_check(request)

      # Add subscriber by Email or UserId
      # app/models/concerns/the_comments/comment_subscription.rb
      @comment.add_subscriber(current_user)
    end

    def define_commentable
      commentable_id    = params[:comment][:commentable_id]
      commentable_klass = params[:comment][:commentable_type].constantize

      # Will raise an exception in wrong case
      @commentable = commentable_klass.find(commentable_id)
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
        user_agent: request.user_agent,
        referer:    CGI::unescape(request.referer || 'direct_visit')
      }
    end

    def comment_params
      params
        .require(:comment)
        .permit(
          :title,
          :contacts,
          :raw_content,
          :parent_id,
          :subscribe_to_thread_flag
        )
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
