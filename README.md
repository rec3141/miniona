# miniona

produces real-time Krona plots during a minION run

#pipeline

poretools: convert fast5 to fasta
metagenemark: call open reading frames from fasta
diamond: quick blastp of open reading frames against refseq complete database
kronatools: create krona plot from blastp output
