#!/bin/bash

# Copyright 2010, The Regents of The University of Michigan, All Rights Reserved
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Given two XSLT template files. For every template found in the
# first file, determines whether it is new (doesn't exist in 
# second file), different or the same.
#
# Used for deduping templates.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
usage() {
  cat <<MYUSAGE

USAGE
  xtchanges.sh <file1> <file2>

DESCRIPTION
  Given two XSLT template files, identifies and classifies all
  templates in the first file as one of the following:

    * New (not in the second file)
    * Different (diff in code block)
    * Same

  Note that templates flagged as 'new' or 'different' are not
  guarenteed to be new or different; this is due to a limitation
  in the first-match heuristic for xtloc.sh.

  However, templates flagged as 'same' do have a matching
  template. This tool is conservative about finding similar
  content.

  This is in line with its primary intended use case, which is
  for deduplicating XSLT when refactoring.

EXAMPLES
  xtchanges.sh example1.xsl example2.xsl

DEPENDENCIES
  Requires all the following in path, available at
  [http://bryanesmith.com/documents/unix-shell-scripts/]:
 
    * xtdesc.pl: Prints out attributes for all XSLT templates
      (intended to be used as input for xtloc.pl)
    * xtloc.pl: Prints out start and end line for XSLT template
    * bdiff.sh: Diff algorithm on two blocks of text

EXIT CODES
  0: Exitted normally
  1: Wrong number of parameters
  2: File not found
  3: Environment variable not set
  4: Error with external script

MYUSAGE

}

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
assertnormalexit() {
  if [ "$1" -ne "0" ]; then
    error 4 "The application $2 exitted with non-zero status $1"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
assertexists() {
  if [ ! -e $1 ]; then
    error 2 "Error: $1 not found"
  fi 
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
checktempfileexists() {
  if [ -e $1 ]; then
    error 3 "Temporary file ($1) already exists. I'm being super safe, so please move this file so I can do my job. (I don't want to clobber your files.)"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Verify that environmental variable is set
if [ -z "${MPUBS_BIN}" ]; then
  error 3 "You must set the MPUBS_BIN environmental variable in your .bash_profile to point to the bin/m/mpubs directory in your development space or the dev directory.";
fi

if [ "$#" -ne "2" ]; then
  error 1 "Expecting two parameters, but found ${#}."
fi

# ~ Get arguments and make sure they exist ~
xslt1=$1;
xslt2=$2;

assertexists $xslt1
assertexists $xslt2

TempFile=.xtdesc
checktempfileexists $TempFile
xtdesc.pl $xslt1 > $TempFile

# For every template in the first file, locate in second file
exec 3< $TempFile

while read <&3
do
  
  # Set default read variable to keywords variable for readability
  keywords=$REPLY

  lines1=`xtloc.pl $xslt1 $keywords`
  assertnormalexit $? 'xtloc.pl'
   
  lines2=`xtloc.pl $xslt2 $keywords`
  assertnormalexit $? 'xtloc.pl'

  echo

  # Human-readable range
  lines1Human=`echo "$lines1" | awk '{sub(/ /,"-");print}'`
  lines2Human=`echo "$lines2" | awk '{sub(/ /,"-");print}'`

  if [ "$lines2" == '' ]; then

    echo "---NEW---"
    echo "Template in $xslt1 (keywords "$keywords", lines $lines1Human) is new."

  else

    diffout=`bdiff.sh $xslt1 $lines1 $xslt2 $lines2`
    assertnormalexit $? 'bdiff.sh'

    if [ "$diffout" == '' ]; then

      echo "---SAME---"
      echo "Templates in $xslt1  (keywords "$keywords", lines $lines1Human) and $xslt2 (lines $lines2Human) are same."

    else

      echo "---DIFFERENT---"
      echo "Templates in $xslt1  (keywords "$keywords", lines $lines1Human) and $xslt2 (lines $lines2Human) are different."

    fi

  fi

done

exec 3>&-
rm $TempFile

echo

