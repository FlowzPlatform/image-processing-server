#include <stdio.h>
// #include <wand/MagickWand.h>
#include "MagickWand/MagickWand.h"


int main(int argc, const char * argv[]) {
    // Prototype vars
    MagickWand * wand;
    PixelWand ** histogram;
    size_t histogram_count = 0;
    // Boot environment.
    MagickWandGenesis();
    // Allocate & read image
    wand = NewMagickWand();
    MagickReadImage(wand, "rose:");
    // Get Histogram as array of pixels
    histogram = MagickGetImageHistogram(wand, &histogram_count);
    // Iterate over each pixel & dump info.
    for (int i = 0; i < histogram_count; ++i)
    {
        printf("%s => %zu\n",
               PixelGetColorAsString(histogram[i]),
               PixelGetColorCount(histogram[i]));
    }
    // Clean-up
    histogram = DestroyPixelWands(histogram, histogram_count);
    wand = DestroyMagickWand(wand);
    MagickWandTerminus();
    return 0;
}
