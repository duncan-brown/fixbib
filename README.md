# fixbib
Scripts for fixing bibtex keys in latex documents

People should always pick bibtex keys from *either* [ADS](http://adsabs.harvard.edu/abstract_service.html) *or* [INSPIRES](https://inspirehep.net/) and never the twain shall meet. They should never invent their own bibtex keys. Unfortunately, this generally never happens, so these are my scripts for fixing it.

## Required Packages

These scripts use the perl `Text::BibTeX` module. First install the CPAN module that lets you install perl modules in a user's home directory:
```sh
sudo cpan install local::lib
```
Then enable this by adding
```sh
eval `perl -I ~/Library/perl5/lib/perl5 -Mlocal::lib=~/Library/perl5`
```
to your `.bash_profile`. Open a new shell and install the required module with
```sh
cpan install Text::BibTeX
```

## Using the scripts

1. Run the script [converttoinspires.sh](https://github.com/duncan-brown/fixbib/blob/master/converttoinspires.sh) which grabs all bibtex keys from citation commands matching `\cite{key}` or `\citeUS[]{key}` (you will need to modify the regexps if you use other citation commands like `\citep{key}`). The script then does its best to resolve these as INSPIRES keys, ADS keys, and APS keys. For citations that it can match, it writes an INSPIRES entry in the file `inspires_bibliography.bib` and a single line in the file `convert_to_inspies.key` that has the format `oldkey inspireskey`. 
2. Keys that it cannot figure out are written into the file `unresolved.key` and will need to be converted to INSPIRES keys manually. For each key that you resolve, add (or use an existing) INSPIRES BibTeX entry to `inspires_bibliography.bib` and add a line to `convert_to_inspies.key` that lists the `oldkey inspireskey` for the conversion.
3. Finally, run [fixkey.sh](https://github.com/duncan-brown/fixbib/blob/master/fixkey.sh) which loops over the lines in the file `convert_to_inspies.key` and does a find and replace on each `*.tex` file in the current directory converting each `oldkey` to  `inspireskey`.

The script [printbib.pl](https://github.com/duncan-brown/fixbib/blob/master/printbib.pl) is a helper script that is called by [converttoinspires.sh](https://github.com/duncan-brown/fixbib/blob/master/converttoinspires.sh) but does not need to be run directly.
