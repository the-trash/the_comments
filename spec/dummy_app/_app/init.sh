#!/bin/bash
# chmod 744 script/app/*.sh

#######################################
# INCLUDE COMMON VARIABLES
#######################################
CURRENT_DIR=`dirname $0`
source $CURRENT_DIR/_vars.sh

#######################################
# SPHINX
#######################################
service_notification "SPHINX" "try to INIT"

(
  execute "$RAKE_DO ts:configure" &&
  service_notification "SPHINX" "configured"
) || (error_message "Sphinx can't be configated")

(
   execute "$RAKE_DO ts:index" &&
   service_notification "SPHINX" "indexed"
) || (error_message "Sphinx can't be indexed")
