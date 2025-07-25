#!/usr/bin/bash -l
#SBATCH -p short -c 48 --mem 64gb --out logs/AAFTF.log

module load AAFTF
CPU=8
MEM=64
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
INDIR=../../Dataset/A_tubingensis/input
OUTDIR=assemblies/spades

mkdir -p $OUTDIR
# these data were processed in the clean step
# right now this isn't using nanopore reads just an example for short read assembly with spades
OUTREADS=input
LEFT=$OUTREADS/${BASE}_filtered_1.fastq.gz
RIGHT=$OUTREADS/${BASE}_filtered_2.fastq.gz
MERGED=$OUTREADS/${BASE}_filtered_U.fastq.gz
ID=Atub
ASMFILE=$OUTDIR/${ID}.spades.fasta
AAFTF assemble -c $CPU --left $LEFT --right $RIGHT --merged $MERGED --memory $MEM \
	      -o $ASMFILE -w $WORKDIR/spades_${ID}

