#include "main.h"
#include "util.h"
#include "util_i.h"
#include "util_genes.h"

int main(int argc, char *argv[]) {
	FILE *f;
//	int b = 0, e = 0;
	char buf[10000], type[100];
//	int sum = 0;
	struct g_list *genes1;
	struct exons_list *exons1;
	int num_genes1 = 0;
	int num_exons1 = 0;	
	int num = 0;
	int i = 0, j = 0;
	char seq_name[100];

	strcpy(seq_name, "");
	if( argc == 3 ) {
		strcpy(seq_name, argv[3]);
	}
	else if( argc != 2 ) {
		fatal("merge_gff codex (seq_name)\n");
	}
	
	strcpy(buf, "");
	strcpy(type, "");

	if((f = ckopen(argv[1], "r")) == NULL )
	{
		fatalf("Cannot open file %s\n", argv[1]);
	}
	else {
		num_genes1 = count_genes(f, &num_exons1);

		if( num_genes1 > 0 ) {
			genes1 = (struct g_list *) ckalloc(num_genes1 * sizeof(struct g_list));	
			exons1 = (struct exons_list *) ckalloc(num_exons1 * sizeof(struct exons_list));	
			if( num_exons1 < num_genes1 ) num_exons1 = num_genes1;
			initialize_genes(genes1, num_genes1);
			initialize_exons(exons1, num_exons1);
		}
	}
	fseek(f, 0, SEEK_SET);
	
	num = input_genes(f, genes1, exons1);	
	if( num != num_genes1 ) {
		fatalf("gene counter error in %s\n", argv[1]);
	}

	if( num_genes1 > 0 ) {
		quick_sort_inc_genes(genes1, 0, num_genes1-1, POS_BASE);
	}
	i = 0;
	while( i < num_genes1 ) {
		j = 0;
    while( ((i+j) < num_genes1) && (genes1[i].txStart == genes1[i+j].txStart )) j++;
    quick_sort_dec_genes(genes1, i, i+j-1, LEN_BASE);
    i = i+j;
	}

	if( num_genes1 > 0 ) {
		num_genes1 = rm_redun_genes(genes1, 0, num_genes1-1);
		num_exons1 = count_exons(genes1, 0, num_genes1-1);
	}

	if( num_genes1 > 0 ) {
		quick_sort_inc_genes(genes1, 0, num_genes1-1, POS_BASE);
	}
	i = 0;
	while( i < num_genes1 ) {
		j = 0;
    while( ((i+j) < num_genes1) && (genes1[i].txStart == genes1[i+j].txStart )) j++;
    quick_sort_dec_genes(genes1, i, i+j-1, LEN_BASE);
    i = i+j;
	}

	write_in_gff(genes1, num_genes1, exons1, num_exons1);

	if( num_genes1 > 0 ) {
		free(genes1);
		free(exons1);
	}

	fclose(f);
	return EXIT_SUCCESS;
}
