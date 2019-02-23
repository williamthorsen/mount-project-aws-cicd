#!/usr/bin/env bash

# This script creates the code pipeline stack, or updates it if it already exists

CLOUDFORMATION_TEMPLATE='templates/codepipeline.yml'

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

source ../aws-functions.sh
source ../../compute-variables.sh

# Capture the mode that should be used put the stack: `create` or `update`
PUT_MODE=$(echoPutStackMode ${PROFILE} ${Region} ${CodePipelineStackName})

# TODO: REFACTOR: Use a function to generate ParameterKey,ParameterValue strings

./package.sh ${CLOUDFORMATION_TEMPLATE}

if [[ $? -ne 0 ]]
then
  exit 1
fi

# TODO: REFACTOR: This snippet is duplicated in `put-codebuild-project-stack.sh`
codecommitRepoExists ${PROFILE} ${Region} ${RepoName}
if [[ $? -eq 0 ]]
then
  echo "The CodeCommit repository '${RepoName}' exists and will be used for this project."
else
  ../codecommit/create-repository.sh
  if [[ $? -ne 0 ]]
  then
    exit 1
  fi
fi

TEMPLATE_BASENAME=$(echo ${CLOUDFORMATION_TEMPLATE} | awk -F '/' '{ print $NF }' | cut -d. -f1)

OUTPUT=$(aws cloudformation ${PUT_MODE}-stack \
  --profile ${PROFILE} \
  --region ${Region} \
  --stack-name ${CodePipelineStackName} \
  --template-body file://${TEMPLATE_BASENAME}--expanded.yml \
  --parameters \
    ParameterKey=BranchName,ParameterValue=${BranchName} \
    ParameterKey=CicdArtifactsBucketName,ParameterValue=${CicdArtifactsBucketName} \
    ParameterKey=CodeBuildEnvironmentImage,ParameterValue=${CodeBuildEnvironmentImage} \
    ParameterKey=CodeBuildProjectName,ParameterValue=${CodeBuildProjectName} \
    ParameterKey=CodeBuildServiceRoleName,ParameterValue=${CodeBuildServiceRoleName} \
    ParameterKey=CodeBuildServiceRolePolicyName,ParameterValue=${CodeBuildServiceRolePolicyName} \
    ParameterKey=CodePipelineName,ParameterValue=${CodePipelineName} \
    ParameterKey=CodePipelineServiceRoleName,ParameterValue=${CodePipelineServiceRoleName} \
    ParameterKey=DeploymentId,ParameterValue=${DeploymentId} \
    ParameterKey=EventsRuleRandomId,ParameterValue=${EventsRuleRandomId} \
    ParameterKey=ProjectBucketName,ParameterValue=${ProjectBucketName} \
    ParameterKey=ProjectDescription,ParameterValue="${ProjectDescription}" \
    ParameterKey=ProjectName,ParameterValue=${ProjectName} \
    ParameterKey=RepoName,ParameterValue=${RepoName} \
  --capabilities \
    CAPABILITY_AUTO_EXPAND \
    CAPABILITY_IAM \
    CAPABILITY_NAMED_IAM \
)

EXIT_STATUS=$?
echoPutStackOutput ${PUT_MODE} ${Region} ${EXIT_STATUS} ${OUTPUT}
