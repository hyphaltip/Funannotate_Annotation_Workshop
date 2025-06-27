#!/usr/bin/bash -l
#SBATCH -c 24 --mem 24gb --out logs/AAFTF_cleanup.log

module load AAFTF
CPU=8
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

MEM=24
INDIR=../../Dataset/A_tubingensis/input
OUTREADS=input
WORKDIR=work
mkdir -p $OUTREADS $WORKDIR
#SRA READS
BASE=SRR29740273
LEFTIN=$INDIR/${BASE}_1.fastq.gz
RIGHTIN=$INDIR/${BASE}_2.fastq.gz


if [ ! -f $LEFTIN ]; then
    echo "no $LEFTIN file for $BASE in $INDIR dir"
    exit
fi
LEFTTRIM=$WORKDIR/${BASE}_1P.fastq.gz
RIGHTTRIM=$WORKDIR/${BASE}_2P.fastq.gz
MERGETRIM=$WORKDIR/${BASE}_fastp_MG.fastq.gz
LEFT=$OUTREADS/${BASE}_filtered_1.fastq.gz
RIGHT=$OUTREADS/${BASE}_filtered_2.fastq.gz
MERGED=$OUTREADS/${BASE}_filtered_U.fastq.gz

if [ ! -f $LEFT ]; then
	if [ ! -f $LEFTTRIM ]; then
        # run fastp to trim and filter reads
        # first pass does merging and deduplication
        # second pass does right trimming
        # third pass does bbduk filtering
        AAFTF trim --method fastp --dedup --merge --memory $MEM --left $LEFTIN --right $RIGHTIN -c $CPU \
        -o $WORKDIR/${BASE}_fastp -ml 50
        
        AAFTF trim --method fastp --cutright -c $CPU --memory $MEM \
        --left $WORKDIR/${BASE}_fastp_1P.fastq.gz \
        --right $WORKDIR/${BASE}_fastp_2P.fastq.gz -o $WORKDIR/${BASE}_fastp2 -ml 50
        
        AAFTF trim --method bbduk -c $CPU --memory $MEM \
        --left $WORKDIR/${BASE}_fastp2_1P.fastq.gz \
        --right $WORKDIR/${BASE}_fastp2_2P.fastq.gz \
        -o $WORKDIR/${BASE} -ml 50
    fi
    # remove phage and contamination reads
	AAFTF filter -c $CPU --memory $MEM -o $OUTREADS/${BASE} --left $LEFTTRIM --right $RIGHTTRIM --aligner bbduk
	AAFTF filter -c $CPU --memory $MEM -o $OUTREADS/${BASE} --left $MERGETRIM --aligner bbduk
	if [ -f $LEFT ]; then
        rm -f $LEFTTRIM $RIGHTTRIM $WORKDIR/${BASE}_fastp*
        echo "found $LEFT"
	else
        echo "did not create left file ($LEFT $RIGHT)"
        exit
	fi
fi

# now map and clean the nanopore
BASE=SRR29740272
LEFTIN=$INDIR/${BASE}_1.fastq.gz
AAFTF filter -c $CPU --mem $MEM -o $OUTREADS/${BASE} --left ${LEFTIN} --aligner bbduk
if [ -f $OUTREADS/${BASE}_filtered_U.fastq.gz ]; then
    echo "filtered nanopore reads into $OUTREADS/${BASE}_filtered_U.fastq.gz"
else
    echo "did not create nanopore reads file ($OUTREADS/${BASE}_filtered_U.fastq.gz)"
    exit
fi
