#!/bin/bash
ERROR_DOCKER_NOT_RUNNING=1
ERROR_CONFIG_MISSING=2
ERROR_CHANGING_DIRECTORY=3
ERROR_DIRECTORY_NOT_EMPTY=4
ERROR_CONFIG_NOT_SET=5
ERROR_SOURCE_CONFIG=6
ERROR_GIT_PULL=7
ERROR_DOCKER_CREATE_NETWORK=8

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
  print_to_screen "Loaded config file"
}

function verify_env_variables() {
  print_to_screen "Checking environment variables"

  if [ -z "${PROJECT_DIRECTORY}" ]
  then
    print_to_screen "Project directory not set in config, exiting"
    exit "$ERROR_CONFIG_NOT_SET"
  fi

  if [ -z "${GIT_URI}" ]
  then
    print_to_screen "Git URI not set in config, exiting"
    exit "$ERROR_CONFIG_NOT_SET"
  fi

  if [ -z "${DOCKER_USERNAME}" ]
  then
    print_to_screen "Docker username not set in config, exiting"
    exit "$ERROR_CONFIG_NOT_SET"
  fi

  if [ -z "${PROJECT_NAME}" ]
  then
    print_to_screen "Project name not set in config, exiting"
    exit "$ERROR_CONFIG_NOT_SET"
  fi

  if [ -z "${DOCKER_DB_NAME}" ]
  then
    print_to_screen "Docker database name not set in config, exiting"
    exit "$ERROR_CONFIG_NOT_SET"
  fi

  if [ -z "${DOCKER_DB_IMAGE}" ]
  then
    print_to_screen "Docker database image not set in config, exiting"
    exit "$ERROR_CONFIG_NOT_SET"
  fi

  if [ -z "${DOCKER_DB_IMAGE_VERSION}" ]
  then
    print_to_screen "Docker database image version not set in config, exiting"
    exit "$ERROR_CONFIG_NOT_SET"
  fi

  if [ -z "${DOCKER_NETWORK_NAME}" ]
  then
    print_to_screen "Docker network name not set in config, exiting"
    exit "$ERROR_CONFIG_NOT_SET"
  fi

  print_to_screen "Environment variables all set"
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
    LINES=$(ls -l "$PROJECT_DIRECTORY" | wc -l)
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
  echo "==============="
}

function print_to_screen() {
  echo "...$1"
}

function pull_down_code() {
  git clone "$GIT_URI" . || problem_with_git_pull
}

function problem_with_git_pull() {
  print_to_screen "Problem pulling down repository"
  exit "$ERROR_GIT_PULL"
}

function create_project_image() {
  docker build -t "$DOCKER_USERNAME"/"$PROJECT_NAME" .
}

function create_docker_network() {
  docker network create "$DOCKER_NETWORK_NAME" || problem_creating_network
}

function problem_creating_network() {
  print_to_screen "Problem creating docker network"
  exit "$ERROR_DOCKER_CREATE_NETWORK"
}

print_new_section "Checking if Docker is running"
verify_docker_is_running

print_new_section "Loading config file"
verify_config_exists
source_config

print_new_section "Verifying ENV Variables set in config file"
verify_env_variables

print_new_section "Creating project directory"
verify_project_directory

print_new_section "Pulling down code"
pull_down_code

print_new_section "Creating project docker image"
create_project_image

print_new_section "Creating Docker network"
create_docker_network
