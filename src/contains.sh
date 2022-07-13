#!/bin/bash

args=("android ios windows macos")

value=$1

if [[ " ${args[*]} " =~ " ${value} " ]]; then
    echo contains
fi
