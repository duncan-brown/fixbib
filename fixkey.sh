#!/bin/bash

# loop over all the key conversions and perl find and replace them

IFS="
"

for l in `cat convert_to_inspies.key`
do
  old=`echo $l | awk '{print $1}'`
  new=`echo $l | awk '{print $2}'`
  for file in *tex
  do
    echo changing $old to $new in $file
    rm -f ${file}.bak
    perl -pi.bak -e "s/$old/$new/g" $file
  done
done
