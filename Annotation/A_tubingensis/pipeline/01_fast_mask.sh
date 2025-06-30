#!/usr/bin/bash -l
#SBATCH -N 1 -c 16 --mem 24gb --out logs/repeatmask_fast.%a.log -a 1

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

INDIR=genomes
SAMPLES=samples.csv
MASKDIR=analysis/RepeatMasker
FUNGILIB=lib/fungi_repeat.20170127.lib.gz
N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=$(wc -l $SAMPLES | awk '{print $1}')
if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPLES"
    exit
fi

# make sure samples.csv file has a newline at end of last line 
# or this won't read it in properly
IFS=,
tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME SPECIES STRAIN LOCUS RNASEQ
do
    echo $NAME
    mkdir -p $MASKDIR/$NAME.fast
    #SPECIESNOSPACE=$(echo -n "$SPECIES $STRAIN" | perl -p -e 's/\s+/_/g')
    GENOME=$(realpath $INDIR)/$NAME.sorted.fasta
    BASENAME=$(basename $GENOME)
    if [ ! -s $MASKDIR/$NAME.fast/$NAME.sorted.fasta.masked ]; then
	# note you can also use the tantan repeat tool which is less sensitive but does not have the 
	# commerical licensing restrictions
	module load funannotate
	funannotate mask -i $GENOME -o $INDIR/${BASENAME}.masked_tantan.fasta
	module unload funannotate
        module load RepeatModeler
        RepeatMasker -e ncbi -xsmall -s -pa $CPU -species fungi -dir $MASKDIR/$NAME.fast -gff $GENOME
	pigz -dkf $FUNGILIB
	FUNGILIBUNCOMPRESS=$(echo $FUNGILIB | perl -p -e 's/\.gz$//')
        #RepeatMasker -e ncbi -xsmall -s -pa $CPU -lib $FUNGILIBUNCOMPRESS -dir $MASKDIR/$NAME.fast -gff $GENOME
        rsync -a $MASKDIR/$NAME.fast/$BASENAME.masked $INDIR/$BASENAME.masked_fast.fasta
    fi

    echo "you will need to either copy the $INDIR/${BASENAME}.masked_fasta.fasta or $INDIR/${BASENAME}.masked_tantan.fasta to $INDIR/${BASENAME}"
done
