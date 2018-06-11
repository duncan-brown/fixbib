#! /usr/bin/env perl

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
