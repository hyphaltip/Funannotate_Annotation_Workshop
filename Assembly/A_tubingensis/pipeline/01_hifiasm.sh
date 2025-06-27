#!/usr/bin/bash -l
#SBATCH -p short -c 32 --mem 64gb --out logs/hifiasm_filt.log

module load hifiasm


CPU=8
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
INDIR=input
OUTDIR=assemblies/hifasm
NANOBASE=SRR29740272
ILLBASE=SRR29740273
mkdir -p $OUTDIR
# hifiasm requires long reads, so we use the Nanopore reads as the primary input
# and the Illumina reads as the secondary input for polishing
# --ont is for long reads, this is the Nanopore File, all FASTQ in same file
# --telo-m is for telomere motif, which is used to identify telomeres in the assembly
# --telo-m 'CCCTAAAA' is the telomere motif for A. tubingensis
# The input files are the filtered reads from the previous step
# The output will be in the specified OUTDIR with the prefix Atub_hifi.asm
# The output will be in the form of a GFA file, which can be converted
# to FASTA or FASTQ format using hifiasm tools or other tools like seq
hifiasm -l0 --ont -o $OUTDIR/Atub_ONT -t $CPU --telo-m 'CCCTAAAA' $INDIR/${NANOBASE}_filtered_U.fastq.gz 
#$INDIR/${ILLBASE}_filtered_U.fastq.gz
