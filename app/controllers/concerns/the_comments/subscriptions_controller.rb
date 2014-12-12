module TheComments
  # class CommentSubscriptionsController < ApplicationController
  #   include TheComments::SubscriptionsController
  # end
  module SubscriptionsController
    extend ActiveSupport::Concern

    included do
      before_action do
        @type = params[:type].to_s.downcase
        @user_id = @email = params[:id].to_s.to_the_decrypted
      end
    end

    def unsubscribe_comment
      user_unsubscribe_comment  if @type == 'user'
      email_unsubscribe_comment if @type == 'guest'
      render text: "Wrong type", status: 404
    end

    def user_unsubscribe_comment
      user = ::User.find(@user_id)
      subs = user.comment_subscriptions
      # subs.update_column(state: :unactive)

      return render text: "User Id #{ @user_id }"
    end

    def email_unsubscribe_comment
      return render text: "Email #{ @email }"
    end
  end
end
