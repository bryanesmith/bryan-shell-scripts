#!/bin/bash
# Remove one or more files from disk and CVS.

error() {
  echo
  echo "Error: $1"
  echo
  exit $2
}

rmfile() {
  
  File=$1

  if [ ! -e $File ]; then

    error "$File does not exist." 2
  
  fi  

  rm $File
  RmCode=$?
  if [ "$RmCode" != "0" ]; then
  
    error "Problem removing {$File}, exit code: $RmCode" $RmCode
  
  fi  

  cvs rm $File
}

if [ $# == 0 ]; then

  error "You invoked $0 without any parameters. Do you want to delete something or not?" 1

fi

while (( "$#" )); do
  rmfile $1
  shift
done


