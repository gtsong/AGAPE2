#/bin/sh

strain_name=$1
out_dir=$2
fasta=$3
SCRIPT=$4
width=50

comb_annot=$out_dir/comb_annot
. $SCRIPT/configs.cf

process_dir=$comb_annot/process_result
post_process_dir=$comb_annt/postprocess
mkdir -p $process_dir
mkdir -p $post_process_dir

cd $process_dir
mkdir -p $strain_name

less $comb_annot/gff/$strain_name.gff.sorted.rmdup | grep -v 'UNDEF' > $strain_name.blastUsage.gff
grep "gene" $comb_annot/gff/$strain_name.gff.sorted.rmdup | grep -v 'UNDEF' > $strain_name.bedUsage.gff
grep -P "\tgene\t" $REF_GFF > $REF_NAME.gff

$SGD/gen_sgd_data.sh $strain_name $process_dir/$strain_name $fasta $strain_name.blastUsage.gff $SGD

$BLAST/blastp -query $strain_name/pep/$strain_name.pep.fsa -subject $PROTEIN1 -outfmt 6 -out $strain_name.blastp

$SCRIPT/conv_gff_form.py $strain_name.bedUsage.gff > $strain_name.conv.gff

$QUOTA/scripts/gff_to_bed.py $strain_name.conv.gff > $strain_name.bed
$QUOTA/scripts/gff_to_bed.py $REF_NAME.gff > $REF_NAME.bed
$QUOTA/scripts/blast_to_raw.py $strain_name.blastp --qbed $strain_name.bed --sbed $REF_NAME.bed --filter_repeats --write-filtered-blast > $strain_name.blast.raw

wid=5
while [ $wid -le $width ];
do
  $QUOTA/scripts/synteny_score.py $strain_name.blast.raw --qbed $strain_name.bed --sbed $REF_NAME.bed --width $wid;
  wid=$((wid+5));
done

$QUOTA/scripts/bed_to_gff.py $comb_annot/gff/$strain_name.gff.sorted.rmdup $strain_name.bed

$SCRIPT/compare_CDS.py $comb_annot/gff/$strain_name.gff.sorted.rmdup.modified $REF_GFF $REF_FASTA > $comb_annot/gff/$strain_name.gff.final
