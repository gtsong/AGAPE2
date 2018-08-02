#include "util.h"

#define MIN_LEN 300

int main(int argc, char *argv[]) {
	FILE *f = NULL;
	char buf[1000];
	int b = 0, e = 0;
	bool is_over_min = false;

	if((argc != 2) || ((f = ckopen(argv[1], "r")) == NULL) )
	{
		fatalf("Cannot open file %s\n", argv[1]);
	}
	
	while( fgets(buf, 10000, f)) { 
		if((buf[0] == '>') || (buf[0] == '<')) {
			is_over_min = false;
			if( sscanf(buf, "%*s %d %d %*s", &b, &e) == 2 ) {
				if( (e - b + 1) >= MIN_LEN ) {
					is_over_min = true;
				}
			}	

			if( is_over_min == true ) printf("%s", buf);
		}
		else {
			if( is_over_min == true ) printf("%s", buf);
		}
	}
	
	fclose(f);

	return EXIT_SUCCESS;
}
