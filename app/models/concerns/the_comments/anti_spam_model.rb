module TheComments
  module AntiSpamModel
    # include ::TheComments::AntiSpam::Akismet
    # include ::TheComments::AntiSpam::YandexCleanWeb

    def antispam_services_check request
      # yandex_cleanweb_antispam_check(request)
      # akismet_antispam_check(request)
    end
  end
end
