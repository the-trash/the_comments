module TheComments
  module Akismet
    private

    def akismet_antispam_check request_data
      comment   = self
      aksm_key  = ::TheComments.config.akismet_api_key
      aksm_blog = ::TheComments.config.akismet_blog

      if aksm_key.present? && aksm_blog.present?
        data = akismet_html_data(comment, request_data)
        akismet_check(comment, aksm_key, aksm_blog, data)
      end
    end

    def akismet_html_data comment, request_data
      author  = comment.try(:user).try(:username) || comment.contacts
      email   = self.try(:user).try(:email) || comment.contacts
      email   = nil unless email.to_s.match ::TheComments::EMAIL_REGEXP

      {
        comment_author: author,
        comment_author_email: email,
        comment_content: comment.content,

        user_ip:    request_data.try(:[], :ip),
        referrer:   request_data.try(:[], :referrer),
        user_agent: request_data.try(:[], :user_agent)
      }.compact
    end

    def akismet_check comment, aksm_key, aksm_blog, data
      vik    = ::TheViking::Akismet.new(api_key: aksm_key, blog: aksm_blog)
      result = vik.check_comment(data)

      if result[:spam]
        comment.update_columns(akismet_state: :spam)
      end
    end
  end
end

