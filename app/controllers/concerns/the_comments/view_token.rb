# Cookies and View token for spam protection
# include TheComments::ViewToken

module TheComments
  module ViewToken
    extend ActiveSupport::Concern

    def comments_cookies_token
      'JustTheComments-3.0-Cookies'
    end

    included { before_action :set_the_comments_cookies }

    def comments_view_token
      cookies[:comments_view_token]
    end

    private

    def set_the_comments_cookies
      cookies[:the_comment_cookies] = { value: comments_cookies_token, expires: 1.year.from_now }
      cookies[:comments_view_token] = { value: SecureRandom.hex, expires: 7.days.from_now } unless cookies[:comments_view_token]
    end
  end
end
