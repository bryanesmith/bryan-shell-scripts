#!/bin/bash

if [ $# != 0 ]; then
  echo "No parameters permitted. Script checks current directory (recursively) for any changes."
  exit 1
fi

nice cvs -f status 2>/dev/null | grep -A 4 "Status: Locally"


