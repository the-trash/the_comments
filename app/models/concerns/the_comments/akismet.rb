module TheComments
  module AntiSpam
    module Akismet
      private

      def akismet_antispam_check request
        aksm_key  = ::TheComments.config.akismet_api_key
        aksm_blog = ::TheComments.config.akismet_blog

        if aksm_key.present? && aksm_blog.present?
          puts "CHECK FOR AKISMET"
        end

        # ref: request.try(:referer),
        # ua:  request.try(:user_agent),
        # email: email
        # subject: self.title,
        # body: ,
      end
    end
  end
end

