/*
  convert rose: -background black -gravity south -splice 0x8 \
          \( +clone -sparse-color barycentric '0,0 black 69,0 white' \) \
          \( +clone -function arcsin 0.5 \) \
          \( -clone 1 -level 25%,75% \
                 -function polynomial -4,4,0 -gamma 2 \
                 +level 50%,0 \) \
          -delete 1 -swap 0,1  miff:- |\
     composite - -virtual-pixel black  -displace 17x7  rose_cylinder.png
*/

#include "MagickWand/studio.h"
#include "MagickWand/MagickWand.h"

int main(int argc, const char * argv[]) {
    MagickWand * wand, *wand0, *wand1, *wand2, *wand3;
    PixelWand *PW1,*PW2,*PW3;

    wand = NewMagickWand();
    PW1 = PW2 = PW3 = NewPixelWand();

    MagickReadImage(wand, "cnbc.jpg");

    // -background black
    PixelSetColor(PW1,"#000000");
    MagickSetImageBackgroundColor(wand, PW1);

    // -gravity south
    MagickSetImageGravity(wand, SouthGravity);

    // south -splice 0x8
    MagickSpliceImage(wand, 100, 100, 0, 8);

    //  +clone -sparse-color barycentric '0,0 black 69,0 white'
    const double *arguments[3];
    arguments[0] = "0";
    arguments[1] = "0 black 69";
    arguments[2] = "0 white";

    wand0 = CloneMagickWand(wand);
    MagickSparseColorImage(wand0, BarycentricColorInterpolate, 3,*arguments);

    // +clone -function arcsin 0.5
    const double *argumentsF[1];
    argumentsF[0] = "0.5";
    MagickFunctionImage(wand0, ArcsinFunction, 1, *argumentsF);

    //-clone 1 -level 25%,75% \
           -function polynomial -4,4,0 -gamma 2 \
           +level 50%,0

    MagickLevelImage(wand0, QuantumRange/4, 1.0, 0);
    MagickLevelImage(wand0, QuantumRange*3/4, 1.0, 0);

    const double *argumentsFF[3];
    argumentsF[0] = -4;
    argumentsF[1] = 4;
    argumentsF[2] = 0;
    MagickFunctionImage(wand0, PolynomialFunction, 3, *argumentsFF);

    MagickGammaImage(wand0, 2);

    MagickLevelImage(wand0, QuantumRange/2, 1.0, 0);

    // -delete 1 -swap 0,1  miff:- |

    // composite - -virtual-pixel black  -displace 17x7  rose_cylinder.png
    MagickSetImageVirtualPixelMethod(wand, BlackVirtualPixelMethod);
    MagickCompositeImage(wand, wand0, DisplaceCompositeOp,MagickFalse, 17, 7);

		MagickWriteImage(wand,"cnbcjpg_m_1.jpg");
    if(wand)wand = DestroyMagickWand(wand);
    // if(dw)dw = DestroyDrawingWand(dw);
    // DestroyPixelWand(*histogram);
    MagickWandTerminus();
    return 0;
}
