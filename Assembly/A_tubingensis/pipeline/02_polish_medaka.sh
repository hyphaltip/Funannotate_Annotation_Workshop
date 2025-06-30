#!/usr/bin/bash -l
#SBATCH -N 1 -n 1 -c 16 --mem 64gb --out logs/polish_medaka.log -p gpu --gres=gpu:1
#SBATCH -w gpu07
module load medaka
module load workspace/scratch

# this is the nanopore chemistry/flowcell type used
MODEL=r1041_e82_400bps_sup_v4.3.0
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

echo $SCRATCH
# run medaka or racon as necessary
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

do_medaka() {
    CPUIN=$1
    MODEL=$2
    OUTDIR=$3
    NANOREADS=$4
    TYPE=$5
    DRAFT=$6
    POLISHED=$OUTDIR/$TYPE.medaka
    mkdir -p $POLISHED
    echo "$CPUIN $MODEL type=$TYPE asm=$DRAFT outdir=$POLISHED reads=$NANOREADS"
    if [ ! -f $POLISHED/calls_to_draft.bam ]; then
        echo "Running medaka_consensus"
    else
        echo "Skipping medaka_consensus, already done"
        return 0
    fi
    medaka_consensus -i $NANOREADS -d $DRAFT -o $POLISHED -t $CPUIN -m $MODEL
    
}

export -f do_medaka 

parallel --link -j 2 do_medaka 8 $MODEL $OUTDIR $INDIR/${NANOBASE}_filtered_U.fastq.gz ::: flye hifiasm hifiasm.2libs unicycler ::: $FLYE $HIFIASM $HIFIASM2LIB $UNICYCLER
