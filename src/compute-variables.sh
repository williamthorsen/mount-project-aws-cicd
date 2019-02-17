#!/usr/bin/env bash

# This script gets the values of regional and project-specific variables and uses them to generate
# default values for other variables.

# Change to the script's directory so that the variables files can be located by relative path,
# then switch back after the variables files have been sourced
THIS_SCRIPT_DIR=$(dirname $(realpath ${PWD}/${BASH_SOURCE[0]}))
cd ${THIS_SCRIPT_DIR} > /dev/null
source ./config/regional-variables.sh
source ./config/project-variables.sh
cd - > /dev/null

# ----- Dummy values for required variables
# TODO: Verify that all required values exist
ProjectDescription="${ProjectDescription:=${ProjectName}}"
ProjectVersion="${ProjectVersion:=0.0.1}"
ProjectMajorVersion=$(echo ${ProjectVersion} | head -n 1 | cut -d . -f 1)

BranchName=${BranchName:=master}

# TODO: FEATURE: Possibly add SiteUrl to allow for microservices hosted at the
#  same domain
SiteDomainName=${SiteDomainName:='www.example.com'}
# TODO: FEATURE: Support multiple domain names
# TODO: FEATURE: Support URLs instead of domain names

ProjectVersion="${ProjectVersion:=0.0.1}"
ProjectMajorVersion=$(echo ${ProjectVersion} | head -n 1 | cut -d . -f 1)

# Combine project, branch, and major version into a single value that can be used in resource names
ProjectBranchVersion="${ProjectName}-${BranchName}-v${ProjectMajorVersion}"

# ----- Defaults
ProtectAgainstTermination='false'

# Note that stack names generated below are ignored when the stacks are created as nested stacks
# Typically, they would be created independently of their parent only during testing & development

# ----- Computed regional variables

# The S3 buckets below are referenced by the pipeline stack, but must be created independently
# if they do not already exist

# Name of the S3 bucket that hosts CodeBuild & CodePipeline artifacts for all projects in the region
# Here they are configured to share a bucket
CodeBuildArtifactBucketName="${CodeBuildArtifactBucketName:=cicd-artifacts-${AccountName}-${Region//-/}}"
CodePipelineArtifactBucketName="${CodePipelineArtifactBucketName:=cicd-artifacts-${AccountName}-${Region//-/}}"
CodeBuildServiceRoleName="cb-service-role-${ProjectBranchVersion}-${Region//-/}"
CodeBuildServiceRolePolicyName="cb-service-role-policy-${ProjectBranchVersion}-${Region//-/}"

# Name and ARN of the service role used by CodePipeline to call AWS services
CodePipelineServiceRoleName='cp-service-role'
CodePipelineServiceRoleArn="arn:aws:iam::${AccountNumber}:role/${CodePipelineServiceRoleName}"

# Name of the S3 bucket that holds CloudFormation templates for the region
TemplateBucketName="${TemplateBucketName:=cf-templates-${AccountName}-${Region//-/}}"


# ----- Computed cluster variables for the project
# If the project specifies a cluster, it will be used; otherwise, the project gets its own cluster
EcsClusterName="${EcsClusterName:=${ProjectBranchVersion}-cluster}"

# These resources are shared by the cluster, so there should be only one of each
BastionInstanceName="${BastionInstanceName:=${EcsClusterName}-bastion}"
BastionStackName="${BastionStackName:=${BastionInstanceName}}"
EcsStackName="${EcsStackName:=${EcsClusterName}}"
KeyPairKeyName="${KeyPairKeyName:=${EcsClusterName}-${Region//-/}}"

# TODO: Build in support for per-project subnets
VpcName="${VpcName:=${ProjectBranchVersion}-vpc}"
VpcStackName="${VpcStackName:=${VpcName}}"
VpcDefaultSecurityGroupName="${VpcDefaultSecurityGroupName:=${VpcName}-sg}"

# ----- Other computed project variables

# --- CodeBuild project
CodeBuildProjectName="${CodeBuildProjectName:=${ProjectBranchVersion}-cb-project}"
CodeBuildProjectStackName="${CodeBuildProjectStackName:=${CodeBuildProjectName}}"
CodeBuildEnvironmentImage="${CodeBuildEnvironmentImage:='aws/codebuild/docker:18.09.0'}"

# --- CodePipeline pipeline
CodePipelineName="${CodePipelineName:=${ProjectBranchVersion}-cp}"
CodePipelineStackName="${CodePipelineStackName:=${CodePipelineName}}"

# --- Events rule
EventsRuleRandomId=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-' | fold -w 24 | head -n 1)

# These values are used only when the rule is created independently of its parent stack
# (i.e., probably only during testing & development)
EventsRepoChangeRuleName="${EventsRepoChangeRuleName:=${CodePipelineName}-events-repochangerule}"
EventsRepoChangeRuleStackName="${EventsRepoChangeRuleStackName:=${EventsRepoChangeRuleName}}"

# --- CodeCommit repo
RepoName="${RepoName:=${ProjectName}}"
RepoDescription="${RepoDescription:=${ProjectDescription}}"

# --- Website stacks

SiteStackName="${SiteStackName:=${ProjectBranchVersion}-site}"

# The name and stack of the S3 bucket that hosts the project's static files
ProjectBucketName="${ProjectBucketName:=${ProjectBranchVersion}-bucket}"
ProjectBucketStackName="${ProjectBucketStackName:=${ProjectBucketName}}"

# Name of the index and error documents for the site (for an SPA, these are typically the same)
SiteIndexDocument="${SiteIndexDocument:='index.html'}"
SiteErrorDocument="${SiteErrorDocument:=${SiteIndexDocument}}"

# --- CloudFront distribution
CloudfrontDistributionStackName="${CloudfrontDistributionStackName:=${ProjectBranchVersion}-cdn}"
