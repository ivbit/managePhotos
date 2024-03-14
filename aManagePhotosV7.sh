#! /usr/bin/dash

# Intellectual property information START
#
# Copyright (c) 2023 Ivan Bityutskiy 
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# Intellectual property information END
#
# Description START
#
# A complex POSIX shell script to manage photographies:
# 1) Move photographies from removable media to destination folders,
# while renaming them appropriately.
# 2) Rearrange last photographies (after the user deletes some of them),
# in an order photo0001.jpg, photo0002.jpg, photo0003.jpg, ...
# User have to choose the number of previous dates, then the script will
# rearrange the files only in the corresponding folders. Default is today +
# yesterday, the day before yesterday, the day before the day before yesterday.
# 3) Rearrange all photographies present on local system.
# User can change script modes through 1st argument to the script (1, 2, 3), or
# by using a prompt. 
# DEPENDENCY: exiftool
#
# Description END

# Shell settings START
# On old shell 'errexit' may cause buggy behavior: shell exits during 'for' loop
# set -o errexit
# set -o nounset
set -eu
# set +o noglob
set +f
# Shell settings END

# Declare variables START
# Handle file names with spaces
IFS="$(printf -- '\n\t')"
tRed='\033[31m'
tNorm='\033[0m'
outPath="/home/${LOGNAME}/Pictures"
inPath='/mnt/Images'
inPath2='/mnt/Pictures'
yearDir=''
photoDir=''
tempPath=''
phName=''
# Variable 'arranged' with 300 records like 'p220918' has length of 2400 chars
arranged=''
yesNo=''
scriptMode=1
numDaysAgo=3
counter=1
# Declare variables END

# Define functions START
# Count photos in a directory provided as 1st argument to a function.
# Result is number of photos + 1, or 1 if there are no photos.
# Some old versions of sh don't understand += -= *= /= %=,
# instead of ': $(( counter += 1 ))', use 'counter=$(( $counter + 1 ))'.
countPhotos()
(
  > /dev/null 2>&1 ls "${1}"/*.jpg || { printf -- '%d' 1 && return 0; }
  counter=$(ls "${1}"/*.jpg | wc -l)
  counter=$(( $counter + 1 ))
  printf -- '%d' $counter
)

# Print 1st argument to STDERR and exit the script
errorM()
{
  >&2 printf -- "\n\t${tRed}%s${tNorm}\n\n" "$1"
  exit 1
}

# Clear just the screen, not the whole console
fnClear()
{
  >&2 printf -- '\033[1;1H\033[0J'
}

# Format file name like 'photo0001.jpg'
formatName()
{
  printf -- 'photo%04d.jpg' "$1"
}

# Use stat from GNU Coreutils (syntax differs from OpenBSD's stat)
# and date to return the date in form of directory name
getDate()
{
  case "$1" in
    # full)
    #   date -d "$(stat -c '%y' "$2")" '+y%Y/p%y%m%d'
    # ;;
    year)
      date -d "$(stat -c '%y' "$2")" '+y%Y'
    ;;
    date)
      date -d "$(stat -c '%y' "$2")" '+p%y%m%d'
    ;;
  esac
}

# Arrange photos in a directory provided as 1st argument.
# Photos are expected to be in format photo0001.jpg, photo0002.jpg, ...
# Having a photo with format like aaa.jpg, something.jpg is an error.
# Photos are rearranged in case some of them were deleted by user:
# photo0002.jpg was deleted because of low quality, photo0001.jpg and
# photo0003.jpg are left. photo0003.jpg becomes photo0002.jpg and so on.
# () instead of {} to run function in a subshell and make it's 'counter'
# variable local to not interfere with global variable 'counter'.
arrangePhotos()
(
  > /dev/null 2>&1 ls "${1}"/*.jpg || return 0
  counter=1
  for img in "${1}"/*.jpg
  do
    phName="$(formatName $counter)"
    test "$phName" != "${img##*/}" &&
      mv "$img" "${1}/${phName}"
    counter=$(( $counter + 1 ))
  done
)

# getUnique()
# {
#   printf -- '%s' "$1" | tr ' ' '\n' | sort -u
# }
# Define functions END

# BEGINNING OF SCRIPT
> /dev/null 2>&1 ls "$outPath" || errorM 'Drive is not mounted!'
> /dev/null 2>&1 command -v exiftool || errorM 'exiftool is not installed!'

fnClear
# If there are no arguments to the script, prompt the user
if test $# -eq 0
then
  printf -- '\n%s\n' '1) Move photos from phone'
  printf -- '%s\n' '2) Rearrange last photos'
  printf -- '%s\n\n' '3) Rearrange all photos'
  IFS='' read -r -p 'Select script mode: ' -- scriptMode
else
  scriptMode="$1"
fi

case "$scriptMode" in
  2) 
    # Rearrange last photos
    printf -- '\n%s\n' 'Enter the amount of days ago:'
    printf -- '%s\n%s\n' '0 - Today' '1 - Today and Yesterday'
    printf -- '%s\n%s\n' '2 - Today, Yesterday and Day before yesterday' '     and so on...'
    printf -- '%s\n\n' 'Default is 3 (today + 3 days ago)'
    # Ask the user to enter the amount of days
    IFS='' read -r -p 'Last days: ' -- numDaysAgo
    # If NaN, or less than 0, or greater than 11000, set number of days to 3
    > /dev/null 2>&1 printf -- '%d' "$numDaysAgo" || numDaysAgo=3
    test -n "$numDaysAgo" && test "$numDaysAgo" -ge 0 && test "$numDaysAgo" -le 11000 || numDaysAgo=3

    # If the directory exists, rearrange photos inside of it
    while test $numDaysAgo -ge 0
    do
      tempPath="${outPath}/$(date -d "now - $numDaysAgo days" '+y%Y/p%y%m%d')"
      numDaysAgo=$(( $numDaysAgo - 1 ))
      test -d "$tempPath" && arrangePhotos "$tempPath"
    done
  ;;
  3) 
    # Rearrange all photos
    # In the output directory look for all directories with names like y2023,
    # inside those directories look for all directories with names like p230117,
    # rearrange all photos in those directories.
    IFS='' read -r -p 'This will take a lot of time, are you sure? (y/n): ' -- yesNo
    test "x$yesNo" != 'xy' && errorM "You've chosen NOT to rearrange all photos!"
    for yDir in "${outPath}"/y????
    do
      for pDir in "${yDir}"/p??????
      do
        arrangePhotos "$pDir"
      done
    done
  ;;
  *)
    # Move photos
    # User entered any input, including empty string (just pressed ENTER)
    > /dev/null 2>&1 ls "$inPath"/*.jpg ||
    { > /dev/null 2>&1 ls "$inPath2"/*.jpg && inPath="$inPath2"; } ||
    errorM 'Phone is not mounted, or no photos are available!'
    # For earch photo on the removable device, create 2 directories in formats y2023 and p230117,
    # if the directory exists, arrange photos in it, but do it only once, then use exiftool to
    # copy the photo without metadata to the destination directory, then remove original photo with rm.
    for img in "${inPath}"/*.jpg
    do
      yearDir="$(getDate year "$img")"
      tempPath="${outPath}/${yearDir}"
      test -d "$tempPath" || mkdir "$tempPath"
      photoDir="$(getDate date "$img")"
      tempPath="${outPath}/${yearDir}/${photoDir}"
      if test -d "$tempPath"
      then
        case "$arranged" in
          *${tempPath##*/}*)
            :
          ;;
          *)
            arranged="${arranged} ${tempPath##*/}"
            arrangePhotos "$tempPath"
          ;;
        esac
        counter=$(countPhotos "$tempPath")
      else
        mkdir "$tempPath" && arranged="${arranged} ${tempPath##*/}"
        counter=1
      fi
      tempPath="${tempPath}/$(formatName $counter)"
      exiftool -all:all= "$img" -o "$tempPath" && rm "$img"
    done
  ;;
esac

# END OF SCRIPT

