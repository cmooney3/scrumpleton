#!/bin/bash

function SecondsToTime() {
  local seconds="$1"
  local hours="$(awk "BEGIN {printf \"%02d\", int(${seconds} / 3600); exit}")"
  local minutes="$(awk "BEGIN {printf \"%02d\", int((${seconds} - ${hours} * 3600) / 60); exit}")"
  local seconds="$(awk "BEGIN {printf \"%05.2f\", ${seconds} - ${hours} * 3600 - ${minutes} * 60; exit}")"
  echo "${hours}:${minutes}:${seconds}"
}

function GetRuntimeInSeconds() {
  local filename="$1"
  local runtime="$(avprobe "${filename}" 2>&1 | grep Duration | cut -d ' ' -f 4 | sed 's/,//')"

  local hours="${runtime:0:2}"
  local minutes="${runtime:3:2}"
  local seconds="${runtime:6:5}"

  local runtime_s="$(awk "BEGIN {print ${hours} * 60 * 60 + ${minutes} * 60 + ${seconds}; exit}")"
  echo "${runtime_s}"
}


if [ $# -eq 0 ]; then
  echo "ERROR: you must specify at least one file"
  exit 1
fi


echo -e "TOTAL TIME\tLOCAL TIME\tFILENAME"
echo -e "----------\t----------\t--------"
total_runtime_s="0.0"
while [ $# -ne 0 ]; do
  filename="$1"
  runtime_s="$(GetRuntimeInSeconds "${filename}")"
  total_runtime_s="$(awk "BEGIN {print ${total_runtime_s} + ${runtime_s}; exit}")"

  echo -e "$(SecondsToTime ${total_runtime_s})\t$(SecondsToTime ${runtime_s})\t$1"

  shift
done

echo "Total Runtime: $(SecondsToTime ${total_runtime_s})"
