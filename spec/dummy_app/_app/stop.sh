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
# service_notification "Whenever" "try to clean CRON"
# (execute "$RVM_DO whenever --clear-crontab deploy_dummy_app") || (error_message "Whenever can't clean CRON")

#######################################
# SPHINX
#######################################
# service_notification "SPHINX" "try to stop"
# (execute "$RAKE_DO ts:stop") || (error_message "Sphinx can't be stopped")

#######################################
# SIDEKIQ
#######################################
service_notification "Sidekiq" "try to stop"
(execute "$BUNDLE_EXEC bin/sidekiqctl stop $RAILS_ROOT/tmp/pids/sidekiq.pid") || (error_message "SidqKiq can't be stoppped")

########################################
# REDIS
########################################
service_notification "Redis" "try to stop"
(execute "redis-cli -h localhost -p $REDIS_PORT shutdown") || (error_message "Redis can't be stopped")

#######################################
# DELAYED JOB
#######################################
# service_notification "Delayed Job" "try to stop"
# (execute "$RVM_DO bin/delayed_job stop") || (error_message "DelayedJob can't be stopped")

#######################################
# UNICORN
#######################################
# service_notification "Unicorn" "try to stop"
# (execute "kill -QUIT `cat $RAILS_ROOT/tmp/pids/unicorn.pid`") || (error_message "Unicorn can't be stopped")
