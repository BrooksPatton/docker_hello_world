#!/bin/bash

CONFIG_LOCATION=./config

function verify_docker_is_running() {
  DOCKER_INFO_OUTPUT=$(docker info 2> /dev/null | grep "Containers:" | awk '{print $1}')

  if [ "$DOCKER_INFO_OUTPUT" == "Containers:" ]
    then
      echo "Docker is running, so we can continue"
    else
      echo "Docker is not running, exiting"
      exit 1
  fi
}

function verify_config_exists() {
  if [ -f $CONFIG_LOCATION ]
  then
    echo "config file exists!"
  else
    echo "Config file missing, exiting"
    exit 2
  fi
}

function source_config() {
# shellcheck source=config
# shellcheck disable=SC1091
  source $CONFIG_LOCATION
  EXIT_CODE=$?

  check_exit_code $EXIT_CODE 'loading config file'
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

verify_docker_is_running
verify_config_exists
source_config
