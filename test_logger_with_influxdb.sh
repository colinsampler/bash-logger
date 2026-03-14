#!/bin/bash

source ./bash_logger.sh

CSBL_SEVERITY_LEVEL=$CSBL_WARN
CSBL_LOG_WEBSERVICE_URL='http://0.0.0.0:8181/api/v3/write_lp?db=testdb&precision=s'
CSBL_LOG_WEBSERVICE_TOKEN='apiv3_QFR-12-IFCNLDE4jqVs3GLMJx1CvwHZ_oopn2SUWf-O4KDq3WVnRyidMapJ8s1K8n_cgh0_RzbZB84qAoJeCgg'

function file_exists {
  filepath="$1"

  if [[ ! -f "$filepath" ]]; then
    csbl_log_warn "temperature,sensor=office value=25.6"
    echo "File does not exist"
    return 1
  fi
  echo "File exists"
  return 0
}

file_exists 'test.txt'

