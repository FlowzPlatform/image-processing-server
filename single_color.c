#include <stdio.h>
#include <MagickWand/MagickWand.h>
#include <math.h>

#define PI 3.14159265


double *arguments(double r[],int i){
  double azimuth = 135;
  int depth = 6;

  r[0] = 0;
  r[1] = 0;
  r[2] = 1;
  r[3] = 0;
  if(i==1){
    r[4] = cos(0.78539816339) * depth/2;
    r[5] = sin(0.78539816339) * depth/2;
  }else{
    r[4] = -cos(0.78539816339) * depth/2;
    r[5] = -sin(0.78539816339) * depth/2;
  }
	return(r);
}
int emboss(){

  double r[6];
  MagickWand *wand = NULL;
  wand = NewMagickWand();

  MagickReadImage(wand,"binaryimage.gif");

  int test = MagickSetImageColorspace(wand, 3);
  printf("%d\n", test);
  MagickDistortImage(wand, ScaleRotateTranslateDistortion ,6, arguments(r,0) ,1);
  MagickDistortImage(wand, ScaleRotateTranslateDistortion ,6, arguments(r,1) ,1);
  MagickNegateImage(wand,1);
  MagickCompositeImage(wand, wand, BlendCompositeOp, 1, 0, 0);
  MagickWriteImages(wand,"binaryimage_c_emboss.gif",MagickTrue);

  wand=DestroyMagickWand(wand);
  MagickWandTerminus();

  return 1;
}

int main(int argc, char **argv) {
    // MagickWand items
    MagickWand *image = NULL;
    PixelWand *targetWhite = NULL;
    PixelWand *fillTransparent   = NULL;
    PixelWand *targetTransparent   = NULL;
    PixelWand *fill  = NULL;


    emboss();

    printf("%f\n", QuantumRange);
    // Convert 40% to double
    const double fuzz = 20*QuantumRange/100;

    MagickWandGenesis();

    // Setup Wand
    targetWhite = NewPixelWand();
    fillTransparent = NewPixelWand();
    targetTransparent = NewPixelWand();
    fill = NewPixelWand();
    image = NewMagickWand();

    // Load image
    MagickReadImage(image,"Morning.jpg");

    // Set Colors

    /*if white color present then make it transparent*/
    PixelSetColor(targetWhite,"white");
    PixelSetColor(fillTransparent,"transparent");

    /*change all colors to fill color except transparent*/
    PixelSetColor(targetTransparent,"transparent");
    PixelSetColor(fill,"white");

    // alternate way not working
    // PixelSetRed(target,35);
    // PixelSetGreen(target,31);
    // PixelSetBlue(target,32);
    //
    // PixelSetRed(fill,220);
    // PixelSetGreen(fill,12);
    // PixelSetBlue(fill,12);

    // Apply effect(wand,0.40);
    printf("%f\n", fuzz);
    printf("%f\n", QuantumRange);

    /*if white color present then make it transparent*/
    MagickOpaquePaintImage(image,targetWhite,fillTransparent,fuzz,MagickFalse);

    /*change all colors to fill color except transparent*/
    MagickOpaquePaintImage(image,targetTransparent,fill,fuzz,MagickTrue);

    // Save image
    MagickWriteImages(image,"MorningWhite.jpg",MagickTrue);

    // Clean up
    image=DestroyMagickWand(image);
    MagickWandTerminus();

    return 0;
}
