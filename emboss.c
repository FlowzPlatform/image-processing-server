#include <stdio.h>
#include <MagickWand/MagickWand.h>
#include <math.h>
#define DISTORT_ARG_COUNT 8
#define PI 3.14159265

double distort_ags[DISTORT_ARG_COUNT] = {
    0.0f,
    0.0f,
    1.0f,
    0.0f,
    -2.44929e-16,
    -4
    // -cos(PI*(180-90)/180)*8/2,
    // -sin(PI*(180-90)/180)*8/2
};


int main(int argc, const char * argv[]) {
    MagickWandGenesis();

    MagickWand
        * wand0,
        * wand1,
        * wand2,
        * wandT,
        * wand3;
    wand0 = NewMagickWand();

    // '(' wizard: -colorspace gray ')'
    MagickReadImage(wand0, "Morning.jpg");

    //clone
    wandT = CloneMagickWand(wand0);
    MagickTransformImageColorspace(wand0, GRAYColorspace);

    // '(' -clone 0 -negate ')'
    wand1 = CloneMagickWand(wand0);
    MagickNegateImage(wand1, MagickFalse);

    // '(' -clone 0 -distort SRT '0,0 1 0 -2.12132,-2.12132' ')'
    wand2 = CloneMagickWand(wand0);
    MagickDistortImage(wand2,
                       ScaleRotateTranslateDistortion,
                       DISTORT_ARG_COUNT,
                       distort_ags,
                       MagickFalse);

    // '(' -clone 1 -distort SRT '0,0 1 0 2.12132,2.12132' ')'
    wand3 = CloneMagickWand(wand1);
    printf("%f\n",   distort_ags[4]);
    printf("%f\n",   distort_ags[5]);

    distort_ags[4] *= -1;
    distort_ags[5] *= -1;

    printf("%lf\n",   distort_ags[4]);
    printf("%lf\n",   distort_ags[5]);
    MagickDistortImage(wand3,
                       ScaleRotateTranslateDistortion,
                       DISTORT_ARG_COUNT,
                       distort_ags,
                       MagickFalse);

    // -delete 0,1
    wand0 = DestroyMagickWand(wand0);
    wand1 = DestroyMagickWand(wand1);

    // -define compose:args=50
    MagickSetImageArtifact(wand3, "compose:args", "50"); // Might also be set on wand2
    MagickSetImageArtifact(wand2, "compose:args", "50"); // Might also be set on wand2

    // -compose blend -composite
    MagickCompositeImage(wand2, wand3, BlendCompositeOp,MagickFalse, 0, 0);

    // -level 100%
    MagickLevelImage(wand2, QuantumRange, 1.0, 0);

    // -compose linear_dodge -composite
    MagickCompositeImage(wand2, wandT, LinearDodgeCompositeOp,MagickFalse, 0, 0);

    // output.png
    MagickWriteImage(wand2, "morning22.jpg");

    wand2 = DestroyMagickWand(wand2);
    wand3 = DestroyMagickWand(wand3);
    MagickWandTerminus();
    return 0;
}
