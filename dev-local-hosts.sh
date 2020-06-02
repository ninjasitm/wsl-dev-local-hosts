#!/bin/bash
set -f

# Adjust the variables below to match your path mask based on wsl mountpoints for your project root folder
DIR_MASK="\/mnt\/c\/Users\/${USER}\/Projects\/"
IP="127.0.0.1"
ARGS=$1
USER_HOST=
[[ -z $3 ]] && USER_HOST=$2 || USER_HOST=$3

function split_by {
  local IFS=:"$1";
  read -ra PARTS <<< "$*";
  echo "${PARTS[@]}"
}

function join_by {
  local IFS="$1";
  shift;
  echo "$*";
}

function reverse_parts {
  local -a input
  local ifs count i reverse
  ifs=${IFS}
  IFS=${ifs}
  count=0
  for word in $*
  do
    input[((++count))]=${word}
  done
  IFS=${ifs}
  for ((i=1;i<=count;++i))
  do
    reverse[((count-i))]=${input[i]}
  done
  echo "${reverse[@]}";
}

function get_host {
    local PWD HOST ARG
    ARG="$1"
    if [ -z "$ARG" ] || [ "$ARG" = '.' ]; then
      PWD=$(pwd)
      HOST_SUB=$(echo "$PWD" | sed "s/$DIR_MASK//g")
            HOST_SPLIT=$(split_by '/' "$HOST_SUB")
      HOST_REVERSED=$(reverse_parts "$HOST_SPLIT")
      HOST=$(echo "$HOST_REVERSED" | sed 's/ /./g')
    else
      HOST=$1
    fi
    echo "${HOST,,}.dev.local";
}

case $1 in
  'add')
    HOST=$(get_host "$USER_HOST")
    ARGS="$1 $IP $HOST";;
  'remove')    HOST=$(get_host "$USER_HOST")
    ARGS="$1 $HOST";;
  'show')
    HOST=$(get_host "$USER_HOST")
    ARGS="$1 $HOST";;
esac

PSH_TOOL="ENTER_TOOL_DIRECTORY_HERE/dev-local-hosts.ps1"
CMD="-File $PSH_TOOL $ARGS"
echo "Executing PowerShell.exe $CMD"
PowerShell.exe $CMD