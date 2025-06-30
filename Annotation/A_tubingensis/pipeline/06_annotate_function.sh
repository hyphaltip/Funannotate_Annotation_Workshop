#!/bin/bash -l
#SBATCH -N 1 -c 24 -n 1 --mem 64G --out logs/annotate.%a.log -a 1
# note this doesn't need that much memory EXCEPT for the XML -> tsv parsing that happens when you provided an interpro XML file

module load workspace/scratch

CPUS=$SLURM_CPUS_ON_NODE

if [ -z "$CPUS" ]; then
    CPUS=2
fi
SAMPLES=samples.csv
N=${SLURM_ARRAY_TASK_ID}

if [ -z "$N" ]; then
    N=$1
    if [ -z "$N" ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=$(wc -l $SAMPLES | awk '{print $1}')
if [ "$N" -gt "$MAX" ]; then
    echo "$N is too big, only $MAX lines in $SAMPLES"
    exit
fi

INDIR=genomes
OUTDIR=annotation
BUSCODB=sordariomycetes_odb10
SBTTEMPLATE=lib/sbt

# make sure samples.csv file has a newline at end of last line 
# or this won't read it in properly
IFS=,
tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME SPECIES STRAIN LOCUS RNASEQ
do
    MITO=$INDIR/$NAME.mito.fasta
    SBT=$SBTTEMPLATE/$NAME.sbt
    if [ ! -f $SBT ]; then
        echo "no SBT file $SBT"
        exit
    fi
    echo "$BASE"
    module load funannotate
    export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db

    ANTISMASH=$OUTDIR/$BASE/antismash_local/$NAME.gbk
    ARGS=()
    if [[ -d $(dirname $ANTISMASH) && -s $ANTISMASH ]]; then
	ARGS+=(--antismash $ANTISMASH)
    fi 
    if [ -s $MITO  ]; then
	ARGS+=(--mito $MITO)
    fi
    funannotate annotate -i $OUTDIR/$BASE --cpus $CPUS --tmpdir $SCRATCH  \
		--species "$SPECIES" --strain "$STRAIN" --sbt $SBT \
		-o $OUTDIR/$BASE --busco_db ${BUSCODB} --rename $LOCUS \
		"${ARGS[@]}"
done


