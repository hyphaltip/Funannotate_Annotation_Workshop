#!/usr/bin/bash -l
#SBATCH -N 1 -n 1 -c 32 --mem 64gb --out logs/polish_polca.log
module load workspace/scratch
module load AAFTF

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

SCRATCH=/tmp/$$
mkdir -p $SCRATCH

echo $SCRATCH
# run POLCA polishing as necessary
#
INDIR=input
OUTDIR=assemblies/polished
mkdir -p $OUTDIR
FLYE=assemblies/flye/assembly.fasta
HIFIASM=assemblies/hifiasm/Atub_ONT.bp.p_ctg.fa
HIFIASM2LIB=assemblies/hifiasm.2libs/Atub_hifi.asm.bp.p_ctg.fa
UNICYCLER=assemblies/unicycler_filt_merged_reads/assembly.fasta

NANOBASE=SRR29740272
ILLBASE=SRR29740273
do_polca() {
    CPUIN=$1
    OUTDIR=$2
    LEFT=$3
    RIGHT=$4
    TYPE=$5
    DRAFT=$OUTDIR/$TYPE.medaka/polished.fasta
    POLISHED=$OUTDIR/$TYPE.polished.fasta

    if [[ ! -f $POLISHED ]]; then
        AAFTF polish -l $LEFT -r $RIGHT  -i $DRAFT \
        --polca $(which polca.sh) -c $CPUIN --mem 16gb -it 5
    fi
}

export -f do_polca
parallel --link -j 4 do_polca 8 $OUTDIR $INDIRRAW/${ILLBASE}_1.fastq.gz $INDIRRAW/${ILLBASE}_2.fastq.gz ::: flye hifiasm hifiasm.2libs unicycler 

rm -rf $SCRATCH