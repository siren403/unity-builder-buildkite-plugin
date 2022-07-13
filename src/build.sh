#!/usr/bin/env bash

#set -ex
set -e

echo "--- image build $UNITY_VERSION $PLATFORM"
# UNITY_VERSION=2021.3.3f1
GAME_CI_VERSION=1.0.1 # https://github.com/game-ci/docker/releases
MY_USERNAME=qkrsogusl3
COMPOSE_FILE=./unity-build-scripts/docker-compose.yml
COMPOSE_ENV_FILE=./unity-build-scripts/.env
COMPOSE_ENV_FILE_SAMPLE=./unity-build-scripts/.env.sample

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
: '
  docker-compose -f ${COMPOSE_FILE} run \
      --entrypoint /bin/bash \
      --rm \
      -v $(echo $(pwd):/app) \
      -v /tmp:/tmp \
      unity

  if [ -n $UNITY_PROJECT_ROOT ]; then
    UNITY_PROJECT_DIR="$(pwd)/$UNITY_PROJECT_ROOT";
  else
    UNITY_PROJECT_DIR="$(pwd)"
  fi
  
  echo $UNITY_PROJECT_DIR
'
if [ "$DEBUG" = true ]; then
  docker-compose -f ${COMPOSE_FILE} run \
      -itd --entrypoint /bin/bash \
      -v $(echo $(pwd):/app) \
      unity
elif [ -n "$SYNC" ]; then
  echo "compose run sync $args"
  docker-compose -f ${COMPOSE_FILE} run \
      --rm \
      -v $(echo "$SYNC"):/app \
      -v $(echo $(pwd)/Build):/app/Build \
      unity $(echo ${args})
else
  echo "compose run $args"
  docker-compose -f ${COMPOSE_FILE} run \
      --rm \
      -v $(echo $(pwd):/app) \
      unity $(echo ${args})
fi

# uncomment the following to publish the built images to docker hub
#  docker push ${IMAGE_TO_PUBLISH}
done
