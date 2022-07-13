#!/bin/bash

function build {
    echo "--- build unity $PLATFORM $1"
    unity-editor -quit -nographics -projectPath /app -executeMethod UActions.Bootstrap.Run -logfile - -buildTarget $PLATFORM -work $1
}
function build-url {
    URL="$1"
    WORK="$2"
    echo "--- build unity $PLATFORM $WORK"
    unity-editor -quit -nographics -projectPath /app -executeMethod UActions.Bootstrap.Run -logfile - -buildTarget $PLATFORM -work "$WORK" -url "$URL"
}

function run-lane {
    cd unity-build-scripts/fastlane
    echo "--- bundle install"
    bundle install
    export FL_UNITY_EXECUTE_METHOD=UActions.Bootstrap.Run
    #KEY=$PRODUCT_NAME-$PLATFORM
    #restore $KEY
    echo "--- running fastlane $PLATFORM $@"
    bundle exec fastlane $PLATFORM "$@"
    #cache $KEY
}
: '
function deploy {
    restore $PRODUCT_NAME
    build $1
    cache $PRODUCT_NAME
    run-lane $2
}
'
function restore {
    if [ "${ENABLE_CACHE:-false}" = false ]; then
        exit 0;
    fi

    tar -xvf /tmp/buildkite-$1-cache.tar || true
}

function cache {
    if [ "${ENABLE_CACHE:-false}" = false ]; then
        exit 0;
    fi
    
    tar -cf /tmp/buildkite-$1-cache.tar ./Library
}

function log {
    pwd
}

function args {
    arr=("$@")
    for i in "${arr[@]}";
    do
        echo "$i"
    done
}  

function init {
    echo do init
}

"$@"
# restore $PRODUCT_NAME-$PLATFORM
# cache $PRODUCT_NAME-$PLATFORM
