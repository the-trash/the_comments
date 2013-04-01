# TheComments.config.param_name => value

TheComments.configure do |config|
  config.max_reply_depth     = 3
  config.tolerance_time      = 5
  config.default_state       = :draft
  config.default_owner_state = :published
  config.empty_inputs        = [:commentBody]
  config.default_title       = 'Undefined title'
end