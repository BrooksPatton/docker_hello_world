#!/bin/bash
ERROR_DOCKER_NOT_RUNNING=1
ERROR_CONFIG_MISSING=2
ERROR_CHANGING_DIRECTORY=3
ERROR_DIRECTORY_NOT_EMPTY=4
ERROR_CONFIG_NOT_SET=5

CONFIG_LOCATION=./config

function verify_docker_is_running() {
  DOCKER_INFO_OUTPUT=$(docker info 2> /dev/null | grep "Containers:" | awk '{print $1}')

  if [ "$DOCKER_INFO_OUTPUT" == "Containers:" ]
    then
      echo "Docker is running, so we can continue"
    else
      echo "Docker is not running, exiting"
      exit "$ERROR_DOCKER_NOT_RUNNING"
  fi
}

function verify_config_exists() {
  if [ -f $CONFIG_LOCATION ]
  then
    echo "config file exists!"
  else
    echo "Config file missing, exiting"
    exit "$ERROR_CONFIG_MISSING"
  fi
}

function source_config() {
# shellcheck source=config
# shellcheck disable=SC1091
  source $CONFIG_LOCATION
  EXIT_CODE=$?

  check_exit_code $EXIT_CODE 'loading config file'

  if [ -z "${PROJECT_DIRECTORY}" ]
  then
    echo "Project directory environment variable not set, exiting"
    exit "$ERROR_CONFIG_NOT_SET"
  fi
}

function check_exit_code() {
  EXIT_CODE=$1
  MESSAGE=$2

  if [ "$EXIT_CODE" -ne 0 ]
  then
    echo "Error $MESSAGE, exiting"
    exit "$EXIT_CODE"
  else
    echo "$MESSAGE"
  fi
}

function verify_project_directory() {
  if [ -d "$PROJECT_DIRECTORY" ]
  then
    echo "$PROJECT_DIRECTORY exits, checking if it is empty"
    cd "$PROJECT_DIRECTORY" || exit "$ERROR_CHANGING_DIRECTORY"
    # shellcheck disable=SC2012
    LINES=$(ls -l | wc -l)
    if [ "$LINES" -ne 0 ]
    then
      echo "Directory is not empty, exiting"
      exit "$ERROR_DIRECTORY_NOT_EMPTY"
    fi
  else
    echo "Creating $PROJECT_DIRECTORY"
    mkdir "$PROJECT_DIRECTORY"
  fi
}

verify_docker_is_running
verify_config_exists
source_config
verify_project_directory
