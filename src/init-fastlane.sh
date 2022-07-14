#!/bin/bash

# fastlane
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# rbenv
eval "$(rbenv init -)"

# pyenv
eval "$(pyenv init --path)"

echo "initialized fastlane"

#echo "--- bundle install"
#bundle install

