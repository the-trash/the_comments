module TheComments
  # class CommentSubscriptionsController < ApplicationController
  #   include TheComments::SubscriptionsController
  # end
  module SubscriptionsController
    extend ActiveSupport::Concern

    included do
      before_action :define_subscriptions_params, only: %w[ unsubscribe_comment ]
    end

    def unsubscribe_comment
      email_unsubscribe_comment if @type == 'guest'
      user_unsubscribe_comment  if @type == 'user'

      render template: view_context.comment_template('subscriptions/info')
    end

    private

    def define_subscriptions_params
      @type       = params[:type].to_s.to_the_decrypted.downcase
      @comment_id = params[:comment_id].to_s.to_the_decrypted
      @user_id    = @email = params[:id].to_s.to_the_decrypted

      @comment = ::Comment.find @comment_id
      @comments_id = @comment.commentable.comments.pluck(:id)
    end

    def email_unsubscribe_comment
      subs = @comment.active_subscriptions.where(email: @email)
      @subs_count = subs.count

      subs.update_all(state: :unactive)
      define_info_params_for_email
    end

    def user_unsubscribe_comment
      subs = @comment.active_subscriptions.where(user_id: @user_id)
      @subs_count = subs.count

      subs.update_all(state: :unactive)
      define_info_params_for_user
    end

    def define_info_params_for_email
      @total_active_subscriptions       = ::CommentSubscription.where(email: @email, state: :active).count
      @commentable_active_subscriptions = ::CommentSubscription.where(email: @email, state: :active, comment_id: @comments_id).count
    end

    def define_info_params_for_user
      @user = ::User.find @user_id
      @total_active_subscriptions       = ::CommentSubscription.where(user_id: @user_id, state: :active).count
      @commentable_active_subscriptions = ::CommentSubscription.where(user_id: @user_id, state: :active, comment_id: @comments_id).count
    end
  end
end
