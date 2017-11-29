// + convert -quiet single_color.png +repage -gravity center -background none -extent 12000x834 ./cylinderize_1_20264.mpc
// + convert -size 12000x1 xc: -virtual-pixel black -fx 'xd=(i-6000)/366.34955984688; ffx=0.31831*asin(xd); xs=0.5*(ffx+(6000-i)/(6000))+0.5; xd>1?1:xd<-1?-1:xs' -clamp -scale '12000x443.089!' ./cylinderize_3_20264.mpc
// + convert -size 12000x1 xc: -virtual-pixel black -fx 'xd=(i-6000)/366.34955984688; ffx=-sqrt(1-(xd)^2); xs=0.5*(ffx)+0.5; abs(xd)>1?0.5:xs' -scale '12000x443.089!' ./cylinderize_4_20264.mpc
// + convert '(' -size 12000x443.089 gradient:black-white +level 57.1429x100% ')' ./cylinderize_4_20264.mpc -compose mathematics -define compose:args=1,0,-0.5,0.5 -composite ./cylinderize_4_20264.mpc
// + convert ./cylinderize_1_20264.mpc -resize 100x22.5634% -background none -gravity north -extent 12000x443.089 ./cylinderize_1_20264.mpc
// + convert ./cylinderize_1_20264.mpc ./cylinderize_3_20264.mpc ./cylinderize_4_20264.mpc -channel rgba -alpha on -virtual-pixel background -background none -define compose:args=6000x254.91 -compose displace -composite ./cylinderize_1_20264.mpc
// + convert ./cylinderize_1_20264.mpc -gravity center -crop 2000x443.089+0+0 +repage ./cylinderize_1_20264.mpc
// + convert ./cylinderize_1_20264.mpc -virtual-pixel background -background none -distort perspective '0,0 0,0  1999,0 1999,0  1999,442 1959.99,442  0,442 39.0099,442' ./cylinderize_1_20264.mpc
// + convert ./cylinderize_1_20264.mpc single_color.j.png

// #include <stdlib.h>
#include <stdio.h>
#include "MagickWand/MagickWand.h"
#include <string.h>
#include <math.h>

#define PI 3.14159265
#define DISTORT_ARG_COUNT 8

int roundNo(float num)
{
    return num < 0 ? num - 0.5 : num + 0.5;
}

int cylinderize(MagickWand *wand, char *mod, double radius, double length, double wrap, double pitch, double efact, double angle, double narrow)
{
  MagickWand *wand0, *wand1, *wand2, *wand3, *wand4, *wandc, *wandcc, *wandccc;
  PixelWand *PW1,*PW2,*PW3;

  if(mod==NULL){
    mod = "vertical";
  }
  if (radius==0.0) {
    radius = 0.0;
  }
  if (length==0.0) {
    length = 0.0;
  }
  if (wrap==0.0) {
    wrap = 50;
  }
  if (pitch==0.0) {
    pitch = 0;
  }
  if (efact==0.0) {
    efact = 1;
  }
  if (angle==0.0) {
    angle = 0;
  }
  if(narrow==0.0){
    narrow=100;
  }

  char *direction = "";

  // wand = NewMagickWand();
  PW1 = NewPixelWand();
  PW2 = NewPixelWand();
  PW3 = NewPixelWand();

  PixelSetColor(PW1,"none");
  PixelSetColor(PW2,"#000000");

  // MagickReadImage(wand, "single_color.png");

  wand4 = CloneMagickWand(wand);

  size_t height = MagickGetImageHeight(wand);
  size_t width =  MagickGetImageWidth(wand);

  size_t pwidth, pheight, resizeX, resizeY, rollx, rolly;
  char rolling[]="";
  int scale=100;
  float ratio, pct;
  double iefact, length1, rproc=0.0;
  double radius1, radius2, length2;

  if(0 == strcmp(mod, "vertical")){
      if(radius==0.0){
          radius = width/4 ;
      }

      if(width<2*radius){
          ratio = 2*radius/width;
          pct = 100*ratio;
          width = roundNo(2*radius);
          height = ratio*height;
          rproc = pct;
      }else{

      }
      pwidth = 100*width/wrap;
      pheight = height;

      /*angle*/
      if(angle!=0){
          rollx = abs(angle)*pwidth/360;
          rolly = 0;
      }

      if(scale!=100){
        resizeX=100;
        resizeY= width*scale/100;
      }
    }else{
      if(radius==0.0){
          radius = height/4;
      }
      if(height<2*radius){
          ratio = 2*radius/height;
          pct = 100*ratio;
          height = roundNo(2*radius);
          width = ratio*width;
          rproc = pct;
      }else{

      }
      pwidth = width;
      pheight = 100*height/wrap;

      if(angle!=0){
          rollx = 0;
          rolly = abs(angle)*pheight/360;
      }
      if(scale!=100){
        resizeX = scale;
        resizeY = height*100/100;
      }
  }
  // convert yahoo.jpg -resize 294.105% +repage -gravity center -background none -extent 1941.09x5663.99 yahootest.png

  // for tests
  // convert yahoo.jpg -resize 294.105% -extent 1941.09x5663.99 yahootest.png
  // convert yahoo.jpg -resize 5708x2776 -extent 1941.09x5663.99 yahootest.png

  char resetP[20];
  int cenX, cenY;



  sprintf(resetP, "%zu%s%zu%s",pwidth, "x", pheight,"+0+0");
  // MagickResetImagePage(wand,resetP);
  if(scale!=100){
      MagickResizeImage(wand, resizeX, resizeY, GaussianFilter);
  }
  size_t procWidth = rproc*width/100;
  size_t procHeight = rproc*height/100;
  if(rproc!=0.0){
      cenX = -(pwidth-procWidth)/2;
      cenY = -(pheight-procHeight)/2;
      MagickResizeImage(wand, procWidth, procHeight, GaussianFilter);
      sprintf(resetP, "%zu%s%zu%s%d%s%d",procWidth, "x", procHeight,"+",cenX,"+",cenY);
      MagickResetImagePage(wand,resetP);
  }
  cenX = -(pwidth-width)/2;
  cenY = -(pheight-height)/2;
  MagickSetImageBackgroundColor(wand, PW1);
  MagickScaleImage(wand, width, height);
  MagickExtentImage(wand, pwidth, pheight,cenX,cenY);


  if(angle!=0){
      MagickRollImage(wand, rollx, rolly);
  }
  if(0 == strcmp(direction, "negative")){
      if(0 == strcmp(mod, "vertical")){
          MagickFlipImage(wand);
      }else{
          MagickFlopImage(wand);
      }
  }

  // compute center coords
  size_t xc = pwidth/2;
  size_t yc = pheight/2;

  if(length==0.0){
    if(0 == strcmp(mod, "vertical")){
      length1 = height;
    }else{
      length1 = width;
    }
  }else{
    length1 = length;
  }

  if(length==0.0){
    length1 = length1*cos(PI*pitch/180);
  }
  radius1 = radius*sin(PI*pitch/180);
  radius2 = efact*radius1;

  if(0 == strcmp(mod, "vertical")){
    size_t height1, height12;
    length2 = 100*(length1)/height;

    height1 = length1+radius2;
    height12 = height1;
    printf("%s\n", "rahul");

    // + convert -size 12000x1 xc: -virtual-pixel black -fx 'xd=(i-6000)/366.34955984688; ffx=0.31831*asin(xd); xs=0.5*(ffx+(6000-i)/(6000))+0.5; xd>1?1:xd<-1?-1:xs' -clamp -scale '12000x443.089!' ./cylinderize_3_20264.mpc
    char expr[100];
    sprintf(expr,"%s%zu%s%f%s%f%s%s%zu%s%zu%s","xd=(i-", xc, ")/", radius, "; ffx=", 1/PI, "*asin(xd); ", "xs=0.5*(ffx+(",xc,"-i)/(", xc, "))+0.5; xd>1?1:xd<-1?-1:xs");
    MagickWand *m_wand = NULL;
    m_wand = NewMagickWand();
    MagickNewImage(m_wand,pwidth,1,PW2);
    MagickSetImageVirtualPixelMethod(m_wand, BlackVirtualPixelMethod);
    wand2 = MagickFxImage(m_wand,expr);
    if(m_wand)m_wand = DestroyMagickWand(m_wand);
    MagickClampImage(wand2);
    MagickScaleImage(wand2,pwidth,height12);
    MagickWriteImage(wand2,"Fred_single_color2.png");


    char expr2[100];
    sprintf(expr2,"%s%zu%s%f%s","xd=(i-", xc, ")/", radius, "; ffx=-sqrt(1-(xd)^2); xs=0.5*(ffx)+0.5; abs(xd)>1?0.5:xs");
    MagickWand *m_wand1 = NULL;
    m_wand1 = NewMagickWand();
    MagickNewImage(m_wand1,pwidth,1,PW2);
    MagickSetImageVirtualPixelMethod(m_wand1, BlackVirtualPixelMethod);
    wand3 = MagickFxImage(m_wand1,expr2);
    if(m_wand1)m_wand1 = DestroyMagickWand(m_wand1);
    MagickScaleImage(wand3,pwidth,height12);
    MagickWriteImage(wand3,"Fred_single_color3.png");


    if(efact!=1){
      // + convert '(' -size 12000x443.089 gradient:black-white +level 57.1429x100% ')' ./cylinderize_4_12265.mpc -compose mathematics -define compose:args=1,0,-0.5,0.5 -composite ./cylinderize_4_12265.mpc
      // MagickResizeImage(wand4, 12000,443, GaussianFilter);
      // MagickSetImageMatte(wand4, MagickTrue);
      // MagickLevelImage(wand4, QuantumRange, 1.0, 0);
      // MagickCompositeImage(wand4, wand3, MathematicsCompositeOp,MagickFalse, 0, 0);
      // MagickSetImageArtifact(wand4, "compose:args", "1,0,-0.5,0.5"); // Might also be set on wand2
    }

    // + convert ./cylinderize_1_20264.mpc -resize 100x22.5634% -background none -gravity north -extent 12000x443.089 ./cylinderize_1_20  264.mpc
    // width should be 100%
    size_t newHeight = pheight*length2/100;
    MagickResizeImage(wand, pwidth, newHeight, GaussianFilter);
    MagickSetImageBackgroundColor(wand, PW1);
    MagickSetImageGravity(wand, NorthGravity);
    MagickExtentImage(wand,pwidth, height1,0,0);

    // + convert ./cylinderize_1_20264.mpc ./cylinderize_3_20264.mpc ./cylinderize_4_20264.mpc -channel rgba -alpha on -virtual-pixel background -background none -define compose:args=6000x254.91 -compose displace -composite ./cylinderize_1_20264.mpc
    // convert Fred_single_color_bash1_2.png Fred_single_color3.png Fred_single_color4.png -channel rgba -alpha on -virtual-pixel background -background none -define compose:args=6000x254.91 -compose displace -composite cylinderCMD.png
    wand4 = CloneMagickWand(wand3);
    MagickCompositeImage(wand2, wand3, CopyGreenCompositeOp, MagickTrue, 0, 0);
    MagickCompositeImage(wand2, wand4, CopyBlueCompositeOp,  MagickTrue, 0, 0);
    if(wand4)wand4 = DestroyMagickWand(wand4);
    MagickWriteImage(wand2,"Fred_single_color4.png");


    MagickSetImageAlphaChannel(wand,OnAlphaChannel);
    MagickSetImageVirtualPixelMethod(wand, BackgroundVirtualPixelMethod);
    MagickSetImageBackgroundColor(wand, PW1);
    char cmpArgs[50];
    sprintf(cmpArgs,"%zu%s%f",xc,"x",radius2);
    MagickSetImageArtifact(wand, "compose:args", cmpArgs); // Might also be set on wand2

    MagickSetImageAlphaChannel(wand2,OnAlphaChannel);
    MagickSetImageVirtualPixelMethod(wand2, BackgroundVirtualPixelMethod);
    MagickSetImageBackgroundColor(wand2, PW1);
    MagickSetImageArtifact(wand2, "compose:args", cmpArgs); // Might also be set on wand2

    MagickCompositeImage(wand, wand2, DisplaceCompositeOp,MagickFalse, 0, 0);
    MagickWriteImage(wand,"Fred_single_color5.png");


    // + convert ./cylinderize_1_20264.mpc -gravity center -crop 2000x443.089+0+0 +repage ./cylinderize_1_20264.mpc
    // int test = MagickSetImageGravity(wand, CenterGravity);
    int  cenXL, cenYL;
    cenXL = (pwidth-width)/2;
    cenYL = (pheight-height12)/2;
    printf("%zu\n", width);
    printf("%zu\n", height12);
    if(cenXL<0)cenXL=0;
    if(cenYL<0)cenYL=0;

    MagickCropImage(wand, width, height12, cenXL, cenYL);

    char restArgs[50];
    sprintf(restArgs,"%zu%s%zu%s",width,"x",height12,"+0+0");
    MagickResetImagePage(wand,restArgs);
    MagickWriteImage(wand,"rose_cylinder_20.png");

    if(narrow!=100){
      double ww = width-1;
      double hh = height12-1;
      double offset = (ww/2)*(1-narrow/100);
      double www = ww-offset;

      double x1=0,y1=0, x2=ww, y2=0, x3=www, y3=hh, x4=offset, y4=hh;

      MagickSetImageVirtualPixelMethod(wand, BackgroundVirtualPixelMethod);
      MagickSetImageBackgroundColor(wand, PW1);
      double arguments[16] = {0, 0, x1, y1, ww, 0, x2, y2, ww, hh, x3, y3, 0, hh, x4, y4};
      MagickDistortImage(wand, PerspectiveDistortion,16,arguments,MagickTrue);
    }
    MagickWriteImage(wand,"rose_cylinder_2.png");


    if(wand)wand = DestroyMagickWand(wand);
    if(wand2)wand2 = DestroyMagickWand(wand2);
    if(wand3)wand3 = DestroyMagickWand(wand3);

    if(PW1)DestroyPixelWand(PW1);
    if(PW2)DestroyPixelWand(PW2);
    if(PW3)DestroyPixelWand(PW3);

    MagickWandTerminus();

  }else{
    // + convert -size 1x1668 xc: -virtual-pixel black -fx 'yd=(j-834)/208.5; ffy=0.31831*asin(yd); ys=0.5*(ffy+(834-j)/(834))+0.5; yd>1?1:yd<-1?-1:ys' -scale '2000x1668!' ./cylinderize_3_5841.mpc
    size_t width1, width12;
    width1 = length1+radius2;
    width12 = width1;
    length2 = 100*(length1)/width;
    size_t newWidth = pwidth*length2/100;

    char expr[100];
    sprintf(expr,"%s%zu%s%f%s%f%s%s%zu%s%zu%s","yd=(j-", yc, ")/", radius, "; ffy=", 1/PI, "*asin(yd); ", "ys=0.5*(ffy+(",yc,"-j)/(", yc, "))+0.5; yd>1?1:yd<-1?-1:ys");
    MagickWand *m_wand = NULL;
    m_wand = NewMagickWand();
    MagickNewImage(m_wand,1,pheight,PW2);
    MagickSetImageVirtualPixelMethod(m_wand, BlackVirtualPixelMethod);
    wand2 = MagickFxImage(m_wand,expr);
    MagickClampImage(wand2);
    MagickScaleImage(wand2,width12,pheight);
    MagickWriteImage(wand2,"Fred_single_color3.png");


    // + convert -size 1x1668 xc: -virtual-pixel black -fx 'yd=(j-834)/208.5; ffy=-sqrt(1-(yd)^2); ys=0.5*(ffy)+0.5; abs(yd)>1?0.5:ys' -scale '2000x1668!' ./cylinderize_4_5841.mpc
    char expr2[100];
    sprintf(expr2,"%s%zu%s%f%s","yd=(j-", yc, ")/", radius, "; ffy=-sqrt(1-(yd)^2); ys=0.5*(ffy)+0.5; abs(yd)>1?0.5:ys");
    MagickWand *m_wand1 = NULL;
    m_wand1 = NewMagickWand();
    MagickNewImage(m_wand1,1,pheight,PW2);
    MagickSetImageVirtualPixelMethod(m_wand1, BlackVirtualPixelMethod);
    wand3 = MagickFxImage(m_wand1,expr2);
    MagickScaleImage(wand3,width12,pheight);
    MagickWriteImage(wand3,"Fred_single_color33.png");


    // + convert ./cylinderize_1_5841.mpc -resize 100x100% -background black -gravity west -extent 2000x1668 ./cylinderize_1_5841.mpc
    MagickResizeImage(wand, newWidth, pheight, GaussianFilter);
    MagickSetImageBackgroundColor(wand, PW1);
    MagickSetImageGravity(wand, WestGravity);
    MagickScaleImage(wand,newWidth,pheight);
    MagickExtentImage(wand,width1, pheight,0,0);
    MagickWriteImage(wand,"Fred_single_color333.png");

    // + convert ./cylinderize_1_5841.mpc ./cylinderize_4_5841.mpc ./cylinderize_3_5841.mpc --channel rgba -alpha on -virtual-pixel background -background none -define compose:args=257.264x2831.99 -compose displace ./cylinderize_1_5841.mpc

    wand4 = CloneMagickWand(wand2);
    MagickCompositeImage(wand3, wand2, CopyGreenCompositeOp, MagickTrue, 0, 0);
    MagickCompositeImage(wand3, wand4, CopyBlueCompositeOp,  MagickTrue, 0, 0);
    if(wand4)wand4 = DestroyMagickWand(wand4);
    MagickWriteImage(wand3,"Fred_single_color3333.png");

    char cmpArgs[50];
    sprintf(cmpArgs,"%f%s%zu",radius2,"x",yc);

    MagickSetImageAlphaChannel(wand, OnAlphaChannel);
    MagickSetImageVirtualPixelMethod(wand, BackgroundVirtualPixelMethod);
    MagickSetImageBackgroundColor(wand, PW1);
    MagickSetImageArtifact(wand, "compose:args", cmpArgs);

    MagickSetImageAlphaChannel(wand3, OnAlphaChannel);
    MagickSetImageVirtualPixelMethod(wand3, BackgroundVirtualPixelMethod);
    MagickSetImageBackgroundColor(wand3, PW1);
    MagickSetImageArtifact(wand3, "compose:args", cmpArgs);

    MagickCompositeImage(wand, wand3, DisplaceCompositeOp,MagickFalse, 0, 0);
    MagickWriteImage(wand,"Fred_single_color33333.png");



    // + convert ./cylinderize_1_5841.mpc -gravity center -crop 2000x834+0+0 +repage ./cylinderize_1_5841.mpc
    // + convert ./cylinderize_1_29490.mpc -gravity center -crop 613.293x944+0+0 +repage ./cylinderize_1_29490.mpc

    size_t heightwand1 = MagickGetImageHeight(wand);
    size_t widthwand1 =  MagickGetImageWidth(wand);

    int cenXL, cenYL;
    // cenXL = (widthwand1-width12)/2;
    // cenYL = (heightwand1-height)/2;
    double dividex = widthwand1/newWidth;
    double dividey = heightwand1/height;
    cenXL = (widthwand1-width12)/2;
    cenYL = (heightwand1-height)/2;

    char restArgs[50];
    sprintf(restArgs,"%zu%s%zu%s%d%s%d",width12,"x",height,"+",0,"+",0);
    MagickResetImagePage(wand,restArgs);
    MagickCropImage(wand, width12, height, cenXL, cenYL);
    MagickWriteImage(wand,"math1.png");
    MagickResetImagePage(wand,restArgs);

    if(narrow!=100){
      double ww = width12-1;
      double hh = height-1;
      double offset = (hh/2)*(1-narrow/100);
      double hhh = hh-offset;

      double x1=0,y1=0, x2=ww, y2=offset, x3=ww, y3=hhh, x4=0, y4=hh;

      MagickSetImageVirtualPixelMethod(wand, BackgroundVirtualPixelMethod);
      MagickSetImageBackgroundColor(wand, PW1);
      double arguments[16] = {0, 0, x1, y1, ww, 0, x2, y2, ww, hh, x3, y3, 0, hh, x4, y4};
      MagickDistortImage(wand, PerspectiveDistortion,16,arguments,MagickTrue);
    }
    MagickWriteImage(wand,"rose_cylinder_2.png");

    // sprintf(restArgs,"%zu%s%zu%s%d%s%d",width12,"x",height,"+",cenXL,"+",cenYL);
    // sprintf(restArgs,"%zu%s%zu%s%d%s%d",613,"x",944,"+",0,"+",0);
    // MagickResetImagePage(wand,restArgs);

    if(wand)wand = DestroyMagickWand(wand);
    if(wand2)wand2 = DestroyMagickWand(wand2);
    if(wand3)wand3 = DestroyMagickWand(wand3);

    if(PW1)DestroyPixelWand(PW1);
    if(PW2)DestroyPixelWand(PW2);
    if(PW3)DestroyPixelWand(PW3);

    MagickWandTerminus();
  }
}

int main(int argc, const char * argv[]) {
  MagickWand *wand, *newwand;
  wand = NewMagickWand();
  MagickReadImage(wand, "single_color.png");

  int status = cylinderize(wand, "horizontal", 472.03813405274, 356.029, 16.6667, 18.145578659481, 1.75, 0.0,90.00);
  // int status = MagickCylinderize(wand, "vertical", 366.34955984688, 188.179, 16.6667, 23.428692808745, 1.75, 0.0);
  // cylinderize(wand,"vertical", 0, 0, 0, 0, 0, 0);
  // MagickWriteImage(newwand);
  // MagickWriteImage(wand,"rose_cylinder_22.png");
  // int status = cylinderize(NULL, 0, 0, 0, 0, 0, 0);
}

int main1(int argc, const char * argv[]) {
    MagickWand *wand, *wand0, *wand1, *wand2, *wand3, *wand4, *wandc, *wandcc, *wandccc;
    PixelWand *PW1,*PW2,*PW3;

    /*options*/
    char *mod = "horizontal";
    char *direction = "";

    wand = NewMagickWand();
    PW1 = NewPixelWand();
    PW2 = NewPixelWand();
    PW3 = NewPixelWand();

    PixelSetColor(PW1,"none");
    PixelSetColor(PW2,"#000000");

    MagickReadImage(wand, "rose.png");

    wandcc = CloneMagickWand(wand);
    wandccc = CloneMagickWand(wand);
    wand4 = CloneMagickWand(wand);

    size_t height = MagickGetImageHeight(wand);
    size_t width =  MagickGetImageWidth(wand);
    size_t pwidth, pheight, resizeX, resizeY, rollx, rolly;
    char rolling[]="";
    double radius = 366.34955984688, length=188.179, wrap=16.6667, pitch=23.428692808745, efact=1.75, angle=0;
    // int efact=1 ;
    // int pitch = 0;
    // int wrap = 50, angle=10, scale=100;
    int scale=100;

    // int radius, length=0;
    float ratio, pct, rproc;

    // printf("%s\n", mod);
    if(0 == strcmp(mod, "vertical")){
        if(radius==0.0){
            radius = width/4 ;
        }

        if(width<2*radius){
            ratio = 2*radius/width;
            pct = 100*ratio;
            width = roundNo(2*radius);
            height = ratio*height;
            rproc = 0.0;
        }else{

        }
        pwidth = 100*width/wrap;
        pheight = height;

        /*angle*/
        if(angle!=0){
            rollx = abs(angle)*pwidth/360;
            rolly = 0;
        }

        if(scale!=100){
          resizeX=100;
          resizeY= width*scale/100;
        }
      }else{
        if(radius==0.0){
            radius = height/4;
        }
        if(height<2*radius){
            ratio = 2*radius/height;
            pct = 100*ratio;
            width = roundNo(2*radius);
            height = ratio*width;
            rproc = 0.0;
        }else{

        }
        pwidth = width;
        pheight = 100*height/wrap;

        if(angle!=0){
            rollx = 0;
            rolly = abs(angle)*pheight/360;
        }
        if(scale!=100){
          resizeX = scale;
          resizeY = height*100/100;
        }
    }

    // set up resize
    // wandc = CloneMagickWand(wand);


    int cenX = -(pwidth-width)/2;
    int cenY = -(pheight-height)/2;

    char resetP[20];
    sprintf(resetP, "%zu%s%zu%s",pwidth, "x", pheight,"+0+0");
    // int cen = (width/2)-2000;
    // printf("%d\n", cen1);
    // printf("%d\n", cen);

    // MagickSetImageGravity(wand, CenterGravity);

    // convert single_color.png -quiet single_color.png +repage -gravity center -background none -extent 4000x834 Fred_single_color1_ce.png
    // printf("%zu\n%zu\n", pheight, pwidth);

    MagickResetImagePage(wand,resetP);
    if(scale!=100){
        MagickResizeImage(wand, resizeX, resizeY, GaussianFilter);
    }
    MagickSetImageGravity(wand, CenterGravity);
    MagickSetImageBackgroundColor(wand, PW1);
    MagickSetImageGravity(wand, CenterGravity);
    // printf("%zu\n", pwidth);
    // printf("%zu\n", pheight);
    MagickExtentImage(wand,pwidth, pheight,cenX,cenY);
    if(angle!=0){
        MagickRollImage(wand, rollx, rolly);
    }
    if(0 == strcmp(direction, "negative")){
        if(0 == strcmp(mod, "vertical")){
            MagickFlipImage(wand);
        }else{
            MagickFlopImage(wand);
        }
    }
    MagickSetImageGravity(wand, CenterGravity);

    // compute center coords
    size_t xc = pwidth/2;
    size_t yc = pheight/2;


    double iefact, length1;

    if(length==0.0){
      if(0 == strcmp(mod, "vertical")){
        length1 = height;
      }else{
        length1 = width;
      }
    }else{
      length1 = length;
    }

    if(length==0.0){
      length1 = length1*cos(PI*pitch/180);
    }
    // printf("%f\n", length1);

    // printf("%f\n", length1);
    // radius1 = radius*math.sin(PI*pitch/180);
    // radius1 = efact*radius1;
    // iefact = 100/efact;

    // wandc = CloneMagickWand(wand);
    double radius1, radius2, length2;
    // radius1=`convert xc: -format "%[fx:$radius*sin(pi*$pitch/180)]" info:`
    // radius2=`convert xc: -format "%[fx:$efact*$radius1]" info:`
    // iefact=`convert xc: -format "%[fx:100/$efact]" info:`
    // printf("%f\n", radius);
    // printf("%f\n", pitch);
    radius1 = radius*sin(PI*pitch/180);
    // printf("%s\n","radius1");
    // printf("%f\n", radius1);
    radius2 = efact*radius1;

    if(0 == strcmp(mod, "vertical")){

      size_t height1, height12;

      length2 = 100*(length1)/height;

      // printf("%f\n", length2);
      // printf("%f\n", radius2);

      height1 = length1+radius2;
      height12 = height1;

      // + convert -size 12000x1 xc: -virtual-pixel black -fx 'xd=(i-6000)/366.34955984688; ffx=0.31831*asin(xd); xs=0.5*(ffx+(6000-i)/(6000))+0.5; xd>1?1:xd<-1?-1:xs' -clamp -scale '12000x443.089!' ./cylinderize_3_20264.mpc
      char expr[100];
      sprintf(expr,"%s%zu%s%f%s%f%s%s%zu%s%zu%s","xd=(i-", xc, ")/", radius, "; ffx=", 1/PI, "*asin(xd); ", "xs=0.5*(ffx+(",xc,"-i)/(", xc, "))+0.5; xd>1?1:xd<-1?-1:xs");
      MagickWand *m_wand = NULL;
      m_wand = NewMagickWand();
      MagickNewImage(m_wand,pwidth,1,PW2);
      MagickSetImageVirtualPixelMethod(m_wand, BlackVirtualPixelMethod);
      wand2 = MagickFxImage(m_wand,expr);
      MagickClampImage(wand2);
      MagickScaleImage(wand2,pwidth,height12);
      // MagickWriteImage(wand2,"Fred_single_color3.png");

      char expr2[100];
      sprintf(expr2,"%s%zu%s%f%s","xd=(i-", xc, ")/", radius, "; ffx=-sqrt(1-(xd)^2); xs=0.5*(ffx)+0.5; abs(xd)>1?0.5:xs");
      MagickWand *m_wand1 = NULL;
      m_wand1 = NewMagickWand();
      MagickNewImage(m_wand1,pwidth,1,PW2);
      MagickSetImageVirtualPixelMethod(m_wand1, BlackVirtualPixelMethod);
      wand3 = MagickFxImage(m_wand1,expr2);
      MagickScaleImage(wand3,pwidth,height12);
      // MagickWriteImage(wand3,"Fred_single_color4.png");

      if(efact!=1){
        // + convert '(' -size 12000x443.089 gradient:black-white +level 57.1429x100% ')' ./cylinderize_4_12265.mpc -compose mathematics -define compose:args=1,0,-0.5,0.5 -composite ./cylinderize_4_12265.mpc
        MagickResizeImage(wand4, 12000,443, GaussianFilter);
        MagickSetImageMatte(wand4, MagickTrue);
        MagickLevelImage(wand4, QuantumRange, 1.0, 0);
        MagickCompositeImage(wand4, wand3, MathematicsCompositeOp,MagickFalse, 0, 0);
        MagickSetImageArtifact(wand4, "compose:args", "1,0,-0.5,0.5"); // Might also be set on wand2
        // MagickWriteImage(wand3,"Fred_single_color4_1.png");
      }

      // + convert ./cylinderize_1_20264.mpc -resize 100x22.5634% -background none -gravity north -extent 12000x443.089 ./cylinderize_1_20  264.mpc

      // width should be 100%
      size_t newHeight = pheight*length2/100;
      MagickResizeImage(wand, pwidth, newHeight, GaussianFilter);
      MagickSetImageBackgroundColor(wand, PW1);
      MagickSetImageGravity(wand, NorthGravity);
      MagickExtentImage(wand,pwidth, height1,0,0);

      // + convert ./cylinderize_1_20264.mpc ./cylinderize_3_20264.mpc ./cylinderize_4_20264.mpc -channel rgba -alpha on -virtual-pixel background -background none -define compose:args=6000x254.91 -compose displace -composite ./cylinderize_1_20264.mpc

      // convert Fred_single_color_bash1_2.png Fred_single_color3.png Fred_single_color4.png -channel rgba -alpha on -virtual-pixel background -background none -define compose:args=6000x254.91 -compose displace -composite cylinderCMD.png

      wand4 = CloneMagickWand(wand3);
      MagickCompositeImage(wand2, wand3, CopyGreenCompositeOp, MagickTrue, 0, 0);
      MagickCompositeImage(wand2, wand4, CopyBlueCompositeOp,  MagickTrue, 0, 0);

      MagickSetImageAlphaChannel(wand,OnAlphaChannel);
      MagickSetImageVirtualPixelMethod(wand, BackgroundVirtualPixelMethod);
      MagickSetImageBackgroundColor(wand, PW1);
      char cmpArgs[50];
      sprintf(cmpArgs,"%zu%s%f",xc,"x",radius2);
      MagickSetImageArtifact(wand, "compose:args", cmpArgs); // Might also be set on wand2

      // MagickSetImageAlphaChannel(wand2, RGBChannels);
      MagickSetImageAlphaChannel(wand2,OnAlphaChannel);
      MagickSetImageVirtualPixelMethod(wand2, BackgroundVirtualPixelMethod);
      MagickSetImageBackgroundColor(wand2, PW1);
      MagickSetImageArtifact(wand2, "compose:args", cmpArgs); // Might also be set on wand2

      MagickCompositeImage(wand, wand2, DisplaceCompositeOp,MagickFalse, 0, 0);
      MagickWriteImage(wand,"Fred_single_color1_33333.png");


      // + convert ./cylinderize_1_20264.mpc -gravity center -crop 2000x443.089+0+0 +repage ./cylinderize_1_20264.mpc
      int test = MagickSetImageGravity(wand, CenterGravity);
      printf("%d\n", test);
      size_t cenXL, cenYL;
      cenXL = (pwidth-width)/2;
      cenYL = (pheight-height12)/2;
      printf("%zu\n", cenXL);
      printf("%zu\n", cenYL);

      MagickCropImage(wand, width, height12, cenXL, cenYL);
      char restArgs[50];
      sprintf(restArgs,"%zu%s%zu%s",width,"x",height12,"+0+0");
      MagickResetImagePage(wand,restArgs);
      MagickWriteImage(wand,"rose_cylinder_2.png");

    }else{
      // + convert -size 1x1668 xc: -virtual-pixel black -fx 'yd=(j-834)/208.5; ffy=0.31831*asin(yd); ys=0.5*(ffy+(834-j)/(834))+0.5; yd>1?1:yd<-1?-1:ys' -scale '2000x1668!' ./cylinderize_3_5841.mpc
      char expr[100];
      sprintf(expr,"%s%zu%s%f%s%f%s%s%zu%s%zu%s","yd=(j-", yc, ")/", radius, "; ffy=", 1/PI, "*asin(yd); ", "ys=0.5*(ffy+(",yc,"-j)/(", yc, "))+0.5; yd>1?1:yd<-1?-1:ys");
      MagickWand *m_wand = NULL;
      m_wand = NewMagickWand();
      MagickNewImage(m_wand,1,pheight,PW2);
      MagickSetImageVirtualPixelMethod(m_wand, BlackVirtualPixelMethod);
      wand2 = MagickFxImage(m_wand,expr);
      MagickClampImage(wand2);
      MagickScaleImage(wand2,pwidth,pheight);

      // + convert -size 1x1668 xc: -virtual-pixel black -fx 'yd=(j-834)/208.5; ffy=-sqrt(1-(yd)^2); ys=0.5*(ffy)+0.5; abs(yd)>1?0.5:ys' -scale '2000x1668!' ./cylinderize_4_5841.mpc
      char expr2[100];
      sprintf(expr2,"%s%zu%s%f%s","yd=(j-", yc, ")/", radius, "; ffy=-sqrt(1-(yd)^2); ys=0.5*(ffy)+0.5; abs(yd)>1?0.5:ys");
      printf("%s\n", expr2);
      MagickWand *m_wand1 = NULL;
      m_wand1 = NewMagickWand();
      MagickNewImage(m_wand1,1,pheight,PW2);
      MagickSetImageVirtualPixelMethod(m_wand1, BlackVirtualPixelMethod);
      wand3 = MagickFxImage(m_wand1,expr2);
      MagickScaleImage(wand3,pwidth,pheight);

      // + convert ./cylinderize_1_5841.mpc -resize 100x100% -background black -gravity west -extent 2000x1668 ./cylinderize_1_5841.mpc

      size_t width1, width12;
      width1 = length1+radius2;
      width12 = width1;

      length2 = 100*(length1)/width;
      size_t newWidth = pheight*length2/100;
      MagickResizeImage(wand, newWidth, pheight, GaussianFilter);
      MagickSetImageBackgroundColor(wand, PW2);
      MagickSetImageGravity(wand, WestGravity);
      MagickExtentImage(wand,newWidth, pheight,0,0);

      // + convert ./cylinderize_1_5841.mpc ./cylinderize_4_5841.mpc ./cylinderize_3_5841.mpc -alpha off -virtual-pixel black -background black -define compose:args=0x834 -compose displace -composite ./cylinderize_1_5841.mpc

      wand4 = CloneMagickWand(wand2);
      MagickCombineImages(wand,RGBColorspace);
      MagickCombineImages(wand2,RGBColorspace);
      MagickCombineImages(wand4,RGBColorspace);

      MagickAddImage(wand, wand2);
      MagickAddImage(wand, wand4);

      printf("%f\n", radius2);
      char cmpArgs[50];
      sprintf(cmpArgs,"%f%s%zu",radius2,"x",yc);
      printf("%s\n", cmpArgs);

      wand4 = CloneMagickWand(wand3);
      MagickCompositeImage(wand2, wand3, CopyGreenCompositeOp, MagickTrue, 0, 0);
      MagickCompositeImage(wand2, wand4, CopyBlueCompositeOp,  MagickTrue, 0, 0);


      MagickSetImageAlphaChannel(wand, RGBChannels);
      MagickSetImageVirtualPixelMethod(wand, BackgroundVirtualPixelMethod);
      MagickSetImageBackgroundColor(wand, PW1);
      MagickSetImageArtifact(wand, "compose:args", cmpArgs); // Might also be set on wand2

      MagickSetImageAlphaChannel(wand2, RGBChannels);
      MagickSetImageVirtualPixelMethod(wand2, BackgroundVirtualPixelMethod);
      MagickSetImageBackgroundColor(wand2, PW1);
      MagickSetImageArtifact(wand2, "compose:args", cmpArgs); // Might also be set on wand2

      MagickCompositeImage(wand, wand2, DisplaceCompositeOp,MagickTrue, 0, 0);

      // + convert ./cylinderize_1_5841.mpc -gravity center -crop 2000x834+0+0 +repage ./cylinderize_1_5841.mpc
      size_t cenXL, cenYL;
      cenXL = (pwidth-width12)/2;
      cenYL = (pheight-height)/2;
      printf("%zu\n", cenXL);
      printf("%zu\n", cenYL);

      int test = MagickSetImageGravity(wand, CenterGravity);
      printf("%zu\n", width12);
      MagickCropImage(wand, width12, height, cenXL, cenYL);
      char restArgs[50];
      sprintf(restArgs,"%zu%s%zu%s%zu%s%zu",width12,"x",height,"+",cenXL,"+",cenYL);
      MagickResetImagePage(wand,restArgs);
    }


    // + convert '(' -size 12000x443.089 gradient:black-white +level 57.1429x100% ')' ./cylinderize_4_20264.mpc -compose mathematics -define compose:args=1,0,-0.5,0.5 -composite ./cylinderize_4_20264.mpc
    // MagickResizeImage(wand4, 12000,443, GaussianFilter);
    // MagickSetImageMatte(wand4, MagickTrue);
    // MagickLevelImage(wand4, QuantumRange, 1.0, 0);
    // MagickCompositeImage(wand4, wand3, MathematicsCompositeOp,MagickFalse, 0, 0);
    // MagickSetImageArtifact(wand4, "compose:args", "1,0,-0.5,0.5"); // Might also be set on wand2
    // // MagickWriteImage(wand3,"Fred_single_color4_1.png");



    // + convert ./cylinderize_1_20264.mpc -virtual-pixel background -background none -distort perspective '0,0 0,0  1999,0 1999,0  1999,442 1959.99,442  0,442 39.0099,442' ./cylinderize_1_20264.mpc
    // MagickSetImageVirtualPixelMethod(wand, BackgroundVirtualPixelMethod);
    // MagickSetImageBackgroundColor(wand, PW1);
    // const double arguments[14] = {0,0,0,0,1999,0,1999,442,1959.99,442,0,442,39.0099,442};
    // MagickDistortImage(wand, PerspectiveDistortion,14,arguments,MagickTrue);
    // MagickWriteImage(wand,"Fred_single_color1_37.png");

    if(wand)wand = DestroyMagickWand(wand);
    // if(dw)dw = DestroyDrawingWand(dw);
    // DestroyPixelWand(*histogram);
    MagickWandTerminus();
    return 0;

}

