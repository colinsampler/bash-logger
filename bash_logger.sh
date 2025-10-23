#!/bin/bash

CSBL_SEV_LEVELS_NAMES=(EMERG ALERT CRIT ERR WANR NOTICE INFO DEBUG)

CSBL_EMERG=0
CSBL_ALERT=1
CSBL_CRIT=2
CSBL_ERR=3
CSBL_WARN=4
CSBL_NOTICE=5
CSBL_INFO=6
CSBL_DEBUG=7

CSBL_SEVERITY_LEVEL=$CSBL_EMERG

CSBL_ESC_CHAR=$'\033['
CSBL_STYLE_EMERG='7;31m' # most possible red - inverted;red
CSBL_STYLE_ALERT='4;31m' # less red than EMERG - underlined;red
CSBL_STYLE_CRIT='31m'    # just red text
CSBL_STYLE_ERR='91m'     # light-red
CSBL_STYLE_WARN='93m'    # light-yellow
CSBL_STYLE_NOTICE='96m'  # light-cyan
CSBL_STYLE_INFO='94m'    # light-blue
CSBL_STYLE_DEBUG='90m'   # dark-gray
CSBL_STYLE_CLEAR='0m'    # clear style

# sometimes it's worth to denote success
CSBL_STYLE_SUCCESS='92m'

CSBL_LOG_TO_TERMINAL='true'
CSBL_LOG_TO_FILE='true'
CSBL_LOG_FILEPATH="$(uuidgen).log"
CSBL_LOG_TO_WEBSERVICE='true'
CSBL_LOG_WEBSERVICE_URL='http://localhost:3000'

CSBL_TERMINAL_MESSAGE='__CSBL_ESC_CHAR____CSBL_STYLE____MESSAGE____CSBL_ESC_CHAR____CSBL_STYLE_CLEAR__'
CSBL_FILE_MESSAGE='__ISO_DATE__:__SEVERITY_LEVEL__:__MESSAGE__'
CSBL_WEBSERVICE_MESSAGE=''

CSBL_REPLACEMENTS="
__HOSTNAME__=my_hostname
__USERNAME__=my_username
__IP__=my_ip
"
# Special automatic placeholders
# __DATE__
# __ISO_DATE__
# __SECONDS__
# __SEVERITY_LEVEL__
# __MESSAGE_LENGTH__
# __HASH__ TODO:
# __SIGNATURE__ TODO:
# __CSBL_ESC_CHAR__
# __CSBL_STYLE__
# __MESSAGE__
# __CSBL_STYLE_CLEAR__

function fill_placeholders() {
  local sev_level_name="$1"
  local style="$2"
  local message="$3"
  local template="$4"

  local temp="$template"

  while IFS= read -r line; do
    [ -z "$line" ] && continue

    placeholder="${line%=*}"
    varname="${line#*=}"
    temp="$(echo "$temp" | sed -e "s#$placeholder#${!varname}#g")"
  done<<<"$CSBL_REPLACEMENTS"
  temp="$(echo "$temp" | sed \
    -e "s#__DATE__#$(date)#g" \
    -e "s#__ISO_DATE__#$(date +"%Y-%m-%dT%H:%M:%S%z")#g" \
    -e "s#__SECONDS__#$(date +"%s")#g" \
    -e "s#__SEVERITY_LEVEL__#$sev_level_name#g" \
    -e "s#__CSBL_ESC_CHAR__#$CSBL_ESC_CHAR#g" \
    -e "s#__CSBL_STYLE__#$style#g" \
    -e "s#__MESSAGE__#$message#g" \
    -e "s#__CSBL_STYLE_CLEAR__#$CSBL_STYLE_CLEAR#g" \
    -e "s#__[A-Z0-9_]+__##g"
  )"

  echo "$temp"| sed -e "s#__MESSAGE_LENGTH__#$(echo "$temp" | wc -c | xargs)#g"
}

function csbl_log_message {
  local sev_level="$1"
  local style="$2"
  local message="$3"

  local sev_level_name="${CSBL_SEV_LEMEVE_NAMES[$sev_level]}"

  if [[ -n "$CSBL_LOG_TO_TERMINAL" ]]; then
    echo "$(fill_placeholders "$sev_level_name" "$style" "$message" "$CSBL_TERMINAL_MESSAGE")" >&2
  fi
  if [[ -n "$CSBL_LOG_TO_FILE" ]]; then
    echo "$(fill_placeholders "$sev_level_name" "$style" "$message" "$CSBL_FILE_MESSAGE")" > "$CSBL_LOG_FILEPATH"
  fi
  # add sending logs to web service
}

function csbl_log_emerg {
  local message="$1"

  if [[ $CSBL_SEVERITY_LEVEL -ge $CSBL_EMERG ]]; then
    csbl_log_message "$CSBL_EMERG" "$CSBL_STYLE_EMERG" "$message"
  fi
}

function csbl_log_alert {
  local message="$1"

  if [[ $CSBL_SEVERITY_LEVEL -ge $CSBL_ALERT ]]; then
    csbl_log_message "$CSBL_ALERT" "$CSBL_STYLE_ALERT" "$message"
  fi
}

function csbl_log_crit {
  local message="$1"

  if [[ $CSBL_SEVERITY_LEVEL -ge $CSBL_CRIT ]]; then
    csbl_log_message "$CSBL_CRIT" "$CSBL_STYLE_CRIT" "$message"
  fi
}

function csbl_log_err {
  local message="$1"

  if [[ $CSBL_SEVERITY_LEVEL -ge $CSBL_ERR ]]; then
    csbl_log_message "$CSBL_ERR" "$CSBL_STYLE_ERR" "$message"
  fi
}

function csbl_log_warn {
  local message="$1"

  if [[ $CSBL_SEVERITY_LEVEL -ge $CSBL_WARN ]]; then
    csbl_log_message "$CSBL_WARN" "$CSBL_STYLE_WARN" "$message"
  fi
}

function csbl_log_notice {
  local message="$1"

  if [[ $CSBL_SEVERITY_LEVEL -ge $CSBL_NOTICE ]]; then
    csbl_log_message "$CSBL_NOTICE" "$CSBL_STYLE_NOTICE" "$message"
  fi
}

function csbl_log_info {
  local message="$1"

  if [[ $CSBL_SEVERITY_LEVEL -ge $CSBL_INFO ]]; then
    csbl_log_message "$CSBL_INFO" "$CSBL_STYLE_INFO" "$message"
  fi
}

function csbl_log_debug {
  local message="$1"

  if [[ $CSBL_SEVERITY_LEVEL -ge $CSBL_DEBUG ]]; then
    csbl_log_message "$CSBL_DEBUG" "$CSBL_STYLE_DEBUG" "$message"
  fi
}

# success is not limited to severity level
function csbl_log_success {
  local message="$1"

  csbl_log_message '100' "$CSBL_STYLE_SUCCESS" "$message"
}
