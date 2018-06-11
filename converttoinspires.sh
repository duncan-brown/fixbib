#!/bin/bash

set -v

# Remove any existing files uses as bibtex databases.
rm -f inspires_bibliography.bib
rm -f *key
rm -f unresolved.key

# Grab citations from any file ending in *.tex in the current directory. This
# matches: \cite{key} and \citeUS[]{key} in the tex source code.
perl -nle 'print $1 while /(?:\\citeUS\[\]\{|(?<!^)\G),?\s*([^,}]+)(?=[^}]*})/g' *tex | sort | uniq > all.key
perl -nle 'print $1 while /(?:\\cite\{|(?<!^)\G),?\s*([^,}]+)(?=[^}]*})/g' *tex | sort | uniq >> all.key

# Filter out the bibtex keys that look like inspires
perl -nle 'print while /^[a-zA-Z-]*:\d\d\d\d[a-zA-Z]*$/g' all.key | sort | uniq > inspires.key
perl -nle 'print unless /^[a-zA-Z-]*:\d\d\d\d[a-zA-Z]*$/g' all.key | sort | uniq > keys.tmp

rm -f all.key

# Filter out the bibtex keys that look like ads
perl -nle 'print while /\d\d\d\d[a-zA-Z0-9.\&]{15}$/g' keys.tmp | sort | uniq > ads.key
perl -nle 'print unless /\d\d\d\d[a-zA-Z0-9.\&]{15}$/g' keys.tmp | sort | uniq > keys2.tmp

# Filter out the ones that look like aps
perl -nle 'print while /^PhysRev/g' keys2.tmp | sort | uniq > aps.key
perl -nle 'print unless /^PhysRev/g' keys2.tmp | sort | uniq > other.key

rm -f keys.tmp keys2.tmp

# resolve ads and aps keys to inspires
for adskey in `cat ads.key aps.key`
do
  /bin/echo -n "."
  curl -s "https://inspirehep.net/search?ln=en&ln=en&p=${adskey}&of=hx&action_search=Search&sf=earliestdate&so=d&rm=&rg=25&sc=0" > inspires.tmp
  inspireskey=`perl -nle 'undef $/; print "$2" if /(\@article{)(.*?)(,.*?^})/msg;' inspires.tmp`
  if [[ -z $inspireskey ]] ; then
    eprint=`curl -s "http://adsabs.harvard.edu/cgi-bin/nph-bib_query?bibcode=${adskey}&data_type=BIBTEX" | perl -nle 'print $1 if /eprint = \{(.*?)\}/g'`
    curl -s "http://inspirehep.net/search?ln=en&ln=en&p=find+eprint+${eprint}&of=hx&action_search=Search&sf=&so=d&rm=&rg=25&sc=0" > inspires.tmp
    inspireskey=`perl -nle 'undef $/; print "$2" if /(\@article{)(.*?)(,.*?^})/msg;' inspires.tmp`
  fi
  if [[ -z $inspireskey ]] ; then
     echo "*** Unable to resolve: ${adskey} ***"
     curl -s "http://adsabs.harvard.edu/cgi-bin/nph-bib_query?bibcode=${adskey}&data_type=BIBTEX" >> inspires_bibliography.bib
  else
    echo $adskey $inspireskey >> convert_to_inspies.key
    perl -nle 'undef $/; print "$1$2$3" if /(\@article{)(.*?)(,.*?^})/msg;' inspires.tmp >> inspires_bibliography.bib
  fi
done

# get inspires keys
for inspireskey in `cat inspires.key`
do
  /bin/echo -n "."
  curl -s "https://inspirehep.net/search?ln=en&ln=en&p=find+texkey+${inspireskey}&of=hx&action_search=Search&sf=earliestdate&so=d&rm=&rg=25&sc=0" > inspires.tmp
  perl -nle 'undef $/; print "$1$2$3" if /(\@article{)(.*?)(,.*?^})/msg;' inspires.tmp >> inspires_bibliography.bib
done

# try and resolve any other keys
for otherkey in `cat other.key` 
do
  /bin/echo -n "."
  s=`./printbib.pl TheBibFile.bib $otherkey 2>/dev/null`
  curl -s "http://inspirehep.net/search?ln=en&ln=en&p=${s}&of=hx&action_search=Search&sf=&so=d&rm=&rg=25&sc=0" > inspires.tmp
  inspireskey=`perl -nle 'undef $/; print "$2" if /(\@article{)(.*?)(,.*?^})/msg;' inspires.tmp`
  if [[ -z $inspireskey ]] ; then
    echo "*** Unable to resolve: $s ***"
    echo $otherkey >> unresolved.key
  else
    echo $adskey $inspireskey >> convert_to_inspies.key
    perl -nle 'undef $/; print "$1$2$3" if /(\@article{)(.*?)(,.*?^})/msg;' inspires.tmp >> inspires_bibliography.bib
  fi
done

echo "wrote conversion file convert_to_inspies.key and bibfile inspires_bibliography.bib"
exit 0
