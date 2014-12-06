module TheComments
  module AntiSpam
    module YandexCleanweb
      private

      def cleanweb_antispam_check request
        comment = self
        ycw_key = ::TheComments.config.yandex_cleanweb_api_key

        if ycw_key.present?
          data = cleanweb_html_data(request).compact
          delayed_cleanweb_check(comment, ycw_key, data)
        end
      end

      def cleanweb_html_data request
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

      def delayed_cleanweb_check comment, ycw_key, data
        ::YandexCleanweb.api_key = ycw_key

        if result = ::YandexCleanweb.spam?(data)
          ya_id = result.try(:[], :id)
          comment.update_columns(
            yandex_cleanweb_id: ya_id,
            yandex_cleanweb_state: :spam
          )
        end
      end
    end
  end
end

