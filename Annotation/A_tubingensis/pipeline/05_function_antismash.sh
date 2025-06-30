#!/bin/bash -l
#SBATCH -p short -C cascade -N 1 -c 24 -n 1 --mem 16G --out logs/antismash.%a.log -J antismash

module load antismash
# note new version is 
# module load antismash/8.0.1
hostname
CPU=1
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
OUTDIR=annotation
SAMPLES=samples.csv
N=${SLURM_ARRAY_TASK_ID}
if [ -z "$N" ]; then
    N=$1
    if [ -z "$N" ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=`wc -l $SAMPLES | awk '{print $1}'`

if [ "$N" -gt "$MAX" ]; then
    echo "$N is too big, only $MAX lines in $SAMPLES"
    exit
fi

IFS=,
INPUTFOLDER=predict_results

# make sure samples.csv file has a newline at end of last line 
# or this won't read it in properly
IFS=,
tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME SPECIES STRAIN LOCUS RNASEQ
do
    BASE=$NAME
    if [[ ! -d $OUTDIR/$BASE || ! -d $OUTDIR/$BASE/$INPUTFOLDER ]]; then
        echo "No annotation dir for '$OUTDIR/${BASE}'"
        exit
    fi
    if [[ ! -d $OUTDIR/$BASE/antismash_local && ! -s $OUTDIR/$BASE/antismash_local/index.html ]]; then
        antismash --taxon fungi --output-dir $OUTDIR/$BASE/antismash_local  --genefinding-tool none \
                --clusterhmmer --tigrfam --cb-general --pfam2go --rre --cc-mibig \
                --cb-subclusters --cb-knownclusters -c $CPU \
                $OUTDIR/$BASE/$INPUTFOLDER/*.gbk
    else
        echo "folder $OUTDIR/$BASE/antismash_local already exists, skipping."
    fi
done
