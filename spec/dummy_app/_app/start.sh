#!/bin/bash
# chmod 744 script/app/*.sh

#######################################
# INCLUDE COMMON VARIABLES
#######################################
CURRENT_DIR=`dirname $0`
source $CURRENT_DIR/_vars.sh

#######################################
# WHENEVER / CRON
#######################################
# service_notification "Whenever" "try to update CRON"
# (execute "$RVM_DO whenever --update-crontab deploy_dummy_app --set environment=development") || (error_message "Whenever can't update CRON")

#######################################
# SPHINX
#######################################
# service_notification "SPHINX" "try to start"
# (execute "$RAKE_DO ts:start") || (error_message "Sphinx can't be started")

#######################################
# SIDEKIQ
#######################################
service_notification "SideKiq" "try to start"
(execute "$BUNDLE_EXEC bin/sidekiq -e $RAILS_ENV -d -C $RAILS_ROOT/config/sidekiq.yml") || (error_message "SidqKiq can't be started")

#######################################
# REDIS
#######################################
mkdir -p $RAILS_ROOT/redis_db

service_notification "Redis" "try to start"
(execute "redis-server $RAILS_ROOT/config/redis_6500.config") || (error_message "Redis can't be started")

#######################################
# DELAYED JOB
#######################################
# service_notification "Delayed Job" "try to start"
# (execute "$RVM_DO bin/delayed_job start -n 5") || (error_message "DelayedJob can't be started")

#######################################
# UNICORN
#######################################
# service_notification "Unicorn" "try to start"
# (execute "$BUNDLE_EXEC bin/unicorn -D -c $RAILS_ROOT/config/unicorn.rb -E development")  || (error_message "Unicorn can't be started")
