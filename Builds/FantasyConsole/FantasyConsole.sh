#!/bin/sh
printf '\033c\033]0;%s\a' FantasyConsole
base_path="$(dirname "$(realpath "$0")")"
"$base_path/FantasyConsole" "$@"
