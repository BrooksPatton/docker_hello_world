# Prerequisites

You must have Docker installed and running

# To set up an project

Copy the config.example file to `config`. Set up the environment variables inside them.

Run the setup_project.sh file.

# Environment variables in the config file

1.  PROJECT_DIRECTORY `The directory that your project will be installed in. It must not exist or be empty`
1.  GIT_URI `Github or other git repository URI. User must have access to do a git clone`
1.  DOCKER_USERNAME `This username will be used to namespace the docker image you are creating`
1.  PROJECT_NAME `The name of the project. This will be used for the image name, as well as the container name`
1.  DOCKER_DB_NAME `The name given to the database container`
1.  DOCKER_DB_IMAGE `The docker hub image to pull. Example: mongo`
1.  DOCKER_DB_IMAGE_VERSION `The version of the database image to use`
1.  DOCKER_NETWORK_NAME `Name of the docker network to create`
1.  PROJECT_PORT `Port that your project runs on`
