#!/bin/bash

source ./bash_logger.sh

CSBL_LOG_TO_FILE=''

CSBL_SEVERITY_LEVEL=$CSBL_DEBUG
CSBL_TERMINAL_MESSAGE='__DATE__ __CSBL_ESC_CHAR____CSBL_STYLE____MESSAGE____CSBL_ESC_CHAR____CSBL_STYLE_CLEAR__'

csbl_log_emerg "test emerg"
csbl_log_alert "test alert"
csbl_log_crit "test crit"
csbl_log_err "test err"
csbl_log_warn "test warn"
csbl_log_notice "test notice"
csbl_log_info "test info"
csbl_log_debug "test debug"
csbl_log_success "test success"
