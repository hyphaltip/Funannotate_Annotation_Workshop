#!/bin/bash -l
#SBATCH --nodes 1 --ntasks 16 --mem 64G --out logs/predict.%a.log -a 1

module load funannotate
module load workspace/scratch
export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
GMFOLDER=`dirname $(which gmhmme3)`
#genemark key is needed
if [ ! -f ~/.gm_key ]; then
	ln -s $GMFOLDER/.gm_key ~/.gm_key
fi

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

INDIR=genomes
OUTDIR=annotation
SAMPLES=samples.csv
BUSCODB=ascomycota_odb10
BUSCOSEED=anidulans
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
    BASE=$NAME
    GENOME=$INDIR/$NAME.masked.fasta
    #SPECIESNOSPACE=$(echo -n "$SPECIES $STRAIN" | perl -p -e 's/\s+/_/g')
    GENOME=$INDIR/$NAME.masked.fasta
    funannotate predict --keep_no_stops --SeqCenter WVU -i $GENOME \
		-o $OUTDIR/$BASE -s "$SPECIES" --strain "$STRAIN" \
		--AUGUSTUS_CONFIG_PATH $AUGUSTUS_CONFIG_PATH \
		--cpus $CPU --min_training_models 50 --max_intronlen 1200 \
		--name $LOCUS --optimize_augustus \
		--min_protlen 30 --tmpdir $SCRATCH  --busco_db $BUSCODB
done
