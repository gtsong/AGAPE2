#/bin/sh

strain_name=$1
out_dir=$2
fasta=$3
SCRIPTS=$4
width=50

comb_annot=$out_dir/comb_annot
. $SCRIPTS/configs.cf

process_dir=$comb_annot/process_result
mkdir -p $process_dir

cd $process_dir

grep -P "\tgene\t" $REF_GFF > $process_dir/$REF_NAME.gff
$QUOTA/scripts/gff_to_bed.py $process_dir/$REF_NAME.gff > $process_dir/$REF_NAME.bed

temp_dir=$process_dir/temp
mkdir -p $temp_dir
cd $temp_dir

less $comb_annot/gff/$strain_name.gff.scfname > $temp_dir/scf.list

while read scf_line
do

        scf_name=`echo $scf_line`
        less $comb_annot/gff/temp/$scf_name.gff.sorted.rmdup | grep -v 'UNDEF' > $temp_dir/$scf_name.blastUsage.gff
        grep "gene" $comb_annot/gff/temp/$scf_name.gff.sorted.rmdup | grep -v 'UNDEF' > $temp_dir/$scf_name.bedUsage.gff

        $SGD/gen_sgd_data.sh $strain_name $temp_dir/$scf_name $fasta $temp_dir/$scf_name.blastUsage.gff $SGD
        $BLAST/blastp -query $temp_dir/$scf_name/pep/$strain_name.pep.fsa -subject $PROTEIN1 -outfmt 6 -out $temp_dir/$scf_name.blastp

        $SCRIPTS/conv_gff_form.py $temp_dir/$scf_name.bedUsage.gff > $temp_dir/$scf_name.conv.gff
        $QUOTA/scripts/gff_to_bed.py $temp_dir/$scf_name.conv.gff > $temp_dir/$scf_name.bed
        $QUOTA/scripts/blast_to_raw.py $scf_name.blastp --qbed $temp_dir/$scf_name.bed --sbed $process_dir/$REF_NAME.bed --filter_repeats --write-filtered-blast > $temp_dir/$scf_name.blast.raw

        wid=5
        while [ $wid -le $width ];
        do
          $QUOTA/scripts/synteny_score.py $temp_dir/$scf_name.blast.raw --qbed $temp_dir/$scf_name.bed --sbed $process_dir/$REF_NAME.bed --width $wid;
          wid=$((wid+5));
        done

        $QUOTA/scripts/bed_to_gff.py $comb_annot/gff/temp/$scf_name.gff.sorted.rmdup $temp_dir/$scf_name.bed

done < $temp_dir/scf.list

while read scf_line
do
        scf_name=`echo $scf_line`
        cat $comb_annot/gff/temp/$scf_name.gff.sorted.rmdup.modified >> $comb_annot/gff/$strain_name.gff.sorted.rmdup.modified
done < $temp_dir/scf.list


# merge scaffold
$SCRIPTS/compare_CDS.py $comb_annot/gff/$strain_name.gff.sorted.rmdup.modified $REF_GFF $fasta $comb_annot/gff/$strain_name.gff.scfname > $comb_annot/gff/$strain_name.gff.final
