#include "MagickWand/studio.h"
#include <MagickWand/MagickWand.h>
// int sort_hist(PixelWand **p,PixelWand **q)
int sort_hist(const void *p1, const void *q1)
{
	const PixelWand **pixels = p1;
	const PixelWand **pixels1 = q1;

	size_t ip,iq;
	ip = PixelGetColorCount(*pixels);
	iq = PixelGetColorCount(*pixels1);
	if(ip > iq)return(1);
	if(ip < iq)return(-1);
	return(0);
}
void test_wand(void)
{
	MagickWand *mw = NULL;
// Comment out this define to use the region iterator instead of the Draw
//#define USE_DRAW
	PixelWand **pixels = NULL;
	size_t i,num_colours;
	char *pc;
	FILE *fo = NULL;

	MagickWandGenesis();

	/* Create a wand */
	mw = NewMagickWand();

	/* Read the input image */
	MagickReadImage(mw,"cnbc.jpg");
	// fo = fopen("logo.txt","w");
	pixels = MagickGetImageHistogram(mw,&num_colours);
if(1) {
	// Optionally sort them into ascending order of frequency
	qsort(pixels,num_colours,sizeof(PixelWand *),sort_hist);
}
printf("%zu\n", num_colours);
	for(i=num_colours-1; i>=num_colours-8; i--) {
		// fprintf(fo,"%6d: (",PixelGetColorCount(pixels[i]));
		// fprintf(fo,"%d, ",PixelGetRedQuantum(pixels[i]));
		// fprintf(fo,"%d, ",PixelGetGreenQuantum(pixels[i]));
		// fprintf(fo,"%d, ",PixelGetBlueQuantum(pixels[i]));
		// fprintf(fo,"%d)",PixelGetAlphaQuantum(pixels[i]));

		// printf("%s\n", PixelGetColorAsString(pixels[i]));
		// printf("%zu\n", PixelGetColorCount(pixels[i]));
		printf("%s => %zu\n",
					 PixelGetColorAsString(pixels[i]),
					PixelGetColorCount(pixels[i]));

		MagickSetImageColormapColor(mw,1,pixels[i]);
if(1) {
		// pc = PixelGetColorAsString(pixels[i]);
		// fprintf(fo," %s",pc);
		// Must destroy the string once it is no longer required
		// DestroyString(pc);
}
		// fprintf(fo,"\n");
	}

	// fclose(fo);
	// Free up the PixelWand array
	RelinquishMagickMemory(pixels);
	if(mw) mw = DestroyMagickWand(mw);

	MagickWandTerminus();
}

int main(int argc, const char * argv[]) {
	test_wand();
}
