#!/bin/bash

DIR=`pwd`
APPDIR=~/scratch/apps
mkdir -p $APPDIR

echo "This will try to install miniona in $APPDIR, if you don't want to install >10Gb of stuff there then quit and edit the script"

read -p "Press [Enter] key to continue..."

cd $APPDIR

# install poretools
echo "installing poretools"
git clone https://github.com/arq5x/poretools


# Install MetaGeneMark
if [ ! -e $APPDIR/MetaGeneMark_linux_64.tar.gz ]; then echo "You must download MetaGeneMark manually from http://exon.gatech.edu/GeneMark/license_download.cgi into $APPDIR"; exit 0; fi;
tar xvzf MetaGeneMark_linux_64.tar.gz

#install mgm key
cp MetaGeneMark*/mgm/gm_key ~/.gm_key

#install diamond
echo "installing DIAMOND"
wget http://github.com/bbuchfink/diamond/releases/download/v0.8.37/diamond-linux64.tar.gz
tar xzf diamond-linux64.tar.gz

#download refseq database for diamond
echo "about to download 10Gb Refseq complete non-redundant database"
mkdir -p refseq
cd refseq
#389
for NUM in `seq 1  2`; do
	wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/complete/complete.nonredundant_protein.$NUM.protein.faa.gz
done;

echo "splitting refseq for input to diamond"
#split -n l/12 --numeric-suffixes=1 --additional-suffix=.faa <(gunzip -c complete.nonredundant_protein.*.protein.faa.gz) refseq_

awk 'BEGIN {n_seq=0;} /^>/ {if(n_seq%5000000==0){file=sprintf("refseq_%d.faa",n_seq);} print >> file; n_seq++; next;} { print >> file; }' < <(gunzip -c complete.nonredundant_protein.*.protein.faa.gz)

echo "making diamond database"
for NUM in `seq 0 11`; do
	$APPDIR/diamond makedb --in refseq_$NUM.faa -d refseq_$NUM
done;

echo "done making diamond database"
cd $APPDIR

#install Kronatools
echo "installing Kronatools"

wget https://github.com/marbl/Krona/releases/download/v2.7/KronaTools-2.7.tar
tar xvf KronaTools-2.7.tar
cd KronaTools-2.7
./install.pl --prefix=./

echo "installing Krona Taxonomy, this takes a while"
./updateTaxonomy.sh

echo "installing Krona Accession, this take a long while"
./updateAccessions.sh

cd $DIR

echo "done installing miniona. run program with ./run-miniona.sh"

