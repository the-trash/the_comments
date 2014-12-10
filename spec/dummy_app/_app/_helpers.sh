#!/bin/bash
# chmod 744 script/app/*.sh

#######################################
# STYLE AND COLOR VARS
#######################################
BLACK='tput setaf 0'
RED='tput setaf 1'
GREEN='tput setaf 2'
YELLOW='tput setaf 3'
BLUE='tput setaf 4'
MAGENTA='tput setaf 5'
CYAN='tput setaf 6'
WHITE='tput setaf 7'

STYLE_OFF='tput sgr0'

function error_message {
  echo `$RED`$1`$STYLE_OFF`
}

function service_notification {
  echo `$GREEN`$1`$STYLE_OFF`": "`$YELLOW`$2`$STYLE_OFF`
}

function execute {
  echo `$CYAN`$1`$STYLE_OFF`
  eval $1
}
