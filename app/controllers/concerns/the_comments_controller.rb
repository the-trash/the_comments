module TheCommentsController
  extend ActiveSupport::Concern

  included do
    
    def create
      commentable_klass = params[:comment][:commentable_type].constantize
      render text: comments_view_token and return
    end

    private

    def comments_view_token
      cookies[:comments_view_token] = { :value => SecureRandom.hex, :expires => 7.days.from_now } unless cookies[:comments_view_token]
      cookies[:comments_view_token]
    end

  end
end