local ffi = require("ffi")
local lib, can_resize, get_filter
do
  local _obj_0 = require("magick.wand.lib")
  lib, can_resize, get_filter = _obj_0.lib, _obj_0.can_resize, _obj_0.get_filter
end
local composite_operators, gravity, orientation, interlace
do
  local _obj_0 = require("magick.wand.data")
  composite_operators, gravity, orientation, interlace = _obj_0.composite_operators, _obj_0.gravity, _obj_0.orientation, _obj_0.interlace
end
local get_exception
get_exception = function(wand)
  local etype = ffi.new("ExceptionType[1]", 0)
  local msg = ffi.string(ffi.gc(lib.MagickGetException(wand, etype), lib.MagickRelinquishMemory))
  return etype[0], msg
end
local handle_result
handle_result = function(img_or_wand, status)
  local wand = img_or_wand.wand or img_or_wand
  if status == 0 then
    local code, msg = get_exception(wand)
    return nil, msg, code
  else
    return true
  end
end
local Image
do
  local _class_0
  local _parent_0 = require("magick.base_image")
  local _base_0 = {
    get_width = function(self)
      return lib.MagickGetImageWidth(self.wand)
    end,
    get_height = function(self)
      return lib.MagickGetImageHeight(self.wand)
    end,
    get_format = function(self)
      local format = lib.MagickGetImageFormat(self.wand)
      do
        local _with_0 = ffi.string(format):lower()
        lib.MagickRelinquishMemory(format)
        return _with_0
      end
    end,
    set_format = function(self, format)
      return handle_result(self, lib.MagickSetImageFormat(self.wand, format))
    end,
    get_quality = function(self)
      return lib.MagickGetImageCompressionQuality(self.wand)
    end,
    set_quality = function(self, quality)
      return handle_result(self, lib.MagickSetImageCompressionQuality(self.wand, quality))
    end,
    get_option = function(self, magick, key)
      local format = magick .. ":" .. key
      local option_str = lib.MagickGetOption(self.wand, format)
      do
        local _with_0 = ffi.string(option_str)
        lib.MagickRelinquishMemory(option_str)
        return _with_0
      end
    end,
    set_option = function(self, magick, key, value)
      local format = magick .. ":" .. key
      return handle_result(self, lib.MagickSetOption(self.wand, format, value))
    end,
    get_gravity = function(self)
      return gravity:to_str(lib.MagickGetImageGravity(self.wand))
    end,
    set_gravity = function(self, gtype)
      gtype = assert(gravity:to_int(gtype), "invalid gravity type")
      return lib.MagickSetImageGravity(self.wand, gtype)
    end,
    strip = function(self)
      return lib.MagickStripImage(self.wand)
    end,
    clone = function(self)
      local wand = ffi.gc(lib.CloneMagickWand(self.wand), lib.DestroyMagickWand)
      return Image(wand, self.path)
    end,
    coalesce = function(self)
      self.wand = ffi.gc(lib.MagickCoalesceImages(self.wand), ffi.DestroyMagickWand)
      return true
    end,
    resize = function(self, w, h, f, blur)
      if f == nil then
        f = "Lanczos2"
      end
      if blur == nil then
        blur = 1.0
      end
      if not (can_resize) then
       error("Failed to load filter list, can't resize")
      end
      w, h = self:_keep_aspect(w, h)
      return handle_result(self, lib.MagickResizeImage(self.wand, w, h, get_filter(f), blur))
    end,
    adaptive_resize = function(self, w, h)
      w, h = self:_keep_aspect(w, h)
      return handle_result(self, lib.MagickAdaptiveResizeImage(self.wand, w, h))
    end,
    scale = function(self, w, h)
      w, h = self:_keep_aspect(w, h)
      return handle_result(self, lib.MagickScaleImage(self.wand, w, h))
    end,
    crop = function(self, w, h, x, y)
      if x == nil then
        x = 0
      end
      if y == nil then
        y = 0
      end
      return handle_result(self, lib.MagickCropImage(self.wand, w, h, x, y))
    end,
    blur = function(self, sigma, radius)
      if radius == nil then
        radius = 0
      end
      return handle_result(self, lib.MagickBlurImage(self.wand, radius, sigma))
    end,
    modulate = function(self, brightness, saturation, hue)
      if brightness == nil then
        brightness = 100
      end
      if saturation == nil then
        saturation = 100
      end
      if hue == nil then
        hue = 100
      end
      return handle_result(self, lib.MagickModulateImage(self.wand, brightness, saturation, hue))
    end,
    sharpen = function(self, sigma, radius)
      if radius == nil then
        radius = 0
      end
      return handle_result(self, lib.MagickSharpenImage(self.wand, radius, sigma))
    end,
    rotate = function(self, degrees, r, g, b)
      -- if r == nil then
      --   r = 255
      -- end
      -- if g == nil then
      --   g = 255
      -- end
      -- if b == nil then
      --   b = 255
      -- end
      r,g,b = 255,255,255
      local pixel = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      lib.PixelSetRed(pixel, r)
      lib.PixelSetGreen(pixel, g)
      lib.PixelSetBlue(pixel, b)
      lib.PixelSetAlpha(pixel,0.0)

      local res = {
          handle_result(self, lib.MagickRotateImage(self.wand, pixel, degrees))
      }
      return unpack(res)
    end,
    composite = function(self, blob, x, y, op)
      if op == nil then
        op = "OverCompositeOp"
      end
      if type(blob) == "table" and blob.__class == Image then
        blob = blob.wand
      end
      op = assert(composite_operators:to_int(op), "invalid operator type")
      return handle_result(self, lib.MagickCompositeImage(self.wand, blob, op, 1, x, y))
    end,
    compositeTest = function(self, source, compose, clip_to_self, x, y)
      if type(source) == "table" and source.__class == Image then
        source = source.wand
      end
      return handle_result(self, lib.MagickCompositeImage(self.wand, source, compose, clip_to_self, x, y))
    end,
    get_blob = function(self)
      local len = ffi.new("size_t[1]", 0)
      local blob = ffi.gc(lib.MagickGetImageBlob(self.wand, len), lib.MagickRelinquishMemory)
      return ffi.string(blob, len[0])
    end,
    write = function(self, fname)
      return handle_result(self, lib.MagickWriteImage(self.wand, fname))
    end,
    destroy = function(self)
      if self.wand then
        lib.DestroyMagickWand(ffi.gc(self.wand, nil))
        self.wand = nil
      end
      if self.pixel_wand then
        lib.DestroyPixelWand(ffi.gc(self.pixel_wand, nil))
        self.pixel_wand = nil
      end
    end,
    get_pixel = function(self, x, y)
      self.pixel_wand = self.pixel_wand or ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      assert(lib.MagickGetImagePixelColor(self.wand, x, y, self.pixel_wand), "failed to get pixel")
      return lib.PixelGetRed(self.pixel_wand), lib.PixelGetGreen(self.pixel_wand), lib.PixelGetBlue(self.pixel_wand), lib.PixelGetAlpha(self.pixel_wand)
    end,
    transpose = function(self)
      return handle_result(self, lib.MagickTransposeImage(self.wand))
    end,
    transverse = function(self)
      return handle_result(self, lib.MagickTransverseImage(self.wand))
    end,
    flip = function(self)
      return handle_result(self, lib.MagickFlipImage(self.wand))
    end,
    flop = function(self)
      return handle_result(self, lib.MagickFlopImage(self.wand))
    end,
    get_property = function(self, property)
      local res = lib.MagickGetImageProperty(self.wand, property)
      if nil ~= res then
        do
          local _with_0 = ffi.string(res)
          lib.MagickRelinquishMemory(res)
          return _with_0
        end
      else
        local code, msg = get_exception(self.wand)
        return nil, msg, code
      end
    end,
    set_property = function(self, property, value)
      return handle_result(self, lib.MagickSetImageProperty(self.wand, property, value))
    end,
    get_orientation = function(self)
      return orientation:to_str(lib.MagickGetImageOrientation(self.wand))
    end,
    set_orientation = function(self, otype)
      otype = assert(orientation:to_int(otype), "invalid orientation type")
      return lib.MagickSetImageOrientation(self.wand, otype)
    end,
    get_interlace_scheme = function(self)
      return interlace:to_str(lib.MagickGetImageInterlaceScheme(self.wand))
    end,
    set_interlace_scheme = function(self, itype)
      itype = assert(interlace:to_int(itype), "invalid interlace type")
      return lib.MagickSetImageInterlaceScheme(self.wand, itype)
    end,
    auto_orient = function(self)
      return handle_result(self, lib.MagickAutoOrientImage(self.wand))
    end,
    reset_page = function(self)
      return handle_result(self, lib.MagickResetImagePage(self.wand, nil))
    end,
    emboss = function(self, redius, sigma)
      return handle_result(self, lib.MagickEmbossImage(self.wand, redius, sigma))
    end,
    negate = function(self, grey)
      return handle_result(self, lib.MagickNegateImage(self.wand, grey))
    end,
    colorize = function(self, r, g, b)
      if r == nil then
        r = 0
      end
      if g == nil then
        g = 0
      end
      if b == nil then
        b = 0
      end

      local pixel = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      lib.PixelSetRed(pixel, 35)
      lib.PixelSetGreen(pixel, 31)
      lib.PixelSetBlue(pixel, 32)

      local pixel2 = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      lib.PixelSetRed(pixel2, 220)
      lib.PixelSetGreen(pixel2, 12)
      lib.PixelSetBlue(pixel2, 12)
      return handle_result(self, lib.MagickColorizeImage(self.wand, pixel, pixel2))
    end,

    single_color = function(self, fill_rgb, fuzz)

      local fuzz = fuzz*65535/100;
      -- if white color present then make it transparent
      local pixelTargetWhite = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      local pixelFillTransparent= ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)

      -- change all colors to fill color except transparent
      local pixelTargetTransparent = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      local pixelFill = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)

      handle_result(self, lib.PixelSetColor(pixelTargetWhite, "white"))
      handle_result(self, lib.PixelSetColor(pixelFillTransparent, "#00000000"))
      handle_result(self, lib.MagickOpaquePaintImage(self.wand, pixelTargetWhite, pixelFillTransparent, fuzz, 0))

      handle_result(self, lib.PixelSetColor(pixelTargetTransparent, "#00000000"))
      handle_result(self, lib.PixelSetColor(pixelFill, fill_rgb))
      return handle_result(self, lib.MagickOpaquePaintImage(self.wand, pixelTargetTransparent, pixelFill, fuzz, 1))
    end,

    imageColor = function(self, r, g, b)
      if r == nil then
        r = 0
      end
      if g == nil then
        g = 0
      end
      if b == nil then
        b = 0
      end

      local pixel = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      lib.PixelSetRed(pixel, r)
      lib.PixelSetGreen(pixel, g)
      lib.PixelSetBlue(pixel, b)
      -- return handle_result(self, lib.MagickSetImageColor(self.wand, pixel))
      -- return handle_result(self, lib.MagickSetImageBorderColor(self.wand, pixel))
    end,
    colorSpace = function(self, value)
      local colorSpaceTable = {}
      colorSpaceTable['gray'] = 3
      return handle_result(self, lib.MagickSetImageColorspace(self.wand, colorSpaceTable[value]))
    end,
    charcoalImage = function(self, radius, signma)
      return handle_result(self, lib.MagickCharcoalImage(self.wand, radius, signma))
    end,
    toneImage = function(self, threshold)
      return handle_result(self, lib.MagickSepiaToneImage(self.wand, threshold))
    end,
    -- sharpen image
    contrastImage = function(self, sharpen)
      return handle_result(self, lib.MagickContrastImage(self.wand, sharpen))
    end,
    --edge image
    edgeImage = function(self, radius)
      return handle_result(self, lib.MagickEdgeImage(self.wand, radius))
    end,
    shadeImage = function(self, gray, azimuth, elevation)
       handle_result(self, lib.MagickShadeImage(self.wand, gray, azimuth, elevation))

      -- local nelem = 2
      -- local arg = ffi.new("const double[?]",nelem,{1,0})
      -- local x =  handle_result(self, lib.MagickFunctionImage(self.wand, 3, nelem, arg))
      -- print(x)
      -- return t
    end,
    distortImage = function(self)
      -- double a[1] = {15.5}
      -- local tlen = ffi.new("double *")
      -- local tlen = ffi.new("double[?]",60)
      -- local arg = ffi.new("const char*[3]", {"ls", "-l"})
      -- local arg = ffi.new("const double[1]",{120})
      -- local methods = ffi.new("enum DistortMethod[1]",{'one'='Plane2Cylinder'})
      -- local methods = ffi.C.bar("Plane2CylinderDistortion")
      -- arg[0] = 115.23
      -- print(arg[1])
      -- local m = ffi.new("enum DistortMethod","Plane2CylinderDistortion")
      -- lib.DistortMethod = "Plane2CylinderDistortion";
      -- m[0] = "Plane2CylinderDistortion"
      -- local Plane2CylinderDistortion = ffi.new('unsigned int',15)
-- local composite_operators = enum({[0]="Plane2CylinderDistortion"})
-- local tt =  handle_result(self, lib.MagickDistortImageCustom(self.wand))
-- local tt =  handle_result(self, lib.MagickDistortImage(self.wand,15, 1, arg, 1))
-- DistortMethod
    local nelem = 1 -- number of args
    local arg = ffi.new("const double[?]", nelem, {100})
    -- local methos = ffi.new("const int", 15)
    return handle_result(self, lib.MagickDistortImage(self.wand,13, nelem, arg, 1))
    end,
    distort_image = function(self, type, no_arg, arg)
      -- local nelem = 6 -- number of args
      -- 3
      local arg = ffi.new("const double[?]", no_arg, arg)
      -- local arg = ffi.new("const double[?]", nelem, {0,0,1,0,2.12132,2.12132})
      return handle_result(self, lib.MagickDistortImage(self.wand,type, no_arg, arg, 1))
    end,

    histogram = function(self)
      -- double a[1] = {15.5}
      local tlen = ffi.new("size_t[?]",1)

      -- local a = ffi.new("int[10]")

      local t = handle_result(self, lib.MagickGetImageHistogram(self.wand, tlen))
      local tt = lib.PixelGetColorCount(t)

      -- lib.PixelGetRed(t)
      -- print(tlen)
      for i=0,2 do
        -- handle_new_pixel(self, t[i], lib.PixelGetColorCount(t[i]))
      end

      -- local t = handle_result(self, lib.MagickGetBackgroundColor(self.wand))
      -- local a = ffi.new(t)
    end,

    fuzz_image = function(self)
      -- local flen = ffi.new("const double[?]",20)
      return handle_result(self, lib.MagickSetImageFuzz(self.wand, 20))
    end,

    custom_emboss_ = function(self, grey, method)

      if method==1 then
        self.shadeImage(self,2,135,45)
        self.colorSpace(self,'gray')
        handle_result(self, lib.MagickSetImageDepth(self.wand, 32))
      elseif method==2 then
-- -m 2 -a 90 -e 90 -i 0 -d 8 -c linear_dodge

        -- local wand0 = self
        -- local wand1 = wand0.clone(wand0)
        --
        -- wand1.transform_image_colorspace(wand1)
        -- local wand2 = wand0.clone(wand0)
        -- self.negate(wand2,false)
        -- local wand3 = wand0.clone(wand0)
        -- --
        -- local PI = 3.14159265
        -- local args = {0.0,0.0,1.0,0.0,-math.cos(PI*(180-90)/180)*8/2,-math.sin(PI*(180-90)/180)*8/2}
        -- wand3.distort_image(wand3,3,6,args)
        -- wand3.image_artifact(wand3, "compose:args", "50")
        -- --
        -- local wand4 = wand3.clone(wand3)
        -- local args = {0.0,0.0,1.0,0.0,math.cos(PI*(180-90)/180)*8/2,math.sin(PI*(180-90)/180)*8/2}
        -- wand4.distort_image(wand4,3,6,args)
        -- wand4.image_artifact(wand4, "compose:args", "50")
        --
        -- --
        -- -- self.image_artifact(wand4, "compose:args", "50")
        -- -- self.image_artifact(wand3, "compose:args", "50")
        --
        -- wand3.composite(wand3,wand4,0,0,"LinearDodgeCompositeOp")
        -- wand3.level_image(wand3, 100, 1.0, 0)
        -- wand3.composite(wand3,wand1,0,0,"LinearDodgeCompositeOp")
        self = wand3
      end

    end,

    transform_image_colorspace = function(self)
      handle_result(self, lib.MagickTransformImageColorspace(self.wand, 3))
    end,

    image_artifact = function(self, artifact, value)
      handle_result(self, lib.MagickSetImageArtifact(self.wand, artifact, value))
    end,

    level_image = function(self, percentage, gamma, white_point)
      local percentage = percentage*65535/100;
      handle_result(self, lib.MagickLevelImage(self.wand, percentage, gamma, white_point))
    end,

    custom_cylinderize = function(self, mod, radius, length, wrap, pitch, efact, angle, narrow)
      local mod = ffi.new("char[?]", 10, mod)

      -- local arg = ffi.new("NULL", nil)
      -- local test =  handle_result(self, lib.MagickCylinderize(self.wand,"vertical",0,0,0,0,0,0))
      -- -r 472.03813405274 -l 356.029 -w 16.6667 -p 18.145578659481 -n 90.686478261958 -e 1.75
      -- local test =  handle_result(self, lib.MagickCylinderize(self.wand,"vertical",472.03813405274, 356.029, 16.6667, 18.145578659481, 1.75, 0.0,90.00))
      local test = handle_result(self, lib.MagickCylinderize(self.wand, mod, radius, length, wrap, pitch, efact, angle, narrow))
      -- 366.34955984688, 188.179, 16.6667, 23.428692808745, 1.75, 0.0
      return test
    end,

    custom_emboss= function(self, method, azimuth, elevation, depth, intensity, compose, gray)
      local op = "LinearDodgeCompositeOp"
      op = assert(composite_operators:to_int(op), "invalid operator type")
      local test =  handle_result(self, lib.MagickCustomEmboss(self.wand, method, azimuth, elevation, depth, intensity, compose, gray))
      return test
    end,

    coloration = function(self, hue, sat, light)
      local test =  handle_result(self, lib.MagickColoration(self.wand, hue, sat, light))
      return test
    end,

    dominant_color = function(self)
      local color = lib.MagickGetDominantColor(self.wand)
      do
        local _with_0 = ffi.string(color):lower()
        lib.MagickRelinquishMemory(color)
        return _with_0
      end
    end,

    wooden = function(self, blob, kind, presharp, blur, dither, postsharp, azimuth, intensity, mix, colors, sat, hue, edge)
      if type(blob) == "table" and blob.__class == Image then
        blob = blob.wand
      end

      local kind = ffi.new("char[?]", 6, kind)
      local dither = ffi.new("char[?]", 3, dither)
      local colors = ffi.new("char[?]", 15, colors)

      local test =  handle_result(self, lib.MagickSetWooden(self.wand, blob, kind, presharp, blur, dither, postsharp, azimuth, intensity, mix, colors, sat, hue, edge))
      return test
    end,

    bevel = function(self, form, azimuth, elevation, depth, width, soften, imode, omode, taper, bcolor, colormode)
      local form = ffi.new("char[?]", 10, form)
      local imode = ffi.new("char[?]", 10, imode)
      local omode = ffi.new("char[?]", 10, omode)
      local taper = ffi.new("char[?]", 10, taper)
      local bcolor = ffi.new("char[?]", 10, bcolor)
      local colormode = ffi.new("char[?]", 10, colormode)

      self.wand = ffi.gc(lib.MagickBevelImage(self.wand, form, azimuth, elevation, depth, width, soften, imode, omode, taper, bcolor, colormode), ffi.DestroyMagickWand)
      return true
    end,

    tshirt = function(self, place, coords, region, fit, gravity, vshift, offset, rotate, lighting, blur, displace, sharpen, antialias, export)
      if type(place) == "table" and place.__class == Image then
        place = place.wand
      end

      local coords = ffi.new("char[?]", 10, coords)
      local region = ffi.new("char[?]", 20, region)
      local fit = ffi.new("char[?]", 10, fit)
      local gravity = ffi.new("char[?]", 10, gravity)
      local offset = ffi.new("char[?]", 10, offset)
      local export = ffi.new("char[?]", 10, export)
      self.wand  = ffi.gc(lib.MagickTshirtImage(self.wand, place, coords, region, fit, gravity, vshift, offset, rotate, lighting, blur, displace, sharpen, antialias, export), ffi.DestroyMagickWand)
      return true
    end,

    leather_engrave = function(self, product)
      local pixel = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      lib.PixelSetColor(pixel, "white")
      -- local x = lib.QuantumRange
      -- print(x)
      local x, y
      local i_width = self.get_width(self)
      local i_height = self.get_height(self)
      local p_width = self.get_width(product)
      local p_height = self.get_height(product)

      x = (i_width-p_width)/2;
      y = (i_height-p_height)/2;

      handle_result(self, lib.MagickTransparentPaintImage(self.wand, pixel, 0.0, 20.0*65535.0/100.0, 0))
      self.composite(self, product.wand, x, y, 2)
      self.bevel(self, "inner", 135.0, 30.0, 100.0, 5.0, 0.0, "smooth", "lowered", "", "black", "dark");
      handle_result(self, lib.MagickSetImageAlphaChannel(self.wand,10))
      -- self.composite(product, self.wand, (p_width-i_width)/2, (p_height-i_height)/2, 55);
      --   MagickSetImageAlphaChannel(wand1, OnAlphaChannel);
      --   MagickSetImageChannelMask(wand1, RGBChannels);
      --   PixelSetColor(PW2, "rgb(207,14,9)");
      -- PixelSetColor(PW3, "rgba(207,14,9,0.6)");
      -- MagickOpaquePaintImage(wand1, PW2, PW3, 20*QuantumRange/100, MagickFalse);
      -- DestroyPixelWand(PW2);
      -- DestroyPixelWand(PW3);
    end,

    deep_etch = function(self)

      self.single_color(self, "black", 20);
      handle_result(self, lib.MagickSetImageAlphaChannel(self.wand,8))
      handle_result(self, lib.MagickSetImageAlphaChannel(self.wand,4))
      self.negate(self,0)
      -- --
      -- --fuzz $fuzz% -transparent white
      local pixelTargetWhite = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      local pixelFillTransparent= ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      handle_result(self, lib.PixelSetColor(pixelTargetWhite, "white"))
      handle_result(self, lib.PixelSetColor(pixelFillTransparent, "transparent"))
      handle_result(self, lib.MagickOpaquePaintImage(self.wand, pixelTargetWhite, pixelFillTransparent, 20.0*65535.0/100.0, 0))
      -- -- --
      self.custom_emboss(self, 2, 135, 45, 4.0, 50.0, 0, 0.9)
      -- --
      -- -- -fuzz 10% -fill 'rgb(230,230,230)' -opaque 'rgb(255,255,255)
      local pixel1 = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      local pixel2= ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      handle_result(self, lib.PixelSetColor(pixel1, "rgb(255,255,255)"))
      handle_result(self, lib.PixelSetColor(pixel2, "rgb(230,230,230)"))
      handle_result(self, lib.MagickOpaquePaintImage(self.wand, pixel1, pixel2, 10.0*65535.0/100.0, 0))

    end,

    four_colour = function(self, width, height, shape, plate_color)
      print(width)
      print(height)
      
      local x0 = width/2
      local y0 = height/2
      
      local x1 = (width)/2
      local y1 = (y0)/2
      
      if y1 < 30 then 
        y1 = 30
      end
    
      lib.MagickSetImageAlphaChannel(self.wand,9)
      local cloneWand = self.clone(self)
      local dwand = ffi.gc(lib.NewDrawingWand(), lib.DestroyDrawingWand)
      --
      lib.MagickThresholdImage(cloneWand.wand, 1.0)
      self.negate(cloneWand, 0)
      -- lib.DrawEllipse(dwand, 254.27, 121.0, 254.27, 60.5, 0, 360)
      lib.DrawEllipse(dwand, x0, y0, x1, y1, 0, 360)

      local pixel1 = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      local pixel2= ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      lib.PixelSetColor(pixel1, "#000000")
      lib.PixelSetColor(pixel2, "white")
      lib.MagickTransparentPaintImage(cloneWand.wand, pixel2, 0.0, 20.0*65535.0/100.0, 0)
      lib.MagickDrawImage(cloneWand.wand,dwand)
      self.composite(self, cloneWand, 0, 0, 17);
      self.bevel(self, "inner", 135.0, 30.0, 100.0, 10.0, 5.0, "hard", "lowered", "2", "white", "light");

      -- MagickSetImageAlphaChannel(wand, OffAlphaChannel);
      --
      -- wand1 = CloneMagickWand(wand);
      -- MagickThresholdImage(wand1, 1.0);
      -- MagickNegateImage(wand1, MagickFalse);
      -- DrawEllipse(dwand, 254.27, 121.0, 254.27, 60.5, 0, 360);
      -- PixelSetColor(PW1,"#000000");
      -- PixelSetColor(PW2,"white");
      -- DrawSetStrokeColor(dwand, PW1);
      -- MagickTransparentPaintImage(wand1, PW2, 0.0,  20.0*QuantumRange/100.0, MagickFalse);
      -- DrawSetFillColor(dwand,PW2);
      -- MagickDrawImage(wand1,dwand);
      --
      -- MagickCompositeImage(wand, wand1, CopyAlphaCompositeOp, MagickFalse, 0, 0);
      -- wand2 = MagickBevelImage(wand, "inner", 135.0, 30.0, 100.0, 10.0, 5.0, "hard", "lowered", "2", "white", "light");

    end,

    gel_dom = function(self)
      -- local fuzz = 20*65535/100;
      --
      -- local pixelTargetWhite = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      -- local pixelFillTransparent= ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      --
      -- handle_result(self, lib.PixelSetColor(pixelTargetWhite, "white"))
      -- handle_result(self, lib.PixelSetColor(pixelFillTransparent, "#00000000"))
      -- handle_result(self, lib.MagickOpaquePaintImage(self.wand, pixelTargetWhite, pixelFillTransparent, fuzz, 0))
      self.bevel(self, "inner", 135.0, 30.0, 100.0, 10.0, 5.0, "hard", "lowered", "2", "white", "light");
    end,

    toneontoneImage = function(self)
      local fuzz = 27.0*65535.0/100.0;

      local pixelTargetWhite = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      local pixelFillTransparent= ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)

      handle_result(self, lib.PixelSetColor(pixelTargetWhite, "white"))
      handle_result(self, lib.PixelSetColor(pixelFillTransparent, "#00000000"))
      handle_result(self, lib.MagickOpaquePaintImage(self.wand, pixelTargetWhite, pixelFillTransparent, fuzz, 0))

      handle_result(self, lib.MagickSetImageAlphaChannel(self.wand,8))
      -- handle_result(self, lib.MagickSetImageAlphaChannel(self.wand,4))
      self:negate(0)
    end,

    glassImage = function(self, logoColor)
      if logoColor and  logoColor ~= '' then
        
        print(logoColor)
        self:single_color(logoColor,20)
        self:custom_emboss(1, 135.0, 10.0, 2.0, 0.0, 42, 0.0)      
      else
        self:single_color("rgb(229,229,229)",20)
        self:custom_emboss(1, 135.0, 40.0, 10.0, 0.0, 42, 0.0)
        -- 'convert '. $newimage .' -alpha set -evaluate set 90% '.$newimage
        lib.MagickSetImageAlphaChannel(self.wand,13)
        -- handle_result(self, lib.MagickEvaluateImage(self.wand, 0, 90.0*65535.0*0.01))
      end
    end,

    deboss = function(self)
      self:custom_emboss(2, 135.0, 40.0, 1.0, 0.0, 42, 0.0)
      handle_result(self, lib.MagickSetImageAlphaChannel(self.wand,8))
      handle_result(self, lib.MagickSetImageAlphaChannel(self.wand,8))
      self:negate(0)
    end,

    textToImage = function(self, text, font, textSize, textColor, no_args, args)
      local font = ffi.new("char[?]", 100, font)
      local text = ffi.new("char[?]", 50, text)
      local textColor = ffi.new("char[?]", 50, textColor)
      local arguments = ffi.new("double[?]", no_args, args)
    --   double arguments[1] = {320};
    -- MagickDistortImage(magick_wand, ArcDistortion, 1, arguments, MagickTrue);

      handle_result(self, lib.MagickSetTextToImage(self.wand, font, text, textSize, textColor, no_args, arguments))
      return true
    end,

    transparent_background = function(self, target_color)
      local pixel = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
      lib.PixelSetColor(pixel, target_color)

      handle_result(self, lib.MagickTransparentPaintImage(self.wand, pixel, 0.0, 20.0*65535.0/100.0, 0))
    end,

    __tostring = function(self)
      return "Image<" .. tostring(self.path) .. ", " .. tostring(self.wand) .. ">"
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, wand, path)
      self.wand, self.path = wand, path
    end,
    __base = _base_0,
    __name = "Image",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.load = function(self, path)
    local wand = ffi.gc(lib.NewMagickWand(), lib.DestroyMagickWand)
    if 0 == lib.MagickReadImage(wand, path) then
      local code, msg = get_exception(wand)
      return nil, msg, code
    end
    return self(wand, path)
  end
  self.newImage = function(self, width, height)
    local wand = ffi.gc(lib.NewMagickWand(), lib.DestroyMagickWand)
    local pixel = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
    lib.PixelSetColor(pixel, "none")

    if 0 == lib.MagickNewImage(wand, width, height, pixel) then
      local code, msg = get_exception(wand)
      return nil, msg, code
    end
    return self(wand)
  end
  self.load_from_blob = function(self, blob)
    local wand = ffi.gc(lib.NewMagickWand(), lib.DestroyMagickWand)
    if 0 == lib.MagickReadImageBlob(wand, blob, #blob) then
      local code, msg = get_exception(wand)
      return nil, msg, code
    end
    return self(wand, "<from_blob>")
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Image = _class_0
end
return {
  Image = Image
}
