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

verify_docker_is_running
