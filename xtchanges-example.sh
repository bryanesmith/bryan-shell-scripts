#!/bin/sh

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
# Compares all the templates in all the XSLT files
# in the mpubserials directories with those in text
# directory, and classifies each template as 'new',
# 'different' or 'same'. (To aid with refactoring and
# deduplication.)
#
# Requires xtchanges.sh and its dependencies, which
# are available for download:
#
# http://bryanesmith.com/documents/unix-shell-scripts/
#
# Nov 8 2010
# Bryan Smith - besmit@umich.edu
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

mpubs="/l1/dev/besmit/web/m/mpubserials"
text="/l1/dev/besmit/web/t/text"

compare() {
  echo "--- Examining $1 ---"
  mpubsfile="$mpubs/$1"
  textfile="$text/$1"
  output="${1}.xtchanges"
  xtchanges.sh $mpubsfilel $textfile > $output
}

cd $mpubs
for file in *.xsl; do
  compare $file
done

