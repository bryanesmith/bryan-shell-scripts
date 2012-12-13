#!/bin/bash

if [ $# != 0 ]; then
  echo "No parameters permitted. Script checks current directory (recursively) for unadded files."
  exit 1
fi

nice cvs -nq update | grep "^\?"

