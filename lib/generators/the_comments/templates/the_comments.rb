# TheComments.config.param_name => value

TheComments.configure do |config|
  config.max_reply_depth = 3
  config.tolerance_time  = 5
  config.empty_inputs    = [:commentBody]
end