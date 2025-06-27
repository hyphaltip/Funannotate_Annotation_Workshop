#!/usr/bin/bash -l
#SBATCH -p short -c 48 --mem 48gb --out logs/flye.log

module load Flye

CPU=8
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
INDIR=input
OUTDIR=assemblies/flye
NANOBASE=SRR29740272
ILLBASE=SRR29740273
mkdir -p $OUTDIR
flye --polish-target --genome-size 35m --threads $CPU --iterations 5  --scaffold --nano-corr $INDIR/${NANOBASE}_filtered_U.fastq.gz --out-dir $OUTDIR
