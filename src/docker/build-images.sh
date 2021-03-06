#!/usr/bin/env bash

# This script builds and tags the project's Docker images

if [[ ! $1 == '--force' ]]; then
  test -z "$(git status --porcelain)"
  if [[ $? -ne 0 ]]; then
    echo -e "Please commit or stash your changes before building or use --force.\nAborting build" 1>&2
    exit 1
  fi
fi

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

source ../aws/aws-functions.sh
source ../compute-variables.sh

# PROJECT_DIR is set when the aws-cicd image is built. See `build.sh`
# TODO: Allow this to be overridden
PROJECT_DIR=${PROJECT_DIR:-'/var/project'}
cd "${PROJECT_DIR}"

echo "Docker version label: ${ProjectVersionLabel}"

for IMAGE_NAME in ${EcrRepoNames}; do

  SHORT_TAG=${DeploymentId}/${IMAGE_NAME}:${ProjectVersionLabel}
  LONG_TAG=${AccountNumber}.dkr.ecr.${Region}.amazonaws.com/${SHORT_TAG}

  DOCKERFILE=${IMAGE_NAME}.Dockerfile
  DOCKERFILE_PATH=${PROJECT_DIR}/${DOCKERFILE}

  if [[ ! -f "${DOCKERFILE_PATH}" ]]; then
    echo "The build could not proceed. ${DOCKERFILE_PATH} WAS NOT FOUND" 1>&2
    exit 1
  fi

  echo "Building ${SHORT_TAG}"

  docker build \
    --build-arg IMAGE_NAME=${IMAGE_NAME} \
    --build-arg IMAGE_VERSION_LABEL=${ProjectVersionLabel} \
    --build-arg VERSION_STAGE=${ProjectVersionStage} \
    --build-arg SITE_DOMAIN_NAME=${SiteDomainName} \
    --file ${DOCKERFILE_PATH} \
    --tag ${LONG_TAG} \
    ${PROJECT_DIR}

  if [[ $? -ne 0 ]]; then
    echo "Docker failed to build ${SHORT_TAG}" 1>&2
    exit 1
  fi
done
