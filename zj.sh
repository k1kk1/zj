#!/bin/bash

SCHEDULE_JSON_PATH=$(pwd)/schedule.json
VERSION="1.0"

re="https?://([a-zA-Z_0-9]+)\.zoom\.us/j/([0-9]+)\?pwd=([a-zA-Z_0-9]+)"
reNoPass="https?://([a-zA-Z_0-9]+)\.zoom\.us/j/([0-9]+)"

if [[ ! -f $SCHEDULE_JSON_PATH ]]; then
  echo "{\"items\":[{\"title\":\"test\",\"url\":\"https://hoge.zoom.us/j/1234567890?pwd=hogepass11Hoge\"}]}" | jq '.' > $SCHEDULE_JSON_PATH
fi
join() {
  # TODO BASH_REMATCHでは(?: ... )といった記法が使えないため暫定的対応
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
    echo "  -a  --add \"title,url\""
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
        -a | --add)
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
              echo "$(basename $0): option requires an argument -- $1" 1>&2
              echo "  example) $(basename $0) --add \"title,url\"" 1>&2
              exit 1
            else
              addRe="([a-zA-Z_0-9-]+),(https?://([a-zA-Z_0-9]+)\.zoom\.us/j/([0-9]+))"
              echo $2
              if [[ $2 =~ $addRe ]]; then
                echo Test
                title=${BASH_REMATCH[1]}
                url=${BASH_REMATCH[2]}
                if [[ $url =~ $re ]] || [[ $url =~ $reNopass ]]; then
                  echo "Add schedule"
                  echo "  Title : $title"
                  echo "  URL   : $url"
                  tmp=$(pwd)/tmp.json
                  cat $SCHEDULE_JSON_PATH | jq ".items |= .+[{\"title\":\"$title\",\"url\":\"$url\"}]" > $tmp
                  rm $SCHEDULE_JSON_PATH
                  mv $tmp $SCHEDULE_JSON_PATH
                  exit 1
                else
                  echo "Invalid URL"
                fi
              fi
              echo "Cannot add schedule"
              echo "Arg: $2"
              exit 1
            fi
            ;;
        --config)
            vi $SCHEDULE_JSON_PATH
            exit 1
            ;;
        -h | --help)
            usage
            ;;
        -*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
        * )
            ;;
    esac
done

selectTitle
