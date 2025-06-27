#!/usr/bin/bash -l
#SBATCH -p short -c 48 --mem 64gb --out logs/unicycler_filt_merged_reads.log

module load unicycler
CPU=8
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
INDIR=input
OUTDIR=assemblies/unicycler_filt_merged_reads
NANOBASE=SRR29740272
ILLBASE=SRR29740273
mkdir -p $OUTDIR

# -l  is for long reads, this is the Nanopore File, all FASTQ in same file
# -1 and -2 are paired end reads for short read library (eg illumina)
unicycler -l $INDIR/${NANOBASE}_filtered_U.fastq.gz -1 $INDIR/${ILLBASE}_filtered_1.fastq.gz -2 $INDIR/${ILLBASE}_filtered_2.fastq.gz -s $INDIR/${ILLBASE}_filtered_U.fastq.gz -o $OUTDIR -t $CPU

