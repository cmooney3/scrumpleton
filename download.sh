#!/bin/bash

PLAYLIST_URL="https://www.youtube.com/playlist?list=PLbnEWolRzFMQSVqg_3NPyRw3bzvx1KukE"
FORMAT_SPECIFIER="mp4"  #"best[height<=480]"
VIDEO_DIR="./videos"

# First download all the videos into a videos directory
if [ -d "${VIDEO_DIR}" ]; then
  echo "ERROR: The output directory '${VIDEO_DIR}' already exists!"
  echo "Delete or rename this directory, and try again"
  exit 1
fi
mkdir "${VIDEO_DIR}"
youtube-dl --output "${VIDEO_DIR}/%(title)s.%(ext)s" \
           -f "${FORMAT_SPECIFIER}" -i \
           "${PLAYLIST_URL}"

function AddRandomPrefix() {
  while [ $# -ne 0 ]; do
    local filepath="$1"
    local filename="$(basename "${filepath}")"
    local directoryname="$(dirname "${filepath}")"

    local prefix="$(openssl rand -hex 8)"

    echo "${prefix}_${filename}"
    mv "${filepath}" "${directoryname}/${prefix}_${filename}"

    shift
  done
}
function RandomizeFilenames() {
  while [ $# -ne 0 ]; do
    local filepath="$1"
    local filename="$(basename "${filepath}")"
    local extension="${filename##*.}"
    local directoryname="$(dirname "${filepath}")"

    local new_filename="$(openssl rand -hex 8)"

    echo "${filename} ==> ${new_filename}.${extension}"
    mv "${filepath}" "${directoryname}/${new_filename}.${extension}"

    shift
  done
}

# Next, go in and add random prefixes to the filenames so they play in a
# random order once they're on the projector. (or completely kill the old
# filenames.  That's sometimes desireable since it removes any special
# characters that Youtube might have allowed)
#AddRandomPrefix "${VIDEO_DIR}"/*
RandomizeFilenames "${VIDEO_DIR}"/*


# Now split up all the files into directories with no more than 200 videos
# in each -- the projector can only add 200 videos to a playlist at once
# so this way we get a different set to scroll through each night.
MAX_PLAYLIST_SIZE=200
function SeparateIntoPlaylists() {
  local count=0
  while [ $# -ne 0 ]; do
    local filepath="$1"
    local directory_name="$(dirname "${filepath}")"
    local playlist_number=$((count / MAX_PLAYLIST_SIZE))
    local playlist_name="list${playlist_number}"

    echo "${filepath} ==> ${playlist_name}"
    mkdir -p "${directory_name}/${playlist_name}"
    mv "${filepath}" "${directory_name}/${playlist_name}/"

    count=$((count + 1))
    shift
  done
}
SeparateIntoPlaylists "${VIDEO_DIR}"/*
