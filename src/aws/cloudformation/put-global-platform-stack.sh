#!/usr/bin/env bash

# This script creates the region-wide resources used by all deployments of the platform stack
# of the same major version

CLOUDFORMATION_TEMPLATE='templates/global-platform.yml'

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

source ../aws-functions.sh
source ../../compute-variables.sh

if [[ ! ${Region} == ${AWS_GLOBAL_REGION} ]]
then
  echo "The global platform stack must be created in the ${AWS_GLOBAL_REGION} region" 1>&2
  exit 1
fi

if ! stackExists ${PROFILE} ${Region} ${RegionalPlatformStackName}; then
  ./put-regional-platform-stack.sh
  EXIT_CODE=$?
  if [[ $? -ne 0 ]]
  then
    echo "The global platform stack depends on regional platform stack '${RegionalPlatformStackName}' in ${Region}" 1>&2
    exit ${EXIT_CODE}
  fi
fi

# Capture the mode that should be used put the stack: `create` or `update`
PUT_MODE=$(echoPutStackMode ${PROFILE} ${Region} ${GlobalPlatformStackName})

./package.sh ${CLOUDFORMATION_TEMPLATE} ${Region}

if [[ $? -ne 0 ]]
then
  exit 1
fi

TEMPLATE_BASENAME=$(echo ${CLOUDFORMATION_TEMPLATE} | awk -F '/' '{ print $NF }' | cut -d. -f1)

OUTPUT=$(aws cloudformation ${PUT_MODE}-stack \
  --profile ${PROFILE} \
  --region ${Region} \
  --stack-name ${GlobalPlatformStackName} \
  --template-body file://${TEMPLATE_BASENAME}--expanded.yml \
  --parameters \
    ParameterKey=CodePipelineServiceRoleName,ParameterValue=${CodePipelineServiceRoleName} \
    ParameterKey=EcsTasksServiceRoleName,ParameterValue=${EcsTasksServiceRoleName} \
    ParameterKey=PlatformCommitHash,ParameterValue=${PlatformCommitHash} \
    ParameterKey=PlatformId,ParameterValue=${PlatformId} \
    ParameterKey=PlatformVersionLabel,ParameterValue=${PlatformVersionLabel} \
  --capabilities \
    CAPABILITY_IAM \
    CAPABILITY_NAMED_IAM \
)

EXIT_STATUS=$?
echoPutStackOutput ${PUT_MODE} ${Region} ${EXIT_STATUS} ${OUTPUT}
