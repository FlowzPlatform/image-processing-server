#include "MagickWand/studio.h"
#include "MagickWand/MagickWand.h"
// #define DegreesToRadians(a) (a*M_PI/180.)
// #include "image-magick.c"
// #include <wand/MagickWand.h>
#include <math.h>

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
/*
	wand0
	./EMBROIDERY.8801/tmpI.mpc
			+ convert -quiet cnbc.jpg +repage -depth 8 ./EMBROIDERY.8801/tmpI.mpc
			++ convert -ping ./EMBROIDERY.8801/tmpI.mpc -format %w info:
			++ convert -ping ./EMBROIDERY.8801/tmpI.mpc -format %h info:
			+ colorArr=(`convert $dir/tmpI.mpc -format "%c" histogram:info: |sort -k 1 -nr | head -n $numcolors | sed -n "s/^.*\(#.*\) .*$/\1/p"`)
			++ convert ./EMBROIDERY.8801/tmpI.mpc -format %c histogram:info:

	wand1
	./EMBROIDERY.8801/tmpL.mpc
			+ convert -size 1x1 xc:#FFFFFF ./EMBROIDERY.8801/tmpL.mpc
			+ convert ./EMBROIDERY.8801/tmpL.mpc '(' -size 1x1 xc:#0A0B0D ')' +append ./EMBROIDERY.8801/tmpL.mpc
			+ convert ./EMBROIDERY.8801/tmpI.mpc +dither -remap ./EMBROIDERY.8801/tmpL.mpc ./EMBROIDERY.8801/tmpI.mpc

	wand2
	./EMBROIDERY.8801/tmpP.mpc
			+ convert -size 2x8 gradient: -rotate 270 '(' -clone 0 -roll +2+0 ')' '(' -clone 0 -roll +4+0 ')' '(' -clone 0 -roll +6+0 ')' -append -write mpr:tile +delete -size 1200x874 tile:mpr:tile '(' -clone 0 -spread 1 ')' -define compose:args=100 -compose blend -composite ./EMBROIDERY.8801/tmpP.mpc

	wand3
	./EMBROIDERY.8801/tmpR.mpc
			+ convert ./EMBROIDERY.8801/tmpI.mpc -fuzz 20% -fill 'gray(80%)' -opaque white -fill 'gray(20%)' -opaque black ./EMBROIDERY.8801/tmpR.mpc

	// loop
	./EMBROIDERY.8801/tmpI_0.mpc
	./EMBROIDERY.8801/tmpI_1.mpc


*/

int main(int argc, const char * argv[]) {
    // Prototype vars
    MagickWand * wand, *wand0, *wand1, *wand2, *wand3, *wand4,*wand5,*wand6,*wand7,*wand8;
    PixelWand ** histogram, *pwand;
    const double *arguments;
    typedef int bool;
    const char *DistortMethod[3];
    double r[6];
    DrawingWand *dw = NULL;

    PixelWand *PW1,*PW2,*PW3,*PW4, *PW5, *PW6;

    size_t histogram_count = 0;

    // Boot environment.
    MagickWandGenesis();
    // Allocate & read image
    wand = NewMagickWand();
    pwand = NewPixelWand();
    dw = NewDrawingWand();

    MagickReadImage(wand, "cnbc.jpg");



    PW1 = PW2 = PW3 = PW4 = PW5 = PW6 = NewPixelWand();
    PixelSetColor(PW1,"white");
    PixelSetColor(PW2,"#cccccc");
		PixelSetColor(PW3,"black");
		PixelSetColor(PW6,"black");
    PixelSetColor(PW4,"#333333");
    PixelSetColor(PW5,"#FFFFFF");


    // Get Histogram as array of pixels

    // printf("%lu\n", &histogram_count);
    // &histogram_count=8;
		wand0 = CloneMagickWand(wand);
    MagickSetImageDepth(wand0,8);

    histogram = MagickGetImageHistogram(wand0, &histogram_count);
    // Iterate over each pixel & dump info.
    // printf("%lu\n", histogram_count);
    size_t colorcount[histogram_count];
    char *color[histogram_count];

    qsort(histogram,histogram_count,sizeof(PixelWand *),sort_hist);

    size_t i;
    wand1 = CloneMagickWand(wand0);
		wand2 = CloneMagickWand(wand0);
		wand3 = CloneMagickWand(wand0);
		wand4 = CloneMagickWand(wand0);
		wand5 = CloneMagickWand(wand0);

    for(i=histogram_count-1; i>=histogram_count-2; i--) {
        colorcount[i] =  PixelGetColorCount(histogram[i]);
        color[i] = PixelGetColorAsString(histogram[i]);

        printf("%s => %zu\n",
               color[i],
              colorcount[i]);

        //-size 1x1 xc:#E36612
        MagickSetImageColormapColor(wand1,1,histogram[i]);
        MagickAppendImages(wand1, MagickTrue);
    }

		
    // Clean-up
    MagickWriteImage(wand,"cnbcjpg_m.jpg");
    if(wand)wand = DestroyMagickWand(wand);
    if(dw)dw = DestroyDrawingWand(dw);
    DestroyPixelWand(*histogram);
    MagickWandTerminus();
    return 0;
}
