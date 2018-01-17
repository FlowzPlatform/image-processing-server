--*********** we can use anyone*********
-- local magick = require "magick.gmwand"
-- local magick = require "magick.wand"
local magick = require "magick"
-- require "profiler


-- local img = assert(magick.load_image("html/leafo.jpg"))
-- local img = magick.load_image("html/Bill_Murray_small.jpg")
-- local img = magick.load_image("html/Morning.jpg")
-- local img = magick.load_image("html/binaryimage.gif")
-- local img = magick.load_image("html/leafo.jpg")
-- local img = magick.load_image("html/yahoo.jpg")
-- local img = magick.load_image("html/single_color.png")
-- local img = magick.load_image("html/google.png")

-- local img = magick.load_image("html/lena.jpg")
-- local img = magick.load_image("html/tshirt.jpg")
-- local img = magick.load_image("html/input.png")
-- local img = magick.load_image("html/four.png")
local img
if ngx.var.arg_tshirt then
  img = magick.load_image("html/place.jpg")
elseif ngx.var.arg_four_colour then
  img = magick.load_image("html/foil.png")
elseif ngx.var.arg_custom_emboss then
  img = magick.load_image("html/lena.jpg")
elseif ngx.var.arg_wooden then
  img = magick.load_image("html/Bill_Murray_small.jpg")
elseif ngx.var.arg_cylinder then
  img = magick.load_image("html/yahoo.jpg")
elseif ngx.var.arg_bevel then
  img = magick.load_image("html/google.png")
elseif ngx.var.arg_leather_engrave then
  img = magick.load_image("html/google.png")
elseif ngx.var.arg_glass_image then
  img = magick.load_image("html/single_color.png")
elseif ngx.var.arg_foil then
  img = magick.load_image("html/four.png")
elseif ngx.var.arg_text then
  img = magick.new_image(500,70)
else

  img = magick.load_image("html/google.png")
  -- img = magick.load_image("html/wood.jpg")
end
-- img = 


-- local handle = io.popen("./cylinderize.sh -m vertical -r 366.34955984688 -l 188.179 -w 16.6667 -p 23.428692808745 -n 96.097053534591 -e 1.75 -a 0 -v background -b none -f none -o -86-80.8315 yahoo.jpg yahooC.jpg")
-- local result = handle:read("*a")
-- -- local handle = io.popen("composite -compose Src_Over yahooC.jpg mugs.jpg output.jpg")
-- -- local result = handle:read("*a")
-- handle:close()


-- function hex2rgb(hex)
--     hex = hex:gsub("#","")
--     return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
-- end

--**************COVER ALL IMAGE OPTIONS************

--resize images
--Note: for imagemagick, this is not available
--[[
  Status: It's working now as I have changed in library.
  Changes:
    1. get_filter function->magick/wand/lib.lua
       -- changed vaiable fname, line number 128
       -- changed filter_types, line number 155
    2. changed in if get_filter block->magick/wand/lib.lua
       -- changed const FilterTypes to const FilterType, line number 174
]]--
if ngx.var.arg_height and ngx.var.arg_crop ~= "1" then
  img:resize(tonumber(ngx.var.arg_width), tonumber(ngx.var.arg_height))
end

-- blur image
if ngx.var.arg_blur then
  img:blur(4, 0)
end

--rotate image
--Note: for graphicmagick, this is not available
if ngx.var.arg_rotate then
  img:rotate(tonumber(ngx.var.arg_rotate), 0, 0, 1)
end

if ngx.var.arg_distort then
  local xxx = img:distortImage()
end

-- trying to achieve wooden effect start, include compose image
-- img:contrastImage(10)
-- img:sharpen(0,0)
-- img:edgeImage(0)
-- img:shadeImage(1,360,360)
--wooden effect end

-- trying embroidery
-- local Iheight = img:get_height()
-- local Iwidth = img:get_width()
-- local TIwidth = Iwidth*2
-- local TIheight = Iheight*2
--
-- print("logging hW=======")
-- print(Iheight*2)
-- print(Iwidth*2)
-- local test = img:histogram()
-- print(test)

-- getheightwidth=>img:get_width() and img:get_height()
-- multiply height and width by 2
-- 1. MagickGetImageHistogram
-- 2. MagickResizeImage
-- 3. MagickAppendImages


--compose image
--Note: for graphicmagick, this is not available

-- img:set_quality(50)
-- local xxx = img:distortImage()
-- local xxx = img:fuzz_image()
-- print(xxx)

--image resize and crop
--Note: for imagemagick, this is not available
--[[
  Due to changed in resize function, it's working now.
]]--
if ngx.var.arg_crop then
  img:resize_and_crop(tonumber(ngx.var.arg_width), tonumber(ngx.var.arg_height))
end

--image modulate
if ngx.var.arg_modulate then
  img:modulate(100,100,200)
end

--set image quality
if ngx.var.arg_quality then
  img:set_quality(tonumber(ngx.var.arg_quality))
end

--set emboss to image
if ngx.var.arg_emboss then
  img:emboss(0,1)
end

--flop image
if ngx.var.arg_flop then
  img:flop()
end

--flip image
if ngx.var.arg_flip then
  img:flip()
end

--negate the image
if ngx.var.arg_negate then
  img:negate(true)
end

--colorize image
if ngx.var.arg_colorize then
  local hex = ngx.var.arg_colorize:gsub("#","")
  local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
  img:imageColor(r,g,b)
end

if ngx.var.arg_custom_emboss then
  -- method -> 1
  -- azimuth -> 135
  -- elevation -> 45
  -- depth -> 1
  -- intensity -> 0
  -- compose -> 42
  -- grey -> 0
  -- img:custom_emboss(1, 135, 45, 1, 0, 42, 0)
  img:custom_emboss(2, 90.0, 90.0, 8.0, 0.0, 42, 0.0)

end

if ngx.var.arg_deboss then
  img:deboss()
end

if ngx.var.arg_single_color then
  local hex = ngx.var.arg_single_color:gsub("#","")
  local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
  img:single_color("rgb("..r..","..g..","..b..")",20)
end

if ngx.var.arg_charcoal then
  img:charcoalImage(0,0)
end
-- img:toneImage(100)

if ngx.var.arg_cylinder then
   img:custom_cylinderize("vertical",250.03813405274, 100.029, 15.6667, 15.145578659481, 1.75, 0.0,90.00)
  --  local imgSrc = magick.load_image("html/mugs.jpg")
  --  imgSrc:resize(500,500)
  --  imgSrc:composite(img, -120, 150, "SrcOverCompositeOp")
  --  img = imgSrc
end

if ngx.var.arg_firebranded then
  img:coloration(0.0,50.0,0.0);
end

if ngx.var.arg_wooden then
  print("Ola")
  local woodenImg = magick.load_image("html/wood.jpg")
  woodenImg:wooden(img, "carve", 12, 3, "25", 0.0, 135, 2, 40, "black,white", 125.0, 100.0, 1)
  img = woodenImg
end

if ngx.var.arg_bevel then
  img:bevel("inner", 135.0, 30.0, 100.0, 5.0, 4.0, "smooth", "lowered", "", "black", "dark")
end

if ngx.var.arg_tshirt then
  local tshirt_image = magick.load_image("html/tshirt.jpg")
  img:tshirt(tshirt_image, "", "130x130+275+175", "none", "center", 0, "", 0, 20, 1, 10, 1, 2, "no")
  -- print(ts)
  -- img = ts
end

if ngx.var.arg_deep_etch then
  img:deep_etch()
end

if ngx.var.arg_leather_engrave then
  local product = magick.load_image("html/7832_black.jpg")
  img:leather_engrave(product)
  -- local imgSrc = magick.load_image("html/7832_black.jpg")
  product:composite(img, 120, 300, "OverCompositeOp")
  img = product
end

if ngx.var.arg_four_colour then
  print(img:get_width())
  print(img:get_height())
  img:four_colour(img:get_width(), img:get_height(), 'oval', '000000')
end

if ngx.var.arg_dominant_color then
  local color = img:dominant_color();
  print(color)
end

-- img:transpose()
-- img:transverse()

if ngx.var.arg_compose then
  -- local imgSrc = magick.load_image("html/7832_black.jpg")
  local imgSrc = magick.load_image("html/tshirt.jpg")
  local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2

  imgSrc:composite(img, 0, 0, "SrcOverCompositeOp")
  -- imgSrc:composite(img, 120, 300, "OverCompositeOp")

  -- imgSrc:composite(img, -500, 500, "SrcOverCompositeOp")
  img = imgSrc
  -- "SrcOverCompositeOp"
end

if ngx.var.arg_foil then
    local imgSrc = magick.load_image("html/yellow.gif.jpg")
    -- imgSrc:composite(img, 0, 0, "AtopCompositeOp")
    img:composite(imgSrc, 0, 0, "AtopCompositeOp")
    -- DstAtopCompositeOp
    -- img = imgSrc
end

if ngx.var.arg_gel_dom then
  img:gel_dom();
end

if ngx.var.arg_glass_image then
  img:glassImage();
end



if ngx.var.arg_toneontoneImage then
  img:toneontoneImage();
  -- local imgSrc = magick.load_image("html/7832_black.jpg")
  -- local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2
  -- imgSrc:composite(img, x, y, "OverCompositeOp")
  -- img = imgSrc
end

if ngx.var.arg_text then
  img:textToImage(ngx.unescape_uri(ngx.var.arg_text),"Noto-Sans-Mono-CJK-SC-Bold", tonumber(ngx.var.arg_font_size),"#000000",1,0.0);
  -- "#"..textColor[d], 1, {tonumber(text_curve_a[d])
end


-- local Image = img:clone()
-- Image:write("html/resized.png")

--[[
No need to write image physically
]]--

-- local blobStr = img:get_blob()
-- ngx.say(blobStr);
-- print(blobStr)

--[[
write image physically and display
]]--

-- img:transparent_background('white')


img:write("html/resized.png")
img:destroy()
ngx.exec("/resized.png")
