#!/usr/bin/perl -w

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
# Prints out start and end line numbers for template in an XSLT 
# file.
#
# Nov 8 2010
#
# Bryan Smith - bryanesmith@gmail.com
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

use strict;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub usage() {

  print <<MYUSAGE;

USAGE
  xtloc.pl <file> <keyword> (<keyword> ...)

  Where keyword is the value of the name, match or mode attribute.

DESCRIPTION
  Prints out line numbers for first template with specified name
  in XSLT file if found. Note that name might also be a matching
  XPATH path (e.g., MyContent or /Path/to/node).

  Note this tool uses a first-find heuristic -- it matches the
  first template that contains all the specified keywords. Hence
  the tool cannot be guarenteed to find exactly what you want
  when a query is underspecified.

  This has important implications for tools and pipelines using
  this utility. E.g., in xtchanges.sh, all templates in a
  specified XSLT file are ran through xtloc.pl. If two templates
  have the same keywords but the latter is less specific, this
  tool will find the former.

  When building tools and pipelines using this utility, design
  your solution with this limitation in mind. (Or develop your
  XSLT with less specific templates earlier in the document!)

EXAMPLES
 
  xtolc.pl sample.xsl MyContentBody
    Will print out line numbers for any template with name,
    match or mode value of 'MyContentBody'

  xtolc.pl sample.xsl Item
    Will print out line numbers for any template with name,
    match or mode value of 'MyContentBody'

NOTES
  * This only works if maximum of one template defined per line

EXIT CODES
  0: Exits normally
  1: Input file not found

MYUSAGE

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub myerror {
  my ( $code, $msg ) = @_;
  print "ERROR: $msg\n";
  usage();
  exit $code;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub lineMatches {

  my $line = shift;

  while ( @_ ) {
    my $keyword = shift;

    # Don't wrap keyword in word boundaries since paths
    # wouldn't work
    return 0 if not $$line =~ /\bxsl:template\b.*$$keyword/;
  }

  return 1;
}

sub processArg {
  my $arg = shift;
  
  # Remove quotes
  if ( $arg =~ /^'.*'$/ ) {
    $arg = substr( $arg, 1, -1 );
  }

  # Escape any *
  $arg =~ s/\*/\\*/g;

  $arg;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ( @ARGV < 2 ) {
  myerror 1, "At least two arguments are required: the file and a keyword.";
}

my $xslt = shift;

# Store remaining arguments as references for efficiency
my @keywords = map { \ processArg( $_ ) } @ARGV;

my ( $start, $end, $found );

open XSLT, "<$xslt";

while (<XSLT>) {

  # Trick: use end to keep track of current line, but only
  #        define start if found
  $end++;

  # If in template and found closing
  last if ( defined( $start ) and /\bxsl:template\b/ );
  
  # If found template
  if ( lineMatches( \$_, @keywords ) ) {
    $start = $end;

    # Is this an empty tag?
    last if ( /\bxsl:template\b.*?[\/]\>/ );
  }

}

close XSLT;

if ( defined ( $start ) ) {

  print "$start ${end}\n";

}

