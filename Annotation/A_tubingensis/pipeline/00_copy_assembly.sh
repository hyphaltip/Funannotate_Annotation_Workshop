#!/usr/bin/bash -l
#SBATCH -p short

module load AAFTF


# HARD CODING THIS FOR THE TUTORIAL
# WE WOULD DO A CHOOSE THE BEST ASSEMBLY PROCESS OTHERWISE
PREFIX=A_tubingensis
IN=../../Assembly/A_tubingensis/assemblies/unicycler_filt_merged_reads/assembly.fasta
OUT=genomes

mkdir -p $OUT
perl -p -e 's/>(\S+).+/>$1/' $IN > $OUT/$PREFIX.unicycler.fasta
AAFTF sort -i $OUT/$PREFIX.unicycler.fasta -o $OUT/$PREFIX.sorted.fasta 
AAFTF assess -i $OUT/$PREFIX.sorted.fasta -r $OUT/$PREFIX.sorted.stats.txt
