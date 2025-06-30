#!/usr/bin/bash -l
#SBATCH -N 1 -c 16 --mem 24gb --out logs/repeatmask.%a.log -a 1

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

INDIR=genomes
MASKDIR=analysis/RepeatMasker
SAMPLES=samples.csv
RMLIBFOLDER=lib/repeat_library
FUNGILIB=lib/fungi_repeat.20170127.lib.gz
mkdir -p $RMLIBFOLDER
RMLIBFOLDER=$(realpath $RMLIBFOLDER)
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
    mkdir -p $MASKDIR/$NAME
    #SPECIESNOSPACE=$(echo -n "$SPECIES $STRAIN" | perl -p -e 's/\s+/_/g')
    GENOME=$(realpath $INDIR)/$NAME.sorted.fasta
    if [ ! -s $MASKDIR/$NAME/$NAME.sorted.fasta.masked ]; then
        module load RepeatModeler
        LIBRARY=$RMLIBFOLDER/$NAME.repeatmodeler.lib
        COMBOLIB=$RMLIBFOLDER/$NAME.combined.lib
        if [ ! -f $LIBRARY ]; then
            pushd $MASKDIR/$NAME
            BuildDatabase -name $NAME $GENOME
            RepeatModeler -threads $CPU -database $NAME -LTRStruct
            rsync -a RM_*/consensi.fa.classified $LIBRARY
            rsync -a RM_*/families-classified.stk $RMLIBFOLDER/$NAME.repeatmodeler.stk
            popd
        fi
        if [ ! -s $COMBOLIB ]; then
            cp $LIBRARY $COMBOLIB
            zcat $FUNGILIB >> $COMBOLIB
        fi
        if [[ -s $LIBRARY && -s $COMBOLIB ]]; then
            module load RepeatMasker
            RepeatMasker -e ncbi -xsmall -s -pa $CPU -lib $COMBOLIB -dir $MASKDIR/$NAME -gff $GENOME
        fi
            rsync -a $MASKDIR/$NAME/$(basename $GENOME).masked $INDIR/$(basename $GENOME).masked.fasta
        else
        echo "Skipping $NAME as masked file already exists"
    fi
done