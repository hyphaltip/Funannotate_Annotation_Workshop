#!/usr/bin/bash -l
#SBATCH -p short -c 48 --mem 64gb --out logs/unicycler.log

module load unicycler
CPU=8
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
INDIR=../../Dataset/A_tubingensis/input
OUTDIR=assemblies/unicycler

mkdir -p $OUTDIR

# -l  is for long reads, this is the Nanopore File, all FASTQ in same file
# -1 and -2 are paired end reads for short read library (eg illumina)
unicycler -l $INDIR/SRR29740272_1.fastq.gz -1 $INDIR/SRR29740273_1.fastq.gz -2 $INDIR/SRR29740273_2.fastq.gz -o $OUTDIR -t $CPU
