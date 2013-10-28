module TheComments
  def self.configure(&block)
    yield @config ||= TheComments::Configuration.new
  end

  def self.config
    @config
  end

  # Configuration class
  class Configuration
    include ActiveSupport::Configurable
    config_accessor :tolerance_time,
                    :empty_inputs,
                    :max_reply_depth,
                    :default_state,
                    :default_owner_state,
                    :default_title,
                    :empty_trap_protection,
                    :tolerance_time_protection

  end

  configure do |config|
    config.max_reply_depth     = 3
    config.tolerance_time      = 5
    config.default_state       = :draft
    config.default_owner_state = :published
    config.empty_inputs        = [:message]
    config.default_title       = 'Undefined title'

    config.empty_trap_protection     = true
    config.tolerance_time_protection = true
  end
end