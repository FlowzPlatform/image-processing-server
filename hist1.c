#include "MagickWand/studio.h"
#include "MagickWand/MagickWand.h"
// #define DegreesToRadians(a) (a*M_PI/180.)
// #include "image-magick.c"
// #include <wand/MagickWand.h>
#include <math.h>

void sorting(size_t *x,size_t y, char color[]);

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


int main(int argc, const char * argv[]) {
    // Prototype vars
    MagickWand * wand, *wand1, *wand0;
    PixelWand ** histogram, *pwand;
    const double *arguments;
    typedef int bool;
    const char *DistortMethod[3];
    double r[6];
    DrawingWand *dw = NULL;

    PixelWand *PW1,*PW2,*PW3,*PW4;

    size_t histogram_count = 0;

    // Boot environment.
    MagickWandGenesis();
    // Allocate & read image
    wand = NewMagickWand();
    pwand = NewPixelWand();

    dw = NewDrawingWand();

    MagickReadImage(wand, "cnbc.jpg");


    dw = NewDrawingWand();

    PW1 = PW2 = PW3 = PW4 = PW5 = NewPixelWand();
    PixelSetColor(PW1,"white");
    PixelSetColor(PW2,"#cccccc");
    PixelSetColor(PW3,"black");
    PixelSetColor(PW4,"#333333");
    PixelSetColor(PW5,"#FFFFFF");



    // Get Histogram as array of pixels
    printf("%s\n", DistortMethod[0]);

    // printf("%lu\n", &histogram_count);
    // &histogram_count=8;
    MagickSetImageDepth(wand,8);

    histogram = MagickGetImageHistogram(wand, &histogram_count);
    // Iterate over each pixel & dump info.
    // printf("%lu\n", histogram_count);
    size_t colorcount[histogram_count];
    char *color[histogram_count];

    qsort(histogram,histogram_count,sizeof(PixelWand *),sort_hist);

    size_t i;
    wand1 = CloneMagickWand(wand);
    wand0 = CloneMagickWand(wand);

    for(i=histogram_count-1; i>=histogram_count-2; i--) {
        colorcount[i] =  PixelGetColorCount(histogram[i]);
        color[i] = PixelGetColorAsString(histogram[i]);

        printf("%s => %zu\n",
               color[i],
              colorcount[i]);

        //-size 1x1 xc:#E36612
        MagickSetImageColormapColor(wand,1,histogram[i]);
        MagickAppendImages(wand, MagickTrue);

    }

    /*UndefinedDitherMethod
    NoDitherMethod
    RiemersmaDitherMethod
    FloydSteinbergDitherMethod*/

    // +dither -remap
    MagickRemapImage(wand1, wand, NoDitherMethod);

    //gradient
    MagickSetImageMatte(wand, MagickTrue);

    // -size 2x8
    MagickResizeImage(wand0, 2,8, GaussianFilter);

    //rotate
    MagickRotateImage(wand,pwand,270);

    // -roll +2+0
    MagickRollImage(wand0, 2, 0);

    //-roll +4+0
    MagickRollImage(wand0, 4, 0);

    //-roll +6+0
    MagickRollImage(wand0, 6, 0);

    //-append
    MagickAppendImages(wand, MagickTrue);

    //   MagickMontageImage(MagickWand *wand,
    // const DrawingWand drawing_wand,const char *tile_geometry,
    // const char *thumbnail_geometry,const MontageMode mode,
    // const char *frame)

    MagickMontageImage(wand, dw, "6x4+0+0", "1200x874+4+3",UndefinedMode,"15x15+3+3");

    // -define compose:args=100
    MagickSetImageArtifact(wand, "compose:args", "100");

    //-compose blend -composite
    MagickCompositeImage(wand, wand0, BlendCompositeOp,MagickFalse, 0, 0);


    //-fuzz 20%
    //-fill 'gray(80%)' -opaque white
    MagickOpaquePaintImage(wand,PW1,PW2,20*QuantumRange/100,MagickFalse);

    //-fuzz 20%
    //-fill 'gray(20%)' -opaque black
    MagickOpaquePaintImage(wand,PW3,PW4,20*QuantumRange/100,MagickFalse);

    /*this will be in a loop according to number of colors chhosen*/

    //+transparent '#FFFFFF' -alpha extract
    MagickTransparentPaintImage(wand, PW5, 1.0, 0, MagickFalse);

    // -rotate -45 +repage -gravity center -crop 600x437+0+0 +repage
    MagickRotateImage(wand,pwand,-45);
    MagickSetImageGravity(wand, CenterGravity);
    MagickCropImage(wand, 437, 600, 0, 0);
    MagickResetImagePage(wand,"600x437+0+0");

    // -clone 0 -clone 2 -compose softlight -composite
    // wand0 = CloneMagickWand(wand);
    // wand2 = CloneMagickWand(wand);
    // MagickCompositeImage(wand, wand0, LinearDodgeCompositeOp,MagickFalse, 0, 0);
    // MagickCompositeImage(wand, wand2, LinearDodgeCompositeOp,MagickFalse, 0, 0);

    // -delete 0,2
    // DestroyMagickWand(wand0);
    // DestroyMagickWand(wand2);

    //+swap -compose over -alpha off -compose copy_opacity -composite '(' -clone 0 -background black -shadow 25x2+0+0 -channel A -level 0,50% +channel ')' +swap +repage -gravity center -compose over -composite ./EMBROIDERY.22607/tmpI_0.mpc

    /*And loop ends here*/

    // sorting(colorcount,histogram_count, *color);

    // Clean-up
    MagickWriteImage(wand,"cnbcjpg_m.jpg");
    if(wand)wand = DestroyMagickWand(wand);
    if(dw)dw = DestroyDrawingWand(dw);
    DestroyPixelWand(*histogram);
    MagickWandTerminus();
    return 0;
}
void sorting(size_t *x, size_t y, char color[])
{
  size_t i,j,temp;
  size_t index[y];
  size_t temp2;
  printf("%s\n", &color[0]);

  for(i = 1; i <= y-1; i++)
  {
    for(j = 0; j < y-i; j++)
    {
      // printf("%zu\n", *(x+j));
      if(*(x+j) <*(x+j+1))
      {
        temp = *(x+j);
        *(x+j) = *(x+j+1);
        *(x+j+1) = temp;

        // temp2 = ;
        // j = j+1;
        // j+1 = temp2
        // &color[j+1] = temp2;
      }
    }
  }
  for(i = 0; i < 5; i++)
  {
    printf("\n%zu",*(x+i));
    printf("\n%s",&color[0]);
    x[i] =*(x+i);
  }
}
