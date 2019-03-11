#!/usr/bin/env bash

DELETE_IDENTITIFY_FILE=${1:-''}
if [[ $1 == '--delete' ]]; then
  DELETE_KEY_PAIR_PARAM='--delete'
else
  DELETE_KEY_PAIR_PARAM='--no-delete'
fi

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

source ../aws-functions.sh
source ../../compute-variables.sh

# Check whether services are running in the cluster
SERVICE_COUNT=$(aws ecs list-services \
  --profile ${Profile} \
  --region ${Region} \
  --cluster ${EcsClusterName} \
  --query 'serviceArns[*] | length(@)' \
  > /dev/null \
)
if [[ $? -eq 0 && ${SERVICE_COUNT} -ne 0 ]]; then
  echo "The stack cannot be deleted, because ${SERVICE_COUNT} services are running in the cluster.\nAborting." 1>&2
  exit 1
fi

OUTPUT=$(aws cloudformation delete-stack \
  --profile ${Profile} \
  --region ${Region} \
  --stack-name ${EcsClusterStackName} \
)

EXIT_STATUS=$?
echoPutStackOutput 'delete' ${Region} ${EXIT_STATUS} ${OUTPUT}

if [[ ${EXIT_STATUS} -eq 0 ]]
then
  ../ec2/delete-key-pair.sh ${PROFILE} ${Region} ${KeyPairKeyName} ${DELETE_KEY_PAIR_PARAM}
fi
