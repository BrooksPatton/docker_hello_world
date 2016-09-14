#!/bin/bash
ERROR_DOCKER_NOT_RUNNING=1
ERROR_CONFIG_MISSING=2
ERROR_CHANGING_DIRECTORY=3
ERROR_DIRECTORY_NOT_EMPTY=4
ERROR_CONFIG_NOT_SET=5
ERROR_SOURCE_CONFIG=6

CONFIG_LOCATION=./config

function verify_docker_is_running() {
  DOCKER_INFO_OUTPUT=$(docker info 2> /dev/null | grep "Containers:" | awk '{print $1}')

  if [ "$DOCKER_INFO_OUTPUT" == "Containers:" ]
    then
      print_to_screen "Docker is running"
    else
      print_to_screen "Docker is not running, exiting"
      exit "$ERROR_DOCKER_NOT_RUNNING"
  fi
}

function verify_config_exists() {
  if [ -f $CONFIG_LOCATION ]
  then
    print_to_screen "Config file found"
  else
    print_to_screen "Config file missing, exiting"
    exit "$ERROR_CONFIG_MISSING"
  fi
}

function source_config() {
  # shellcheck source=config
  # shellcheck disable=SC1091
  source $CONFIG_LOCATION || error_sourcing_config

  if [ -z "${PROJECT_DIRECTORY}" ]
  then
    print_to_screen "Project directory not set in config, exiting"
    exit "$ERROR_CONFIG_NOT_SET"
  fi

  print_to_screen "Loaded config file"
}

function error_sourcing_config() {
  print_to_screen "Error loading the config file, exiting"
  exit "$ERROR_SOURCE_CONFIG"
}

function verify_project_directory() {
  if [ -d "$PROJECT_DIRECTORY" ]
  then
    print_to_screen "$PROJECT_DIRECTORY exits, checking if it is empty"
    # shellcheck disable=SC2012
    LINES=$(ls -l $PROJECT_DIRECTORY | wc -l)
    if [ "$LINES" -ne 0 ]
    then
      print_to_screen "Directory is not empty, exiting"
      exit "$ERROR_DIRECTORY_NOT_EMPTY"
    fi
  else
    print_to_screen "Creating $PROJECT_DIRECTORY"
    mkdir "$PROJECT_DIRECTORY"
  fi

  print_to_screen "Changing directory to $PROJECT_DIRECTORY"
  cd "$PROJECT_DIRECTORY" || exit "$ERROR_CHANGING_DIRECTORY"
}

function print_new_section() {
  echo
  echo "$1"
}

function print_to_screen() {
  echo "...$1"
}

print_new_section "Checking if Docker is running"
verify_docker_is_running
print_new_section "Loading config file"
verify_config_exists
source_config
print_new_section "Creating project directory"
verify_project_directory
