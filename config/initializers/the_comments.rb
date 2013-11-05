# TheComments.config.param_name => value

TheComments.configure do |config|
  config.max_reply_depth     = 3                   # comments tree depth
  config.tolerance_time      = 10                  # sec - after this delay user can post a comment
  config.default_state       = :draft              # default state for comment
  config.default_owner_state = :published          # default state for comment for Moderator
  config.empty_inputs        = [:commentBody]      # array of spam trap fields
  config.default_title       = 'Undefined title'   # default commentable_title for denormalization
  config.template_engine     = :haml

  config.empty_trap_protection     = true
  config.tolerance_time_protection = true
end
