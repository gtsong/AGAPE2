#!/bin/sh -l

utils_dir=/home/ubuntu/AGAPE/programs/sequence_format/utils.d

strain_name=$1
out_dir=$2
fasta=$3
gff_file=$4

temp_dir=$out_dir/temp
mkdir -p $temp_dir
rm -rf $temp_dir/*

mkdir -p $out_dir/valid_gff
mkdir -p $out_dir/cds
mkdir -p $out_dir/pep

rm -rf $out_dir/valid_gff/$strain_name.gff
rm -rf $out_dir/cds/$strain_name.cds.fsa
rm -rf $out_dir/pep/$strain_name.pep.fsa
count=1
is_skip=false
while read gff_line 
do
	type=`echo $gff_line | awk '{print $3}'`
	if [ $count -eq 1 ]
	then
		echo $gff_line > $temp_dir/temp.gff
		gname=`echo $gff_line | awk '{print $9}' | awk -F',' '{print $1}'`
		scf_name=`echo $gff_line | awk '{print $1}'`
		count=`expr $count + 1`
		g_b=`echo $gff_line | awk '{print $4}'`
		g_e=`echo $gff_line | awk '{print $5}'`
		if [ $g_b -le 0 ] || [ $g_e -le 0 ] 
		then
			is_skip=true
		else 
			is_skip=false
		fi
	elif [ $type = "CDS" ]
	then 
		if [ "$is_skip" = "false" ]
   	then
			echo $gff_line >> $temp_dir/temp.gff
			b=`echo $gff_line | awk '{print $4}'`
			e=`echo $gff_line | awk '{print $5}'`
			if [ $b -le 0 ] || [ $e -le 0 ] 
			then
				is_skip=true
				echo "" > $temp_dir/temp.gff
			fi
		fi
		count=`expr $count + 1`
	else 
		if [ "$is_skip" = "false" ]
		then
#			head_line=`head -1 $temp_dir/temp.gff`
#			echo $head_line
			$utils_dir/pull_fasta_scaf $fasta $scf_name > $temp_dir/temp.fasta
			scf_len=`head -1 $temp_dir/temp.fasta | awk '{print $2}'`
			$utils_dir/gff2codex $temp_dir/temp.gff CDS $gname > $temp_dir/temp.codex
			$utils_dir/reverse_exon_order $temp_dir/temp.codex > $temp_dir/temp.ordered.codex
			$utils_dir/pull_c $temp_dir/temp.fasta $temp_dir/temp.ordered.codex GENE_NAME_FIRST > $temp_dir/temp.orf.fasta
 		  	$utils_dir/dna2aa -v $temp_dir/temp.orf.fasta 1 > $temp_dir/temp.aa
 		  	tf=`$utils_dir/check_aa $temp_dir/temp.gff $temp_dir/temp.aa BOOLEAN_OUTPUT`
			if [ "$tf" = "true" ] 
			then
				less $temp_dir/temp.gff >> $out_dir/valid_gff/$strain_name.genes.gff
				less $temp_dir/temp.orf.fasta >> $out_dir/cds/$strain_name.cds.fsa
				less $temp_dir/temp.aa >> $out_dir/pep/$strain_name.pep.fsa
			fi
		fi

		count=`expr $count + 1`
		echo $gff_line > $temp_dir/temp.gff
		gname=`echo $gff_line | awk '{print $9}' | awk -F',' '{print $1}'`
		scf_name=`echo $gff_line | awk '{print $1}'`
		g_b=`echo $gff_line | awk '{print $4}'`
		g_e=`echo $gff_line | awk '{print $5}'`
		if [ $g_b -le 0 ] || [ $g_e -le 0 ] 
		then
			is_skip=true
		else 
			is_skip=false
		fi
	fi
done < $gff_file

if [ $type = "CDS" ]
then
	if [ "$is_skip" = "false" ]
	then
#		head_line=`head -1 $temp_dir/temp.gff`
#		echo $head_line
		$utils_dir/pull_fasta_scaf $fasta $scf_name > $temp_dir/temp.fasta
		scf_len=`head -1 $temp_dir/temp.fasta | awk '{print $2}'`
		$utils_dir/gff2codex $temp_dir/temp.gff CDS $gname > $temp_dir/temp.codex
		$utils_dir/reverse_exon_order $temp_dir/temp.codex > $temp_dir/temp.ordered.codex
		$utils_dir/pull_c $temp_dir/temp.fasta $temp_dir/temp.ordered.codex GENE_NAME_FIRST > $temp_dir/temp.orf.fasta
 	 	$utils_dir/dna2aa -v $temp_dir/temp.orf.fasta 1 > $temp_dir/temp.aa
 		tf=`$utils_dir/check_aa $temp_dir/temp.gff $temp_dir/temp.aa BOOLEAN_OUTPUT`

		if [ "$tf" = "true" ] 
		then
			less $temp_dir/temp.gff >> $out_dir/valid_gff/$strain_name.genes.gff
			less $temp_dir/temp.orf.fasta >> $out_dir/cds/$strain_name.cds.fsa
			less $temp_dir/temp.aa >> $out_dir/pep/$strain_name.pep.fsa
		fi
	fi
fi

sed -i 's/maker/agape/' $out_dir/valid_gff/$strain_name.genes.gff
