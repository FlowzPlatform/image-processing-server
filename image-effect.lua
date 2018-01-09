local sig, size, path, ext = ngx.var.arg_sig, ngx.var.arg_size, ngx.var.path, ngx.var.ext
local height, width, rotate, single_color = (ngx.var.arg_h and ngx.var.arg_h or ""), (ngx.var.arg_w and ngx.var.arg_w or ""),
(ngx.var.arg_rotate and ngx.var.arg_rotate or ""), (ngx.var.arg_single_color and ngx.var.arg_single_color or "")

local emboss, cylinder, deboss, crop, fire, compose,
flip, flop, negate, wooden, bevel, fabric, deep_etch,
engrave, four_colour, dcolor, foil, geldom, toneontone, background, cropped = (ngx.var.arg_emboss and ngx.var.arg_emboss .. "emboss" or ""),
(ngx.var.arg_cylinder and ngx.var.arg_cylinder .. "cylinder" or ""),
(ngx.var.arg_deboss and ngx.var.arg_deboss .. "deboss" or ""),
(ngx.var.arg_crop and ngx.var.arg_crop .. "crop" or ""), (ngx.var.arg_fire and ngx.var.arg_fire .. "firebranded" or ""),
(ngx.var.arg_compose and ngx.var.arg_compose .. "compose" or ""),
(ngx.var.arg_flip and ngx.var.arg_flip or ""), (ngx.var.arg_flop and ngx.var.arg_flop or ""),
(ngx.var.arg_negate and ngx.var.arg_negate .. "negate" or ""), (ngx.var.arg_wooden and ngx.var.arg_wooden .. "wooden" or ""), (ngx.var.arg_bevel and ngx.var.arg_bevel .. "bevel" or ""),
(ngx.var.arg_fabric and ngx.var.arg_fabric .. "fabric" or ""), (ngx.var.arg_deep_etch and ngx.var.arg_deep_etch .. "deep_etch" or ""),
(ngx.var.arg_leather_engrave and ngx.var.arg_leather_engrave .. "engrave" or ""), (ngx.var.arg_four_colour and ngx.var.arg_four_colour .. "four_colour" or ""),
(ngx.var.arg_dominant_color and ngx.var.arg_dominant_color .. "dominant_color" or ""), (ngx.var.arg_foil and ngx.var.arg_foil .. "foil" or ""),
(ngx.var.arg_gel_dom and ngx.var.arg_gel_dom .. "gel_dom" or ""), (ngx.var.arg_toneontoneImage and ngx.var.arg_toneontoneImage .. "toneontoneImage" or ""),
(ngx.var.arg_back and ngx.var.arg_back or ""), (ngx.var.arg_cropped and ngx.var.arg_cropped .. 'cropped' or "")

local compose_x, compose_y = (ngx.var.arg_compose_x and ngx.var.arg_compose_x or "") , (ngx.var.arg_compose_y and ngx.var.arg_compose_y or "")


-- TODO this needs to change
local compose_w, compose_h = (ngx.var.arg_c_w and ngx.var.arg_c_w or 410) , (ngx.var.arg_c_h and ngx.var.arg_c_h or 500)

local cImages = (ngx.var.arg_images and ngx.var.arg_images or "")

local texts, text, font_size = (ngx.var.arg_texts and ngx.var.arg_texts or ""), (ngx.var.arg_text and ngx.var.arg_text .. "text" or ""), (ngx.var.arg_font_size and ngx.var.arg_font_size or "")
local area_w, area_h = (ngx.var.arg_area_w and ngx.var.arg_area_w or ""), (ngx.var.arg_area_h and ngx.var.arg_area_h or "")
local font_size, text_width, text_height, text_composex, text_composey, text_color, text_flip, text_flop, text_rotate, font_family, text_curve, orders = (ngx.var.arg_font_size and ngx.var.arg_font_size or ""),
(ngx.var.arg_text_w and ngx.var.arg_text_w or ""),
(ngx.var.arg_text_h and ngx.var.arg_text_h or ""),
(ngx.var.arg_text_c_x and ngx.var.arg_text_c_x or ""),
(ngx.var.arg_text_c_y and ngx.var.arg_text_c_y or ""),
(ngx.var.arg_text_color and ngx.var.arg_text_color or ""),
(ngx.var.arg_text_flip and ngx.var.arg_text_flip or ""),
(ngx.var.arg_text_flop and ngx.var.arg_text_flop or ""),
(ngx.var.arg_text_rotate and ngx.var.arg_text_rotate or ""),
(ngx.var.arg_font_family and ngx.var.arg_font_family or ""),
(ngx.var.arg_text_curve and ngx.var.arg_text_curve or ""),
(ngx.var.arg_layers and ngx.var.arg_layers or "")


local secret = "hello_world" -- signature secret key
local images_dir = "html/user-uploaded-images/" -- where images come from
local cache_dir = "cache/" -- where images are cached
local image_dest = ngx.var.arg_image

local function return_not_found(msg)
  ngx.status = ngx.HTTP_NOT_FOUND
  ngx.header["Content-type"] = "text/html"
  ngx.say(msg or "not found")
  ngx.exit(0)
end

local function calculate_signature(str)
  return ngx.encode_base64(ngx.hmac_sha1(secret, str))
    :gsub("[+/=]", {["+"] = "-", ["/"] = "_", ["="] = ","})
    :sub(1,12)
end


local calculated_sig = calculate_signature(path .. height .. width .. emboss .. cylinder .. deboss .. crop .. fire .. compose .. rotate
.. flip .. flop .. negate .. wooden .. single_color .. bevel .. fabric .. deep_etch
.. engrave .. four_colour .. dcolor .. foil .. geldom .. toneontone .. compose_x .. compose_y .. text .. font_size .. area_w .. area_h
.. font_size .. text_width .. text_height .. text_composex .. text_composey .. text_color .. text_flip .. text_flop .. text_rotate
.. font_family .. texts .. text_curve .. background .. orders .. cropped)

if(calculate_signature("obVMC@123") ~= sig) then
  return_not_found("Invalid signature")
end

-- make sure destination already exists
local output_file = cache_dir .. calculated_sig .. "." .. ext
local ofile = io.open(output_file)
if ofile then
  -- ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)
end


-- for loop here
local magick = require "magick"
local multiText = nil
local multiImage = nil
local vv = nil
local vvText = nil

if texts then
  multiText = 1
end

if cImages ~= '' then
  multiImage = 1
end

function stringToArray (str)

  local j = 1
  local arr = {}

  for i in string.gmatch(str, '([^,]+)') do
    arr[j] = i
    j = j+1
  end

  return arr
end


local dest_fname = cache_dir .. calculated_sig .. "." .. ext

function process_img()
  image(0)
end

function explode(d,p)
   local t, ll
   t={}
   ll=0
   if(#p == 1) then
      return {p}
   end
   while true do
      l = string.find(p, d, ll, true) -- find the next d in the string
      if l ~= nil then -- if "not not" found then..
         table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
         ll = l + 1 -- save just after where we found it for searching next time.
      else
         table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
         break -- Break at end, as it should be, according to the lua manual.
      end
   end
   return t
end

local img

function text()
  -- body
  local img
  img = magick.new_image(tonumber(area_w_x), tonumber(area_h_x))
  text_location = '/home/software/new/virtual-ssr/static/fonts/'
  local fontF = text_location .. font_family

  img:textToImage(ngx.unescape_uri(texts_a), fontF, tonumber(font_size_x), "#"..textColor, 1, {tonumber(text_curve_a)});

  if ngx.var.arg_height and crop ~= "1" then
    img:resize(tonumber(text_width), tonumber(text_height))
  end

  -- blur image
  if ngx.var.arg_blur and ngx.var.arg_blur ~= '' then
    img:blur(4, 0)
  end

  --rotate image
  --Note: for graphicmagick, this is not available
  if text_rotate_a then
    img:rotate(tonumber(text_rotate_a), 0, 0, 1)
  end

  if ngx.var.arg_distort then
    local xxx = img:distortImage()
  end

  if ngx.var.arg_crop then
    img:resize_and_crop(tonumber(text_width_x), tonumber(text_height_x))
  end

  --image modulate
  if ngx.var.arg_modulate then
    img:modulate(100,100,200)
  end

  --set image quality
  if ngx.var.arg_quality then
    img:set_quality(tonumber(ngx.var.arg_quality))
  end

  --flop image

  if text_flop_a ~= '0' and text_flop_a ~= nil then
    img:flop()
  end

  --flip image
  if text_flip_a ~= '0' and text_flip_a ~= nil then
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

  if ngx.var.arg_emboss then
    img:custom_emboss(2, 90.0, 90.0, 8.0, 0.0, 42, 0.0)
  end

  if ngx.var.arg_debose then

  end

  -- if ngx.var.arg_single_color then
  --   local hex = ngx.var.arg_single_color:gsub("#","")
  --   local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
  --   img:single_color("rgb("..r..","..g..","..b..")",20)
  -- end

  if ngx.var.arg_charcoal then
    img:charcoalImage(0,0)
  end


  if ngx.var.arg_fire then
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

  if ngx.var.arg_deep_etch then
    img:deep_etch()
  end

  if ngx.var.arg_four_colour then
    img:four_colour()
  end

  if ngx.var.arg_dominant_color then
    local color = img:dominant_color();
  end

  if ngx.var.arg_foil then
      imgSrc:composite(img, 0, 0, "AtopCompositeOp")
      img = imgSrc
  end

  if ngx.var.arg_gel_dom then
    img:gel_dom();
  end

  if ngx.var.arg_toneontoneImage then
    img:toneontoneImage();
    local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2
    imgSrc:composite(img, x, y, "OverCompositeOp")
    img = imgSrc
  end
end

function image()
    if ngx.var.arg_text and ngx.var.arg_text ~= '' then
      local textColor = (ngx.var.arg_text_color) and ngx.var.arg_text_color or '000000'
      local font_size = (ngx.var.arg_font_size) and ngx.var.arg_font_size or 50
      local text_curve = (ngx.var.arg_text_curve) and ngx.var.arg_text_curve or 0

      img = magick.new_image(500, 250)
      text_location = '/home/software/new/virtual-ssr/static/fonts/'
      local fontF = text_location .. font_family
      img:textToImage(ngx.unescape_uri(ngx.var.arg_text), fontF, tonumber(font_size), "#"..textColor, 1, {tonumber(text_curve)})
    else
      local source_fname = images_dir .. path
      local file = io.open(source_fname)
      if not file then
        return_not_found()
      end
      file:close()
      img = magick.load_image(source_fname)
    end

    if height ~= '' and width ~= '' and crop ~= "1" then
      img:resize(tonumber(width), tonumber(height))
    end

    -- blur image
    if ngx.var.arg_blur and ngx.var.arg_blur ~= '' then
      img:blur(tonumber(ngx.var.arg_blur), 0)
    end

    --rotate image
    --Note: for graphicmagick, this is not available
    if rotate ~= '' then
      img:rotate(tonumber(rotate), 0, 0, 1)
    end

    if ngx.var.arg_distort then
      local xxx = img:distortImage()
    end

    if crop ~= '' then
      img:resize_and_crop(tonumber(width), tonumber(height))
    end

    -- if ngx.var.arg_crop_ then


    -- end

    --image modulate
    if ngx.var.arg_modulate then
      img:modulate(100,100,200)
    end

    --set image quality
    if ngx.var.arg_quality then
      img:set_quality(tonumber(ngx.var.arg_quality))
    end

    --flop image
    if ngx.var.arg_flop and ngx.var.arg_flop ~= '' then
      img:flop()
    end

    --flip image
    if ngx.var.arg_flip and ngx.var.arg_flip ~= '' then
      img:flip()
    end

    --negate the image
    if ngx.var.arg_negate and ngx.var.arg_negate ~=''  then
      img:negate(true)
    end

    --colorize image
    if ngx.var.arg_colorize then
      local hex = ngx.var.arg_colorize:gsub("#","")
      local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
      img:imageColor(r,g,b)
    end

    if ngx.var.arg_emboss and ngx.var.arg_emboss ~= '' then
      img:custom_emboss(2, 90.0, 90.0, 8.0, 0.0, 42, 0.0)
    end

    if ngx.var.arg_debose then

    end

    if single_color ~= '' then
      local hex = single_color:gsub("#","")
      local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
      img:single_color("rgb("..r..","..g..","..b..")",20)
    end

    if ngx.var.arg_charcoal then
      img:charcoalImage(0,0)
    end

    if ngx.var.arg_glass then
      img:glassImage();
    end

    if ngx.var.arg_fire and ngx.var.arg_fire ~='' then
      img:coloration(0.0,50.0,0.0);
    end

    if ngx.var.arg_wooden and ngx.var.arg_wooden ~= '' then
      local woodenImg = magick.load_image("html/wood.jpg")
      woodenImg:wooden(img, "carve", 12, 3, "25", 0.0, 135, 2, 40, "black,white", 125.0, 100.0, 1)
      img = woodenImg
    end

    if ngx.var.arg_bevel then
      img:bevel("inner", 135.0, 30.0, 100.0, 5.0, 4.0, "smooth", "lowered", "", "black", "dark")
    end

    if ngx.var.arg_deep_etch then
      img:deep_etch()
    end

    if ngx.var.arg_four_colour then
      print(img:get_width())
      print(img:get_height())
      img:four_colour(img:get_width(), img:get_height(), 'oval', '000000')
    end

    if ngx.var.arg_dominant_color then
      local color = img:dominant_color();
    end

    if ngx.var.arg_gel_dom then
      img:gel_dom()
    end

    if ngx.var.arg_toneontoneImage and ngx.var.arg_toneontoneImage ~= '' then
      img:toneontoneImage();
    end

    -- if background_a ~= nil and background_a ~= '' then
    --   for i in string.gmatch(background_a, '([^-]+)') do
    --     img:transparent_background(i)
    --   end
    -- end
end

process_img()

print(dest_fname)
img:write(dest_fname)
img:destroy()
ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)
