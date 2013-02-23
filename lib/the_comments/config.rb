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
    config_accessor :tolerance_time, :empty_inputs, :max_reply_depth
  end

  configure do |config|
    config.max_reply_depth = 3
    config.tolerance_time  = 15
    config.empty_inputs    = [:message]
  end
end