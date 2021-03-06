#!/usr/bin/env bash

# This script deletes the HTTP redirection stack created by `put-http-redirection-bucket-stack.sh`

if [[ $# -ne 1 ]]
then
  echo "Usage: $0 STACK_NAME" >&2
  exit 1
fi

STACK_NAME=$1

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

source ../aws-functions.sh
source ../../compute-variables.sh

if ! stackExists ${Profile} ${Region} ${STACK_NAME}; then
  echo "No stack named '${STACK_NAME}' was found in the '${Region}' region" 1>&2
  exit 1
fi

# The bucket has the same name as the domain name being redirected
BUCKET_NAME=$(echoStackParameterValue ${Profile} ${Region} ${STACK_NAME} 'SourceDomainName')

if [[ -z ${BUCKET_NAME} ]]; then
  echo -e "No S3 bucket could be found for the '${STACK_NAME}' stack.\nAborting." 1>&2
  exit 1
fi

echo "Bucket name: ${BUCKET_NAME}"

# If the bucket exists, empty it; otherwise, CloudFormation won't be able to delete it
../s3/empty-bucket.sh ${BUCKET_NAME} 'redirection bucket'
exitOnError $? "Deletion of the '${STACK_NAME}' stack has been aborted."

helpers/delete-stack.sh ${STACK_NAME} "$@"
exitOnError $?
