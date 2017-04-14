#!/bin/bash

APPDIR=~/apps

DIR=`pwd`
PASS_DIR=$DIR/pass_reads
mkdir $PASS_DIR
CUR_DIR=$DIR/current_reads
mkdir $CUR_DIR

GM_DIR=$APPDIR/MetaGeneMark_linux_64/mgm
GM_BIN=$GM_DIR/gmhmmp
GM_MOD=$GM_DIR/MetaGeneMark_v1.mod

DMD_BIN=$APPDIR/diamond
DMD_DB_DIR=$APPDIR/refseq/

KRONA_BIN=$APPDIR/KronaTools-2.7/bin/ktImportBLAST
KRONA_TAX=$APPDIR/taxanomy

#working directory is $DIR
#reads come into pass_reads/ via soft link

READ_BATCH=0

SECONDS=-1
SECONDS_SINCE=0

while [ $(ls $PASS_DIR | grep -c '^') -gt 0 ] ; do

j=0
for DMD_FILE in `ls $DMD_DB_DIR/refseq_nr_*.dmnd`; do

echo $READ_BATCH

#0 fetch new batch
echo "fetching new batch"
SECONDS_SINCE=$((SECONDS_SINCE-SECONDS))
MIN_SINCE=$( echo "$SECONDS_SINCE/60" | bc -l)
if (( $(echo "$MIN_SINCE>=0" | bc -l ) )); then MIN_SINCE="+"$MIN_SINCE; fi;

SECONDS=0
#find $PASS_DIR -name "*.fast5" -mmin $MIN_SINCE -exec ln -s {} ./$CUR_DIR/ \;
find $PASS_DIR -name "*.fast5" -mmin $MIN_SINCE -exec ln -s {} $CUR_DIR/ \;

if [[ ! $(ls $CUR_DIR | grep -c '^') -gt 0 ]]; then echo "waiting for data"; sleep 30; continue; fi;
 
#1 get passing reads from poretools
echo "getting passing reads"
poretools fasta $CUR_DIR/ > $READ_BATCH.fasta
find $CUR_DIR -type l -delete

#2 call genes
echo "calling genes"
$GM_BIN -o $READ_BATCH.faa.lst -a -m $GM_MOD $READ_BATCH.fasta

#3 extract amino acid sequences
echo "getting sequences"
sed 's/	>/	@/;s/>channel/@channel/;s/^Model/>Model/;/^[[:space:]]*$/d' $READ_BATCH.faa.lst | perl -0076 -ne 'chomp;print ">$_" if $_ =~ "^gene"' > $READ_BATCH.faa

#4 BLASTP using DIAMOND
#need to make the ramdisk and copy nr.dmnd there if not already done
echo "BLASTing"
$DMD_BIN blastp -v -p 16 -f 6 -o $READ_BATCH.$j.dmnd.txt -q $READ_BATCH.faa -t /tmp -k 1 -s 1 --index-mode 1 --db $DMD_FILE

#5 make krona plot
echo "making plot"

$KRONA_BIN -o index.html -i -tax $KRONA_TAX -c <(awk '{ gsub(/ref\|/, ""); gsub(/\|\t/, "\t"); print }' *.dmnd.txt)


#I scp the krona file to my webserver, or you can serve it from this folder
#PWDIR=`basename $DIR`
#scp index.html user@host:/path/to/webserver/$PWDIR/

j=$[j+1]


done;

READ_BATCH=$[READ_BATCH + 1]

done
