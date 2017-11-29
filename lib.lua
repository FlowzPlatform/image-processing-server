local ffi = require("ffi")
local lib

ffi.cdef([[  typedef void MagickWand;
typedef void PixelWand;
typedef void DrawingWand;

  typedef int MagickBooleanType;
  typedef int ExceptionType;
  typedef int ssize_t;
  typedef int CompositeOperator;
  typedef int GravityType;
  typedef int OrientationType;
  typedef int InterlaceType;
  typedef const int DistortMethod;
  typedef const double QuantumRange;
  typedef const int MagickFunction;
  typedef int AlphaChannelOption;
  typedef int MagickEvaluateOperator;

  void MagickWandGenesis();
  MagickWand* NewMagickWand();
  DrawingWand *NewDrawingWand(void);
  MagickWand* CloneMagickWand(const MagickWand *wand);
  MagickWand* DestroyMagickWand(MagickWand*);
  DrawingWand *DestroyDrawingWand(DrawingWand *wand);
  MagickBooleanType MagickReadImage(MagickWand*, const char*);
  MagickBooleanType MagickReadImageBlob(MagickWand*, const void*, const size_t);

  char* MagickGetException(const MagickWand*, ExceptionType*);

  int MagickGetImageWidth(MagickWand*);
  int MagickGetImageHeight(MagickWand*);

  MagickBooleanType MagickAddImage(MagickWand*, const MagickWand*);

  MagickBooleanType MagickAdaptiveResizeImage(MagickWand*, const size_t, const size_t);

  MagickBooleanType MagickWriteImage(MagickWand*, const char*);

  unsigned char* MagickGetImageBlob(MagickWand*, size_t*);

  void* MagickRelinquishMemory(void*);

  MagickBooleanType MagickCropImage(MagickWand*,
    const size_t, const size_t, const ssize_t, const ssize_t);

  MagickBooleanType MagickBlurImage(MagickWand*, const double, const double);
  MagickBooleanType MagickModulateImage(MagickWand*, const double, const double, const double);
  MagickBooleanType MagickBrightnessContrastImage(MagickWand*, const double, const double);

  MagickBooleanType MagickSetImageFormat(MagickWand* wand, const char* format);
  char* MagickGetImageFormat(MagickWand* wand);

  size_t MagickGetImageCompressionQuality(MagickWand * wand);
  MagickBooleanType MagickSetImageCompressionQuality(MagickWand *wand,
  const size_t quality);

  MagickBooleanType MagickSharpenImage(MagickWand *wand,
    const double radius,const double sigma);

  MagickBooleanType MagickScaleImage(MagickWand *wand,
    const size_t columns,const size_t rows);

  MagickBooleanType MagickRotateImage(MagickWand *wand,
  const PixelWand *background,const double degrees);

  MagickBooleanType MagickSetOption(MagickWand *,const char *,const char *);
  char* MagickGetOption(MagickWand *,const char *);

  MagickBooleanType MagickCompositeImage(MagickWand *wand,
    const MagickWand *source_wand,const CompositeOperator compose,
    const MagickBooleanType clip_to_self,
    const ssize_t x,const ssize_t y);

  GravityType MagickGetImageGravity(MagickWand *wand);
  MagickBooleanType MagickSetImageGravity(MagickWand *wand,
    const GravityType gravity);

  MagickBooleanType MagickStripImage(MagickWand *wand);

  MagickBooleanType MagickGetImagePixelColor(MagickWand *wand,
    const ssize_t x,const ssize_t y,PixelWand *color);

  MagickWand* MagickCoalesceImages(MagickWand*);

  PixelWand *NewPixelWand(void);
  PixelWand *DestroyPixelWand(PixelWand *);

  double PixelGetAlpha(const PixelWand *);
  double PixelGetRed(const PixelWand *);
  double PixelGetGreen(const PixelWand *);
  double PixelGetBlue(const PixelWand *);

  void PixelSetAlpha(PixelWand *wand, const double alpha);
  void PixelSetRed(PixelWand *wand, const double red);
  void PixelSetGreen(PixelWand *wand, const double green);
  void PixelSetBlue(PixelWand *wand, const double blue);

  MagickBooleanType MagickTransposeImage(MagickWand *wand);

  MagickBooleanType MagickTransverseImage(MagickWand *wand);

  MagickBooleanType MagickFlipImage(MagickWand *wand);

  MagickBooleanType MagickFlopImage(MagickWand *wand);

  char* MagickGetImageProperty(MagickWand *wand, const char *property);
  MagickBooleanType MagickSetImageProperty(MagickWand *wand,
    const char *property,const char *value);

  OrientationType MagickGetImageOrientation(MagickWand *wand);
  MagickBooleanType MagickSetImageOrientation(MagickWand *wand,
    const OrientationType orientation);

  InterlaceType MagickGetImageInterlaceScheme(MagickWand *wand);
  MagickBooleanType MagickSetImageInterlaceScheme(MagickWand *wand,
    const InterlaceType interlace_scheme);

  MagickBooleanType MagickAutoOrientImage(MagickWand *wand);

  MagickBooleanType MagickResetImagePage(MagickWand *wand, const char *page);


  MagickBooleanType MagickEmbossImage(MagickWand *wand, const double radius, const double sigma);

  MagickBooleanType MagickNegateImage(MagickWand *wand, const MagickBooleanType gray);

  MagickBooleanType MagickColorizeImage(MagickWand *wand, const PixelWand *colorize, const PixelWand *blend);

  MagickBooleanType MagickSetImageColor(MagickWand *wand, const PixelWand *color);

  MagickBooleanType MagickCharcoalImage(MagickWand *wand, const double radius, const double sigma);

  MagickBooleanType MagickSepiaToneImage(MagickWand *wand, const double threshold);

  MagickBooleanType MagickContrastImage(MagickWand *wand, const MagickBooleanType sharpen);

  MagickBooleanType MagickEdgeImage(MagickWand *wand,const double radius);

  MagickBooleanType MagickShadeImage(MagickWand *wand, const MagickBooleanType gray,const double azimuth,const double elevation);

  MagickBooleanType MagickDistortImage(MagickWand *wand, DistortMethod method, const size_t, const double *args, const MagickBooleanType bestfit);

  PixelWand **MagickGetImageHistogram(MagickWand *wand, size_t *number_colors);

  PixelWand *MagickGetBackgroundColor(MagickWand *wand);

  size_t PixelGetColorCount(const PixelWand *wand);

  MagickBooleanType MagickSetImageFuzz(MagickWand *wand, const double fuzz);

  MagickBooleanType MagickSetImageBorderColor(MagickWand *wand, const PixelWand *border);
  typedef const int ColorspaceType;
  MagickBooleanType MagickSetImageColorspace(MagickWand *wand, ColorspaceType colorspace);

  MagickBooleanType MagickOpaquePaintImage(MagickWand *wand, const PixelWand *target,const PixelWand *fill,const double fuzz, const MagickBooleanType invert);

  MagickBooleanType PixelSetColor(PixelWand *wand,const char *color);

  MagickBooleanType MagickFunctionImage(MagickWand *wand, MagickFunction function,const size_t number_arguments, const double *arguments);

  MagickBooleanType MagickSetImageDepth(MagickWand *wand, const size_t depth);

  MagickBooleanType MagickTransformImageColorspace(MagickWand *wand, const ColorspaceType colorspace);

  MagickBooleanType MagickSetImageArtifact(MagickWand *wand, const char *artifact,const char *value);

  MagickBooleanType MagickLevelImage(MagickWand *wand, const double black_point,const double gamma,const double white_point);

  MagickBooleanType MagickCylinderize(MagickWand *wand, const char *mod, double radius, double length, double wrap, double pitch, double efact, double angle, double narrow);

  MagickBooleanType MagickCustomEmboss(MagickWand *wand, int method, double azimuth, double elevation, double depth, double intensity, const CompositeOperator compose, double gray);

  MagickBooleanType MagickColoration(MagickWand *wand, double hue, double sat, double light);

  char* MagickGetDominantColor(MagickWand *wand);

  MagickBooleanType MagickSetWooden(MagickWand *wood, MagickWand *wand, char *kind, int presharp, int blur, char *dither, double postsharp, int azimuth, int intensity, int mix, char *colors, double sat, double hue, int edge);

  MagickWand *MagickBevelImage(MagickWand *wand, char *form, double azimuth, double elevation,
      double depth, double width, double soften, char *imode, char *omode, char *taper, char *bcolor, char *colormode);

  MagickWand *MagickTshirtImage(MagickWand *tshirt, MagickWand *place, char * coords, char * region, char * fit,
      char * gravity, int vshift, char * offset, int rotate, int lighting, int blur, int displace, int sharpen, int antialias, char * export);

  MagickBooleanType MagickTransparentPaintImage(MagickWand *wand, const PixelWand *target,const double alpha,const double fuzz, const MagickBooleanType invert);

  MagickBooleanType MagickSetImageAlphaChannel(MagickWand *wand, const AlphaChannelOption alpha_type);

  void DrawEllipse(DrawingWand *wand,const double ox,const double oy, const double rx,const double ry,const double start,const double end);

  void DrawSetStrokeColor(DrawingWand *wand, const PixelWand *stroke_wand);

  MagickBooleanType MagickDrawImage(MagickWand *wand, const DrawingWand *drawing_wand);

  MagickBooleanType MagickThresholdImage(MagickWand *wand, const double threshold);

  MagickBooleanType MagickEvaluateImage(MagickWand *wand, const MagickEvaluateOperator operator, const double value);

  MagickBooleanType MagickNewImage(MagickWand *wand, const size_t columns,const size_t rows, const PixelWand *background);

  MagickBooleanType MagickSetTextToImage(MagickWand *wand, char *font, char *text, int fontSize, char *color, int args, double *arguments);

]])

local get_flags
get_flags = function()
  local proc = io.popen("pkg-config --cflags --libs MagickWand", "r")
  local flags = proc:read("*a")
  get_flags = function()
    return flags
  end
  proc:close()
  return flags
end
local get_filters
get_filters = function()
  local fname = "MagickCore/resample.h"
  local prefixes = {
    "/usr/include/ImageMagick",
    "/usr/local/include/ImageMagick",
    unpack((function()
      local _accum_0 = { }
      local _len_0 = 1
      for p in get_flags():gmatch("-I([^%s]+)") do
        _accum_0[_len_0] = p
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)())
  }

  for _index_0 = 1, #prefixes do
    local p = prefixes[_index_0]
    local full = tostring(p) .. "/" .. tostring(fname)
    do
      local f = io.open(full)
      if f then
        local content
        do
          local _with_0 = f:read("*a")
          f:close()
          content = _with_0
        end
        local filter_types = content:match("(typedef enum.-FilterType;)")

        if filter_types then
          ffi.cdef(filter_types)
          return true
        end
      end
    end
  end
  return false
end
local get_filter
get_filter = function(name)
  return lib[name .. "Filter"]
end
local can_resize
if get_filters() then
  ffi.cdef([[    MagickBooleanType MagickResizeImage(MagickWand*,
      const size_t, const size_t,
      const FilterType, const double);
  ]])
  can_resize = true
end
local try_to_load
try_to_load = function(...)
  local out
  local _list_0 = {
    ...
  }
  for _index_0 = 1, #_list_0 do
    local _continue_0 = false
    repeat
      local name = _list_0[_index_0]
      if "function" == type(name) then
        name = name()
        if not (name) then
          _continue_0 = true
          break
        end
      end
      if pcall(function()
        out = ffi.load(name)
      end) then
        return out
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return error("Failed to load ImageMagick (" .. tostring(...) .. ")")
end
lib = try_to_load("MagickWand", function()
  local lname = get_flags():match("-l(MagickWand[^%s]*)")
  local suffix
  if ffi.os == "OSX" then
    suffix = ".dylib"
  elseif ffi.os == "Windows" then
    suffix = ".dll"
  else
    suffix = ".so"
  end
  return lname and "lib" .. lname .. suffix
end)
return {
  lib = lib,
  can_resize = can_resize,
  get_filter = get_filter
}
