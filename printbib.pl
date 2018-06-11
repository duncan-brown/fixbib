#! /usr/bin/env perl

# Copyright 2018 Duncan Brown
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# helper scropt for pulling keys out of a bibtex entry

use warnings;
use strict;
use feature qw(say);
use Text::BibTeX;

die "Usage $0 <bibfile> <key>\n" if @ARGV != 2;
my $fn=shift;
my $key=shift;

my $bibfile = new Text::BibTeX::File($fn);

while (my $entry = new Text::BibTeX::Entry($bibfile)) {
  if (!$entry->parse_ok) {
    warn "error in input";
    next;
  }
  my $ckey = $entry->key; 
  if (defined $ckey) {
    my $eprint="<no title found>";
    if ($ckey eq $key) {
      if ($entry->exists ('eprint')) {
        $eprint = $entry->get ('eprint');
      }
      elsif ($entry->exists ('doi')) {
        $eprint = $entry->get ('doi');
      }
      elsif ($entry->exists ('title')) {
        $eprint = $entry->get ('title');
        $eprint=~s/ / /g;
      }
      say "$eprint";
      exit;
    }
  }
}
