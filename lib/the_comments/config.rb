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
    config_accessor :tolerance_time, :empty_inputs, :max_reply_depth, :default_state
  end

  configure do |config|
    config.max_reply_depth = 3
    config.tolerance_time  = 5
    config.empty_inputs    = [:message]
    config.default_state   = :draft
  end
end