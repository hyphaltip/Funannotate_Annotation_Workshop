#!/usr/bin/bash -l
#SBATCH -p short --out download_DNA.log -c 24 --mem 24gb 
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
FOLDER=input
mkdir -p $FOLDER
IFS=,
while read -r SRA ORG TYPE
do
	if [[ ! -f $FOLDER/$SRA.fastq.gz && ! -f $FOLDER/${SRA}_1.fastq.gz ]]; then
		parallel-fastq-dump -T $SCRATCH -O $FOLDER --threads $CPU --split-files --gzip --sra-id $SRA
	# fastq-dump --gzip -O $FOLDER $SRA 
	fi
done < sra_dna.csv
