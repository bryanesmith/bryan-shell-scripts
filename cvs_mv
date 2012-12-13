#!/bin/bash
#
# Script to move all files from one directory to another. 
# Will perform cvs remove and add for everything, though
# won't commit.
#
# Bryan Smith - bryanesmith@gmail.com

Script=`basename $0`
From=$1
To=$2

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
error() {
  
  if [ "$#" -eq "2" ]; then
      echo
      echo "ERROR: $2"
  fi  

  usage

  exit $1

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
usage() {

  cat <<MYUSAGE

USAGE:
  $0 <source> <dest>

PARAMETERS:
  <source> is the path to a directory from which you want to move 
  all the files.
  
  <dest> is the path to the directory to which you want all the 
  files to be copied.

  NOTE: Don't end directory paths with '/' or you will get protocol
  errors when adding. 

  e.g., WRONG: /m/mpubs/     CORRECT: /m/mpubs

DESCRIPTION:
  Recursively moves all files from one directory to another. 
  It also removes the old file location from CVS and adds the new 
  file location.

  This script will first check that no files will be overwritten,
  and will fail if this is the case.


EXIT CODES:
  0: Exited normally
  1: Wrong number of arguments
  2: Specified source or destination directory not exist
  3: Destination already exists
  4: Unknown error

MYUSAGE

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
shouldSkip() {

  local myresult=''

  # Skip this script if it happens to be in source directory
  if [ "$1" == "$Script" ]; then
    myresult=1

  # Skip all CVS directories
  elif [ `echo $1 | grep "CVS$"` ]; then
    myresult=1

  fi

  echo $myresult
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
log() {
  echo "Action: $1"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
processFile() {

  local File="$1"
  local Action="$2"

  # Skip this file if it happens to be in source directory
  if [ $( shouldSkip $File )  ]; then
    return
  fi

  local RelativeFile=${File#$From}
  local FileTo="${To}/${RelativeFile}"

  if [ -d "$File" ]; then

    # Make sure directory exists in destination or create
    if [ ! -e $FileTo ]; then

      log "Creating directory [ $FileTo ]"
      mkdir $FileTo

    fi

    # Recursively process files, but leave directory alone
    for NextFile in $File/*; do
      processFile "$NextFile" "$Action"
    done
  elif [ -f "$File" ]; then

    # Call the subroutine that was passed as parameter
    $Action "$File" "$FileTo"

  fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
assertdirectory() {

  if [ ! -d $1 ]; then
    error 2 "[ $1 ] not found or is not a directory"
  fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
assertnotexists() {

  local From=$1
  local To=$2

  if [ -e $To ]; then
    error 3 "Destination file already exists: [ $To ]"
  fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cvsmove() {

  local From=$1
  local To=$2

  log "Moving from [ $File ] to [ $To ]"
  mv $From $To

  ExitCode="$?"
  if [ "$ExitCode" != "0" ]; then
    error 4 "Move from [ $File ] to [ $To ] failed with exit code [ $ExitCode ]"
  fi

  cvs rm $From
  cvs add $To

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$#" -ne 2 ]; then
  error 1 "Wrong number of arguments"
fi

assertdirectory $From
assertdirectory $To

# Verify recursively that files in source do not exist dest
for NextFile in $From/*; do
  processFile "$NextFile" 'assertnotexists'
done

# Move files recursively
for NextFile in $From/*; do
  processFile "$NextFile" 'cvsmove'
done

