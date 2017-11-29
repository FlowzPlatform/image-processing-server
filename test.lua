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
  img = magick.load_image("html/four.png")
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
  img = magick.load_image("html/1492085906_signet-logo.png")
elseif ngx.var.arg_text then
  img = magick.new_image(500,70)
else

  img = magick.load_image("html/shirt-1490420206-a15bc00a09077730c2a8dd98907d1b10.jpg")
  -- img = magick.load_image("html/wood.jpg")
end
-- img = magick.load_image_from_blob("data:image/png;base64,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")





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

if ngx.var.arg_debose then

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
  img:four_colour()
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

img:transparent_background('white')


img:write("html/resized.png")
img:destroy()
ngx.exec("/resized.png")
