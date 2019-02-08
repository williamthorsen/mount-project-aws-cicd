#!/usr/bin/env bash

if [[ ${#} -lt 1 ]]
then
  echo "Usage: ${0} TEMPLATE_FILE" >&2
  exit 1
fi

TEMPLATE=${1}

# Change to the directory of this script
cd $(dirname "$0")

source ../../compute-variables.sh

aws cloudformation validate-template \
  --profile=${PROFILE} \
  --region=${Region} \
  --template-body=file://${TEMPLATE}