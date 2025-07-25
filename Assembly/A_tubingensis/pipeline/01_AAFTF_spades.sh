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
WORKDIR=work

mkdir -p $OUTDIR $WORKDIR
# these data were processed in the clean step
# right now this isn't using nanopore reads just an example for short read assembly with spades
OUTREADS=$(realpath input)
BASE=SRR29740273
LEFT=$OUTREADS/${BASE}_filtered_1.fastq.gz
RIGHT=$OUTREADS/${BASE}_filtered_2.fastq.gz
MERGED=$OUTREADS/${BASE}_filtered_U.fastq.gz
ID=Atub
ASMFILE=$OUTDIR/${ID}.spades.fasta
VECCLEAN=$OUTDIR/${ID}.vecclean.fasta
PURGE=$OUTDIR/${ID}.sourpurge.fasta
POLISH=$OUTDIR/${ID}.polish.fasta

if [[ ! -f $ASMFILE && ! -f $ASMFILE.gz ]]; then
	AAFTF assemble -c $CPU --left $LEFT --right $RIGHT --merged $MERGED --memory $MEM \
	      -o $ASMFILE -w $WORKDIR/spades_${ID}
fi


if [[ ! -f $VECCLEAN && ! -f $VECCLEAN.gz ]]; then
	AAFTF fcs_screen -i $ASMFILE -o $VECCLEAN.fcs_screen
	AAFTF vecscreen -i $VECCLEAN.fcs_screen -c $CPU -o $VECCLEAN
fi
if [[ ! -f $PURGE && ! -f $PURGE.gz ]]; then
	AAFTF sourpurge -i $VECCLEAN -o $PURGE -c $CPU --phylum $PHYLUM
	# let's not remove based on coverage for now this maybe too agressive
	#--left $LEFT --right $RIGHT
	pigz $VECCLEAN
	pigz $VECCLEAN.fcs_screen
    fi

