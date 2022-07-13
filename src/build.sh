#!/usr/bin/env bash

#set -ex
set -e

echo "--- image build $UNITY_VERSION $PLATFORM"

PLUGIN_DIR="$UNITY_BUILDER_DIR"
PROJECT_DIR="$UNITY_BUILDER_PROJECT_DIR"

# UNITY_VERSION=2021.3.3f1
GAME_CI_VERSION=1.0.1 # https://github.com/game-ci/docker/releases
MY_USERNAME=qkrsogusl3
COMPOSE_FILE="$PLUGIN_DIR/src/docker-compose.yml"
COMPOSE_ENV_FILE="$PLUGIN_DIR/src/.env"
COMPOSE_ENV_FILE_SAMPLE="$PLUGIN_DIR/src/.env.sample"

if [ -z "$UNITY_VERSION" ] || [ -z "$UNITY_LICENSE" ] || [ -z "$PLATFORM" ]; then 
    echo "not found env"
    echo UNITY_VERSION=$UNITY_VERSION;
    echo UNITY_LICENSE=$UNITY_LICENSE;
    echo PLATFORM=$PLATFORM;
    exit 1;
fi

if [ ! -f $COMPOSE_ENV_FILE ]; then
    #touch $COMPOSE_ENV_FILE;
    cp $COMPOSE_ENV_FILE_SAMPLE $COMPOSE_ENV_FILE
fi

# don't hesitate to remove unused components from this list
declare -a components=("$PLATFORM")

for component in "${components[@]}"
do
  export GAME_CI_UNITY_EDITOR_IMAGE=unityci/editor:ubuntu-${UNITY_VERSION}-${component}-${GAME_CI_VERSION}
  export IMAGE_TO_PUBLISH=${MY_USERNAME}/editor:ubuntu-${UNITY_VERSION}-${component}-${GAME_CI_VERSION}
  export PLATFORM=${component}

  args=("$@")

  if [[ " ${args[*]} " =~ "-rmi" ]]; then
    args="${args[@]/-rmi}";
    docker rmi $(docker images -q $IMAGE_TO_PUBLISH) || true;
  fi
  
  if [ -z $(docker images -q $IMAGE_TO_PUBLISH) ]; then
    docker-compose -f ${COMPOSE_FILE} build;
  fi
    
  if [ "$DEBUG" = true ]; then
    docker-compose -f ${COMPOSE_FILE} run \
      -itd --entrypoint /bin/bash \
      -v $(echo $PROJECT_DIR:/app) \
      unity
  elif [ -n "$SYNC" ]; then
    echo "compose run sync $args"
    docker-compose -f ${COMPOSE_FILE} run \
      --rm \
      -v $(echo "$SYNC"):/app \
      -v $(echo $PROJECT_DIR/Build):/app/Build \
      unity $(echo ${args})
  else
    echo "compose run $args"
    docker-compose -f ${COMPOSE_FILE} run \
      --rm \
      -v $(echo $PROJECT_DIR:/app) \
      unity $(echo ${args})
  fi

# uncomment the following to publish the built images to docker hub
#  docker push ${IMAGE_TO_PUBLISH}
done
