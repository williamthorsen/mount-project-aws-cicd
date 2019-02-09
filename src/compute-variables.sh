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
SiteDomainName=${SiteDomainName:='www.example.com'}


# ----- Computed regional variables

# The S3 buckets below are referenced by the pipeline stack, but must be created independently
# if they do not already exist

# Name of the S3 bucket that hosts CodeBuild & CodePipeline artifacts for all projects in the region
# Here they are configured to share a bucket
CodeBuildArtifactBucketName="${CodeBuildArtifactBucketName:=cicd-artifacts-${AccountName}-${Region//-/}}"
CodePipelineArtifactBucketName="${CodePipelineArtifactBucketName:=cicd-artifacts-${AccountName}-${Region//-/}}"

# Name and ARN of the service role used by CodePipeline to call AWS services
CodePipelineServiceRoleName='codepipeline-service-role'
CodePipelineServiceRoleArn="arn:aws:iam::${AccountNumber}:role/${CodePipelineServiceRoleName}"

# Name of the S3 bucket that holds CloudFormation templates for the region
TemplateBucketName="${TemplateBucketName:=cf-templates-${AccountName}-${Region//-/}}"


# ----- Computed cluster variables for the project
# If the project specifies a cluster, it will be used; otherwise, the project gets its own cluster
EcsClusterName="${EcsClusterName:-${ProjectName}-cluster}"

# These resources are shared by the cluster, so there should be only one of each
BastionInstanceName="${BastionInstanceName:=${EcsClusterName}-bastion}"
BastionStackName="${BastionStackName:=${EcsClusterName}-bastion-stack}"
EcsStackName="${EcsStackName:=${EcsClusterName}-stack}"
KeyPairKeyName="${KeyPairKeyName:=${EcsClusterName}-${Region//-/}}"

# TODO: Build in support for per-project subnets
VpcDefaultSecurityGroupName="${VpcDefaultSecurityGroupName:=${EcsClusterName}-sg}"
VpcStackName="${VpcStackName:=${EcsClusterName}-vpc-stack}"

# ----- Other computed project variables

# --- CodeBuild project
CodeBuildProjectName="${CodeBuildProjectName:=${ProjectName}-codebuild-project}"
CodeBuildProjectStackName="${CodeBuildProjectStackName:=${CodeBuildProjectName}-stack}"

# --- CodePipeline pipeline
CodePipelineName="${ProjectName}-codepipeline"
CodePipelineStackName="${ProjectName}-codepipeline-stack"

# --- Events rule
EventsRuleRandomId=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-' | fold -w 24 | head -n 1)

# These values are used only when the rule is created independently of its parent stack
# (i.e., probably only during testing & development)
EventsRepoChangeRuleName="${CodePipelineName}-events-repo-change-rule"
EventsRepoChangeRuleStackName="${EventsRepoChangeRuleName}-stack"

# --- CodeCommit repo
RepoName="${RepoName:=${ProjectName}}"
RepoDescription="${RepoDescription:=${ProjectDescription}}"

# --- S3 site

# Replace `.` with `-` to make a valid stack name
SiteStackName="${SiteStackName:=${SiteDomainName//./-}-s3-site-stack}"

# The name of the S3 bucket that hosts the website files
BucketRandomSuffix=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 13 | head -n 1)
SiteBucketName="${SiteBucketName:=${SiteDomainName}-${BucketRandomSuffix}}"

# This stack name is ignored if the S3 bucket stack is created as a nested stack
SiteBucketStackName="${SiteBucketStackName:=${SiteBucketName//./-}-bucket-stack}"

# Name of the index and error documents for the site (for an SPA, these are typically the same)
SiteIndexDocument="${SiteIndexDocument:='index.html'}"
SiteErrorDocument="${SiteErrorDocument:=${SiteIndexDocument}}"

# --- CloudFront distribution

# This value is used only when the distribution is created independently of its parent stack
# (i.e., probably only during testing & development)
CloudfrontDistributionStackName="${CloudfrontDistributionStackName:=${ProjectName}-cdn-stack}"
