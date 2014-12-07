module TheComments
  module AntiSpam
    module Akismet
      private

      def akismet_antispam_check request
        comment   = self
        aksm_key  = ::TheComments.config.akismet_api_key
        aksm_blog = ::TheComments.config.akismet_blog

        if aksm_key.present? && aksm_blog.present?
          data = akismet_html_data(comment, request)
          akismet_check(comment, aksm_key, aksm_blog, data)
        end
      end

      def akismet_html_data comment, request
        author  = comment.try(:user).try(:username) || comment.contacts
        email   = self.try(:user).try(:email) || comment.contacts
        email   = nil unless email.to_s.match /@/

        {
          comment_author: author,
          user_ip: request.try(:ip),
          comment_author_email: email,
          comment_content: comment.content,
          referrer:  request.try(:referrer),
          user_agent: request.try(:user_agent)
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
end

