#!/usr/bin/bash -l
#SBATCH -p short --out download_RNA.log -c 24 --mem 24gb 
module load sratoolkit
module load parallel-fastq-dump
CPU=2
# for cluster running multicpu
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
if [ -z $SCRATCH ]; then
	SCRATCH=/tmp
fi
FOLDER=input/RNA
mkdir -p $FOLDER
IFS=,
while read -r SRA ORG
do
	if [[ ! -f $FOLDER/${SRA}_1.fastq.gz ]]; then
		
		parallel-fastq-dump -T $SCRATCH -O $FOLDER --threads $CPU --split-files --gzip --sra-id $SRA \
			--defline-seq '@$ac.$si/$ri' --defline-qual ''  # these args are for fastq-dump
	# fastq-dump --gzip -O $FOLDER --defline-seq '@$ac.$si/$ri' --defline-qual '' $SRA 
	fi
done < sra_rna.csv
