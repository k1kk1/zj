#!/bin/bash

SCHEDULE_JSON_PATH=$(pwd)/schedule.json
VERSION="1.0"


if [[ ! -f $SCHEDULE_JSON_PATH ]]; then
  echo "{\"items\":[{\"title\":\"test\",\"url\":\"https://hoge.zoom.us/j/1234567890?pwd=hogepass11Hoge\"}]}" | jq '.' > $SCHEDULE_JSON_PATH
fi

join() {
  local re="https?://([a-zA-Z_0-9]+)\.zoom\.us/j/([0-9]+)\?pwd=([a-zA-Z_0-9]+)"
  # TODO BASH_REMATCHでは(?: ... )といった記法が使えないため暫定的対応
  local reNoPass="https?://([a-zA-Z_0-9]+)\.zoom\.us/j/([0-9]+)"
  if [[ $1 =~ $re ]]; then
    open zoommtg:"//${BASH_REMATCH[1]}.zoom.us/join?confno=${BASH_REMATCH[2]}&pwd=${BASH_REMATCH[3]}"
  elif [[ $1 =~ $reNoPass ]]; then
    open zoommtg:"//${BASH_REMATCH[1]}.zoom.us/join?confno=${BASH_REMATCH[2]}"
  fi
  echo "Domain : ${BASH_REMATCH[1]}"
  echo "Join meeting - ID : ${BASH_REMATCH[2]}"
}

selectTitle () {
  local title=$(cat $SCHEDULE_JSON_PATH | jq -r '.items[].title' | fzf --preview "cat $SCHEDULE_JSON_PATH | jq -r '.items[] | select(.title == \""{}"\")'")
  local url=$(cat $SCHEDULE_JSON_PATH | jq -r ".items[] | select(.title == \""$title"\") | .url")
  join $url
}


usage() {
    echo "Usage: $(basename $0) [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help"
    echo "      --version"
    echo "      --config"
    echo
    exit 1
}

for OPT in "$@"
do
    case $OPT in
        -V | --version)
            echo $VERSION
            exit 1
            ;;
        --config)
            vi $SCHEDULE_JSON_PATH
            exit 1
            ;;
         -h | --help)
            usage
            ;;
          * )
            ;;
    esac
done

selectTitle
