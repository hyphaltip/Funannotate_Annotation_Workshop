#!/usr/bin/bash -l

module load AAFTF

echo "these are examples"
CPU=4
ASMFILE=polished.fasta
VECCLEAN=vectrim.fasta
PURGE=sourpurge.fasta
FCSCLEAN=fcsclean.fasta
TAXID=5052 #Aspergillus
AAFTF vecscreen -i $ASMFILE -c $CPU -o $VECCLEAN
AAFTF sourpurge -i $VECCLEAN -o $PURGE -c $CPU --phylum $PHYLUM --left $LEFT --right $RIGHT

# need to setup the NCBI gxdb db - this requires a lot of space (512GB)
AAFTF fcs_gx_purge  --db /dev/shm/gxdb/all  -i $PURGE --cpus $CPU -o $FCSCLEAN -t ${TAXID} -w fcs_gx.report
