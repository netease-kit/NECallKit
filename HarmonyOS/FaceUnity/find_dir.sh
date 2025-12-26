#!/bin/bash

script_path=$(readlink -f "$0")
script_dir=$(dirname "$script_path")

root_dir=${script_dir}/../oh_modules/.ohpm
target_folder="wrapper"

result=$(find "$root_dir" -type d -name "$target_folder")
echo ${result}