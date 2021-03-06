#!/usr/bin/env bash

# This script connects via a jump host to the nth-index cluster instance of the ECS stack.
# Example: To connect to the first container instance:
#
#   ```
#   ssh-into-ecs-instance.sh 0
#   ```

if [[ $# -gt 1 ]]
then
  echo "Usage: $0 INSTANCE_INDEX" 1>&2
  exit 1
fi

INSTANCE_INDEX=${1:-0}

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

helpers/connect-via-jump-host-to-ecs-instance.sh login ${INSTANCE_INDEX}
