class ApplicationController < ActionController::Base
  include TheComments::ViewToken

  def comments_cookies_token
    'DefineYourTheCommentsCookies'
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
