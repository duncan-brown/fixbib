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

