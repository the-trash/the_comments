module TheComments
  module AntiSpam
    module YandexCleanWeb
      private

      def yandex_cleanweb_antispam_check request
        comment = self
        ycw_key = ::TheComments.config.yandex_cleanweb_api_key

        if ycw_key.present?
          data = yandex_antispam_html_data(request).compact
          delayed_yandex_clean_web_check(comment, ycw_key, data)
        end
      end

      def yandex_antispam_html_data request
        email = self.try(:user).try(:email) || self.contacts
        email = nil unless email.to_s.match /@/

        {
          email: email,
          ip: request.try(:ip),
          body_html: self.content,
          login: self.try(:user).try(:login),
          name:  self.try(:user).try(:username) || self.contacts
        }
      end

      def delayed_yandex_clean_web_check comment, ycw_key, data
        ::YandexCleanweb.api_key = ycw_key

        if result = ::YandexCleanweb.spam?(data)
          ya_id = result.try(:[], :id)
          spam  = result.try(:[], :links).size > 0 ? :spam : :default

          comment.update_columns(
            yandex_cleanweb_id: ya_id,
            yandex_cleanweb_state: spam
          )

          if spam == :spam
            comment.to_spam
            comment.to_deleted
          end
        end
      end
    end
  end
end

