#!/bin/bash

source ./bash_logger.sh

CSBL_SEVERITY_LEVEL=$CSBL_WARN

function file_exists {
  filepath="$1"

  if [[ ! -f "$filepath" ]]; then
    csbl_log_warn "File does not exist"
    echo "File does not exist"
    return 1
  fi
  echo "File exists"
  return 0
}

file_exists 'test.txt'

