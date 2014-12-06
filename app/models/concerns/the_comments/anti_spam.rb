module TheComments
  module AntiSpam
    extend ActiveSupport::Concern

    included do
      include ::TheComments::AntiSpam::Akismet
      include ::TheComments::AntiSpam::YandexCleanweb
    end

    def antispam_services_check request
      cleanweb_antispam_check(request)
      akismet_antispam_check(request)
    end
  end
end
