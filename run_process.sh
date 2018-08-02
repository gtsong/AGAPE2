#!/bin/sh

strain_name=$1
out_dir=$2
fasta=$3
SCRIPT=$4

comb_annot=$out_dir/comb_annot
. $SCRIPT/configs.cf

process_dir=$comb_annot/process_result
mkdir -p $process_dir
cd $process_dir
mkdir -p $strain_name

less $comb_annot/gff/$strain_name.gff.sorted | grep -v 'UNDEF' > $strain_name.blastUsage.gff
grep 'gene' $comb_annot/gff/$strain_name.gff.sorted | grep -v 'UNDEF' > $strain_name.bedUsage.gff
grep 'gene' $REF_GFF > $REF_NAME.gff

$SGD/gen_sgd_data.sh $strain_name $process_dir/$strain_name $fasta $strain_name.blastUsage.gff

$BLAST/blastp -query $strain_name/pep/$strain_name.pep.fsa -subject $PROTEIN1 -outfmt 6 -out $strain_name.blastp

$SCRIPT/conv_gff_form.py $strain_name.bedUsage.gff > $strain_name.conv.gff

$QUOTA/scripts/gff_to_bed.py $strain_name.conv.gff > $strain_name.bed
$QUOTA/scripts/gff_to_bed.py $REF_NAME.gff > $REF_NAME.bed
$QUOTA/scripts/blast_to_raw.py $strain_name.blastp --qbed $strain_name.bed --sbed $REF_NAME.bed --filter_repeats --write-filtered-blast > $strain_name.blast.raw
$QUOTA/scripts/synteny_score.py $strain_name.blast.raw --qbed $strain_name.bed --sbed $REF_NAME.bed
$QUOTA/scripts/bed_to_gff.py $comb_annot/gff/$strain_name.gff.sorted $strain_name.bed_corrected




