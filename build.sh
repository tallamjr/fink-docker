#!/bin/bash
# Copyright 2022 AstroLab Software
# Author: Julien Peloton
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -e
message_help="""
Build Dockerfile image for Fink\n\n
Usage:\n
    ./build.sh [--os] [--tag] [--build] [--run] [--deploy] [-h] \n\n

Specify the name of a folder with a Dockerfile with the option --os.\n
By default, the script will build the image (--build), with a tag (--tag).\n
Use --run to enter the container instead, or --deploy to deploy it in the DockerHub.\n
For the deployment, you need to have and defined.\n
Use -h to display this help.
"""

# Show help if no arguments is given
if [[ $1 == "" ]]; then
  echo -e $message_help
  exit 1
fi

# Grab the command line arguments
BUILD=true
RUN=false
DEPLOY=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h)
        echo -e $message_help
        exit
        ;;
    --os)
        if [[ $2 == "" ]]; then
          echo "$1 requires an argument" >&2
          exit 1
        fi
        OS_NAME="$2"
        shift 2
        ;;
    --os=*)
        OS_NAME="${1#*=}"
        shift 1
        ;;
    --tag)
        if [[ $2 == "" ]]; then
          echo "$1 requires an argument" >&2
          exit 1
        fi
        TAG="$2"
        shift 2
        ;;
    -t)
        if [[ $2 == "" ]]; then
          echo "$1 requires an argument" >&2
          exit 1
        fi
        TAG="$2"
        shift 2
        ;;
    --build)
        BUILD=true
        shift 1
        ;;
    --run)
        RUN=true
        BUILD=false
        shift 1
        ;;
    --deploy)
        DEPLOY=true
        BUILD=false
        shift 1
        ;;
  esac
done

if [[ $BUILD == true ]]; then
  if [[ $OS_NAME == "" ]]; then
    echo "You need to specify the name of a folder with a Dockerfile with the option --os."
    exit
  fi
  if [[ $TAG == "" ]]; then
    echo "You need to specify the tag with the option --tag."
    echo `docker build --help | grep "tag list"`
    exit
  fi
  echo "Building ${OS_NAME}"
  docker build -f ${OS_NAME}/Dockerfile -t ${TAG} .
elif [[ $RUN == true ]]; then
  if [[ $TAG == "" ]]; then
    echo "You need to specify the image name with the option --tag."
    exit
  fi
  docker run -t -i --rm ${TAG} bash
fi