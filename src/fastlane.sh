#!/bin/bash

# fastlane
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# rbenv
eval "$(rbenv init -)"

# pyenv
eval "$(pyenv init --path)"

echo "--- cocoapods checking"
cd $XCODE_ROOT && if [ -f "./Podfile" ]; then pod install; fi
cd $WORK_DIR/$UNITY_PROJECT_ROOT

cd "./unity-build-scripts/fastlane/"

echo "--- bundle install"
bundle install

function run_lane {
  LANE="$(perl -pe 's/(\S+):(\S+)//g' <<< $@)"
  echo "--- running fastlane $PLATFORM $LANE"
  bundle exec fastlane $PLATFORM "$@"
}
