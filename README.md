# miniona

produces real-time Krona plots during a minION run

wget https://github.com/rec3141/miniona/archive/master.zip
unzip master.zip
cd master-miniona
bash ./install-miniona.sh <directory-to-install-apps>
bash ./run-miniona.sh <pass-reads-directory> <directory-where-apps-were-installed>

view krona plot at index.html

## pipeline

poretools: convert fast5 to fasta

metagenemark: call open reading frames from fasta

diamond: quick blastp of open reading frames against refseq complete database

kronatools: create krona plot from blastp output
