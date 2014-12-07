module TheComments
  module AntiSpam
    extend ActiveSupport::Concern

    included do
      include ::TheComments::AntiSpam::Akismet
      include ::TheComments::AntiSpam::YandexCleanweb
    end

    # Move this to background with SideKiq or DelayedJob
    def antispam_services_check request
      cleanweb_antispam_check(request)
      akismet_antispam_check(request)
      action_after_spam_checking
    end

    private

    # Reload this method into your App
    # Do something if spam services return true
    def action_after_spam_checking
      comment = self

      spam_flag_1 = comment.akismet_state.to_s == 'spam'
      spam_flag_2 = comment.yandex_cleanweb_state.to_s == 'spam'

      # for example mark it as SPAM
      # and move to DELETED comments
      #
      if spam_flag_1 || spam_flag_2
        comment.mark_as_spam
        comment.to_deleted
      end
    end
  end
end
