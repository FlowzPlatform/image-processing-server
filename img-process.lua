
local sig, size, path, ext, height, width, emboss, cylinder, deboss, crop, fire, compose, rotate,
flip, flop, negate, wooden, single_color, bevel, fabric, deep_etch,
engrave, four_colour, dcolor, foil, geldom, toneontone, background, cropped = ngx.var.arg_sig, ngx.var.arg_size, ngx.var.path, ngx.var.ext,
(ngx.var.arg_height and ngx.var.arg_height or ""), (ngx.var.arg_width and ngx.var.arg_width or ""),
(ngx.var.arg_emboss and ngx.var.arg_emboss .. "emboss" or ""), (ngx.var.arg_cylinder and ngx.var.arg_cylinder .. "cylinder" or ""),
(ngx.var.arg_deboss and ngx.var.arg_deboss .. "deboss" or ""),
(ngx.var.arg_crop and ngx.var.arg_crop .. "crop" or ""), (ngx.var.arg_firebranded and ngx.var.arg_firebranded .. "firebranded" or ""),
(ngx.var.arg_compose and ngx.var.arg_compose .. "compose" or ""), (ngx.var.arg_rotate and ngx.var.arg_rotate or ""),
(ngx.var.arg_flip and ngx.var.arg_flip or ""), (ngx.var.arg_flop and ngx.var.arg_flop or ""),
(ngx.var.arg_negate and ngx.var.arg_negate .. "negate" or ""), (ngx.var.arg_wooden and ngx.var.arg_wooden .. "wooden" or ""),
(ngx.var.arg_single_color and ngx.var.arg_single_color .. "single_color" or ""), (ngx.var.arg_bevel and ngx.var.arg_bevel .. "bevel" or ""),
(ngx.var.arg_fabric and ngx.var.arg_fabric .. "fabric" or ""), (ngx.var.arg_deep_etch and ngx.var.arg_deep_etch .. "deep_etch" or ""),
(ngx.var.arg_leather_engrave and ngx.var.arg_leather_engrave .. "engrave" or ""), (ngx.var.arg_four_colour and ngx.var.arg_four_colour .. "four_colour" or ""),
(ngx.var.arg_dominant_color and ngx.var.arg_dominant_color .. "dominant_color" or ""), (ngx.var.arg_foil and ngx.var.arg_foil .. "foil" or ""),
(ngx.var.arg_gel_dom and ngx.var.arg_gel_dom .. "gel_dom" or ""), (ngx.var.arg_toneontoneImage and ngx.var.arg_toneontoneImage .. "toneontoneImage" or ""),
(ngx.var.arg_back and ngx.var.arg_back or ""), (ngx.var.arg_cropped and ngx.var.arg_cropped or "")

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


local artwork_height, artwork_width, artwork_left, artwork_top = ngx.var.arg_a_height, ngx.var.arg_a_width, ngx.var.arg_a_l, ngx.var.arg_a_t
-- local orders = 'i-2,i-1,t-1'


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
.. font_family .. texts .. text_curve .. background .. orders .. cropped .. artwork_left .. artwork_top)

if(calculate_signature("obVMC@123") ~= sig) then
  return_not_found("Invalid signature")
end

-- make sure destination already exists
local output_file = cache_dir .. calculated_sig .. "." .. ext
local ofile = io.open(output_file)
if ofile then
  ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)
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
local imgSrc = magick.load_image("html/product-images/"..path)
imgSrc:resize(tonumber(compose_w),tonumber(compose_h))



local images, images_x, images_y, height_x, width_x, flip_a, flop_a, cImages_a = {}, {}, {}, {}, {}, {}, {}, {}

local j = 1

images_x = stringToArray(compose_x)
images_y = stringToArray(compose_y)
height_x = stringToArray(height)
width_x = stringToArray(width)
flip_a = stringToArray(flip)
flop_a = stringToArray(flop)
rotate_a = stringToArray(rotate)
background_a = stringToArray(background)
cImages_a = stringToArray(cImages)

local area_w_x, area_h_x, font_size_x, text_width_x, text_height_x, text_compose_x, text_compose_y, textColor = {}, {}, {}, {}, {}, {}, {}, {}

local textsList, text_flip_a, text_flop_a, texts_a = {}, {}, {}, {}

local d = 1

area_w_x = stringToArray(area_w)
area_h_x = stringToArray(area_h)
font_size_x = stringToArray(font_size)
text_width_x = stringToArray(text_width)
text_height_x = stringToArray(text_height)
text_compose_x = stringToArray(text_composex)
text_compose_y = stringToArray(text_composey)
textColor = stringToArray(text_color)
text_flip_a = stringToArray(text_flip)
text_flop_a = stringToArray(text_flop)
text_rotate_a = stringToArray(text_rotate)
text_curve_a = stringToArray(text_curve)
texts_a = stringToArray(texts)

-- local orders = 'i-1'
function process_img()
    orders_x = stringToArray(orders)
    for i, v in ipairs(orders_x) do      
      local tt = explode("-", v) --> {"a", "b", "c"}
      if tt[1] == 't' then
        text(tonumber(tt[2]), imgSrc)
      else
        image(tonumber(tt[2]), imgSrc)
      end
    end
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

function text( d )
  -- body
  local img

  print(area_w_x[d])
  print(area_h_x[d])

  img = magick.new_image(tonumber(area_w_x[d]), tonumber(area_h_x[d]))
  text_location = '/home/software/new/virtual-ssr/static/fonts/'
  local fontF = text_location .. font_family

  img:textToImage(ngx.unescape_uri(texts_a[d]), fontF, tonumber(font_size_x[d]), "#"..textColor[d], 1, {tonumber(text_curve_a[d])});
  
  if ngx.var.arg_height and ngx.var.arg_crop ~= "1" then
    img:resize(tonumber(text_width_x[d]), tonumber(text_height_x[d]))
  end

  -- blur image
  if ngx.var.arg_blur then
    img:blur(4, 0)
  end

  --rotate image
  --Note: for graphicmagick, this is not available
  if text_rotate_a[d] then
    img:rotate(tonumber(text_rotate_a[d]), 0, 0, 1)
  end

  if ngx.var.arg_distort then
    local xxx = img:distortImage()
  end

  if ngx.var.arg_crop then
    img:resize_and_crop(tonumber(text_width_x[d]), tonumber(text_height_x[d]))
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

  if text_flop_a[d] ~= '0' and text_flop_a[d] ~= nil then
    img:flop()
  end

  --flip image
  if text_flip_a[d] ~= '0' and text_flip_a[d] ~= nil then
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

  if ngx.var.arg_cylinder then
     img:custom_cylinderize("vertical",250.03813405274, 100.029, 15.6667, 15.145578659481, 1.75, 0.0,90.00)
     -- local imgSrc = magick.load_image("html/mugs.jpg")
     imgSrc:resize(500,500)
     imgSrc:composite(img, -120, 150, "SrcOverCompositeOp")
     img = imgSrc
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

  if ngx.var.arg_fabric then
    local cmp_x,cmp_y = text_compose_x[d],text_compose_y[d]
    local tshirt  = magick.load_image("html/product-img-1.png")
    tshirt:resize(tonumber(compose_w),tonumber(compose_h))
    local cordinate = text_width_x[d] .. 'x' .. text_height_x[d] .. '+' .. cmp_x .. '+' .. cmp_y
    img:tshirt(tshirt, "", cordinate, "none", "center", 0, "", 0, 20, 1, 10, 1, 2, "no")
  end

  if ngx.var.arg_deep_etch then
    img:deep_etch()
  end

  if ngx.var.arg_leather_engrave then
    -- local product = magick.load_image("html/7832_black.jpg")
    img:leather_engrave(imgSrc)

    -- local imgSrc = magick.load_image("html/7832_black.jpg")
    -- imgSrc:composite(img, 120, 300, "OverCompositeOp")
    -- img = imgSrc
  end

  if ngx.var.arg_four_colour then
    img:four_colour()
  end

  if ngx.var.arg_dominant_color then
    local color = img:dominant_color();
    -- print(color)
  end

  if ngx.var.arg_foil then
      -- local imgSrc = magick.load_image("html/yellow.gif.jpg")
      imgSrc:composite(img, 0, 0, "AtopCompositeOp")
      img = imgSrc
  end

  if ngx.var.arg_gel_dom then
    img:gel_dom();
  end

  if ngx.var.arg_toneontoneImage then
    img:toneontoneImage();
    -- local imgSrc = magick.load_image("html/7832_black.jpg")
    local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2
    imgSrc:composite(img, x, y, "OverCompositeOp")
    img = imgSrc
  end

  -- local x_cord, y_cord = tonumber(artwork_left), tonumber(artwork_top)
  -- print(x_cord)
  -- print(y_cord)

  -- if (text_width_x[d]+text_compose_x[d]) > tonumber(artwork_width) then
  --   x_cord = text_width_x[d]+text_compose_x[d] - tonumber(artwork_width)
  -- end

  -- if (text_height_x[d]+text_compose_y[d]) > tonumber(artwork_height) then
  --   y_cord = text_height_x[d]+text_compose_y[d] - tonumber(artwork_height)
  -- end

  -- if x_cord ~= 0 or y_cord ~= 0 then 
  --   img:crop(tonumber(text_width_x[d]), tonumber(text_height_x[d]), -x_cord, -y_cord)
  -- end


-- text_compose_y

  x_cord_x = tonumber(artwork_left) - tonumber(text_compose_x[d])
  y_cord_x = tonumber(artwork_top) - tonumber(text_compose_y[d])

  -- print(artwork_left.."===="..artwork_top)
  -- print(text_width_x[d].."===="..text_height_x[d])
  -- print(x_cord_x.."===="..y_cord_x)

  img:crop(tonumber(artwork_width), tonumber(artwork_height), x_cord_x, y_cord_x)


  cmp_x,cmp_y = text_compose_x[d],text_compose_y[d]
  local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2

  if ngx.var.arg_fabric then
    imgSrc:composite(img, 0, 0, "SrcOverCompositeOp")
  else
    local composite_x, composite_y

    composite_x = x_cord_x+tonumber(cmp_x)
    composite_y = y_cord_x+tonumber(cmp_y)

    if x_cord_x<0 then 
      composite_x = tonumber(cmp_x)
    end

    if y_cord_x<0 then 
      composite_y = tonumber(cmp_y)
    end
    imgSrc:composite(img, composite_x, composite_y, "SrcOverCompositeOp")
  end
end

function image( j )
  -- body
    local img
    local source_fname = images_dir .. cImages_a[j]

    -- print(source_fname)
    -- make sure the file exists
    local file = io.open(source_fname)

    if not file then
      return_not_found()
    end

    file:close()

    -- start
    img = magick.load_image(source_fname)


    if ngx.var.arg_height and ngx.var.arg_crop ~= "1" then
      img:resize(tonumber(width_x[j]), tonumber(height_x[j]))
    end

    -- blur image
    if ngx.var.arg_blur then
      img:blur(4, 0)
    end

    --rotate image
    --Note: for graphicmagick, this is not available
    if rotate_a[j] then
      img:rotate(tonumber(rotate_a[j]), 0, 0, 1)
    end

    if ngx.var.arg_distort then
      local xxx = img:distortImage()
    end

    if ngx.var.arg_crop then
      img:resize_and_crop(tonumber(width_x[j]), tonumber(height_x[j]))
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
    if flop_a[j] ~= '0' and flop_a[j] ~= nil  then
      img:flop()
    end

    --flip image
    if flip_a[j] ~= '0' and flip_a[j] ~= nil then
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

    if ngx.var.arg_single_color then
      local hex = ngx.var.arg_single_color:gsub("#","")
      local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
      img:single_color("rgb("..r..","..g..","..b..")",20)
    end

    if ngx.var.arg_charcoal then
      img:charcoalImage(0,0)
    end

    if ngx.var.arg_cylinder then
       img:custom_cylinderize("vertical",250.03813405274, 100.029, 15.6667, 15.145578659481, 1.75, 0.0,90.00)
       -- local imgSrc = magick.load_image("html/mugs.jpg")
       imgSrc:resize(500,500)
       imgSrc:composite(img, -120, 150, "SrcOverCompositeOp")
       img = imgSrc
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

    if ngx.var.arg_fabric then
      local cmp_x,cmp_y = images_x[j],images_y[j]
      -- local tshirt = magick.load_image("html/product-images/54607c1317207c5f03d63af1/12323rdfcabc234/main/product-img-red.png")
      -- tshirt:resize(tonumber(compose_w),tonumber(compose_h))

      local cordinate = width_x[j] .. 'x' .. height_x[j] .. '+' .. cmp_x .. '+' .. cmp_y
      img:tshirt(imgSrc, "", cordinate, "none", "center", 0, "", 0, 20, 1, 10, 1, 2, "no")    
    end

    if ngx.var.arg_deep_etch then
      img:deep_etch()
    end

    if ngx.var.arg_leather_engrave then
      -- local product = magick.load_image("html/7832_black.jpg")
      img:leather_engrave(imgSrc)

      -- local imgSrc = magick.load_image("html/7832_black.jpg")
      imgSrc:composite(img, 120, 300, "OverCompositeOp")
      img = imgSrc
    end

    if ngx.var.arg_four_colour then
      img:four_colour()
    end

    if ngx.var.arg_dominant_color then
      local color = img:dominant_color();
      -- print(color)
    end

    if ngx.var.arg_foil then
        -- local imgSrc = magick.load_image("html/yellow.gif.jpg")
        imgSrc:composite(img, 0, 0, "AtopCompositeOp")
        img = imgSrc
    end

    if ngx.var.arg_gel_dom then
      img:gel_dom()
    end

    if ngx.var.arg_toneontoneImage then
      img:toneontoneImage();
      -- local imgSrc = magick.load_image("html/7832_black.jpg")
      local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2
      imgSrc:composite(img, x, y, "OverCompositeOp")
      img = imgSrc
    end

    
    -- left 100+150>200
    -- top 100+200>200


    -- left 100+150>200 150
    -- top 100+200>200 50

    -- local x_cord, y_cord = 0, 0

    -- x_cord = (artwork_left+artwork_width) - (images_x[j]+width_x[j])
    -- y_cord = (artwork_top+artwork_height) - (images_y[j]+height_x[j])

    x_cord_x = artwork_left - images_x[j]
    y_cord_x = artwork_top - images_y[j]

    img:crop(tonumber(artwork_width), tonumber(artwork_height), x_cord_x, y_cord_x)
    
    -- negative right side
    -- possitive left side

    if background_a[j] ~= nil and background_a[j] ~= '' then 
      for i in string.gmatch(background_a[j], '([^-]+)') do
        img:transparent_background(i)
      end
    end

    cmp_x,cmp_y = images_x[j],images_y[j]
    local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2
    if ngx.var.arg_fabric then
      imgSrc:composite(img, 0, 0, "SrcOverCompositeOp")
    else
      -- imgSrc:composite(img, tonumber(cmp_x), tonumber(cmp_y), "SrcOverCompositeOp")
      
      local composite_x, composite_y

      composite_x = x_cord_x+tonumber(cmp_x)
      composite_y = y_cord_x+tonumber(cmp_y)

      if x_cord_x<0 then 
        composite_x = tonumber(cmp_x)
      end

      if y_cord_x<0 then 
        composite_y = tonumber(cmp_y)
      end

      imgSrc:composite(img, composite_x, composite_y, "SrcOverCompositeOp")
    end
end

process_img()

imgSrc:write(dest_fname)
imgSrc:destroy()
ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)




-- if multiImage ~= nil then

--   local images, images_x, images_y, height_x, width_x, flip_a, flop_a = {}, {}, {}, {}, {}, {}, {}

--   local j = 1

--   images_x = stringToArray(compose_x)
--   images_y = stringToArray(compose_y)
--   height_x = stringToArray(height)
--   width_x = stringToArray(width)
--   flip_a = stringToArray(flip)
--   flop_a = stringToArray(flop)
--   rotate_a = stringToArray(rotate)
--   background_a = stringToArray(background)


--   -- local dest_fname = cache_dir .. calculated_sig .. "." .. ext
--   local img

--   for i in string.gmatch(cImages, '([^,]+)') do
--     local source_fname = images_dir .. i

--     -- make sure the file exists
--     local file = io.open(source_fname)

--     if not file then
--       return_not_found()
--     end

--     file:close()

--     -- start
--     img = magick.load_image(source_fname)


--     if ngx.var.arg_height and ngx.var.arg_crop ~= "1" then
--       img:resize(tonumber(width_x[j]), tonumber(height_x[j]))
--     end

--     -- blur image
--     if ngx.var.arg_blur then
--       img:blur(4, 0)
--     end

--     --rotate image
--     --Note: for graphicmagick, this is not available
--     if rotate_a[j] then
--       img:rotate(tonumber(rotate_a[j]), 0, 0, 1)
--     end

--     if ngx.var.arg_distort then
--       local xxx = img:distortImage()
--     end

--     if ngx.var.arg_crop then
--       img:resize_and_crop(tonumber(width_x[j]), tonumber(height_x[j]))
--     end

--     -- if ngx.var.arg_crop_ then

    
--     -- end

--     --image modulate
--     if ngx.var.arg_modulate then
--       img:modulate(100,100,200)
--     end

--     --set image quality
--     if ngx.var.arg_quality then
--       img:set_quality(tonumber(ngx.var.arg_quality))
--     end

--     --flop image
--     if flop_a[j] ~= '0' and flop_a[j] ~= nil  then
--       img:flop()
--     end

--     --flip image
--     if flip_a[j] ~= '0' and flip_a[j] ~= nil then
--       img:flip()
--     end

--     --negate the image
--     if ngx.var.arg_negate then
--       img:negate(true)
--     end

--     --colorize image
--     if ngx.var.arg_colorize then
--       local hex = ngx.var.arg_colorize:gsub("#","")
--       local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
--       img:imageColor(r,g,b)
--     end

--     if ngx.var.arg_emboss then
--       img:custom_emboss(2, 90.0, 90.0, 8.0, 0.0, 42, 0.0)
--     end

--     if ngx.var.arg_debose then

--     end

--     if ngx.var.arg_single_color then
--       local hex = ngx.var.arg_single_color:gsub("#","")
--       local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
--       img:single_color("rgb("..r..","..g..","..b..")",20)
--     end

--     if ngx.var.arg_charcoal then
--       img:charcoalImage(0,0)
--     end

--     if ngx.var.arg_cylinder then
--        img:custom_cylinderize("vertical",250.03813405274, 100.029, 15.6667, 15.145578659481, 1.75, 0.0,90.00)
--        -- local imgSrc = magick.load_image("html/mugs.jpg")
--        imgSrc:resize(500,500)
--        imgSrc:composite(img, -120, 150, "SrcOverCompositeOp")
--        img = imgSrc
--     end

--     if ngx.var.arg_firebranded then
--       img:coloration(0.0,50.0,0.0);
--     end

--     if ngx.var.arg_wooden then
--       local woodenImg = magick.load_image("html/wood.jpg")
--       woodenImg:wooden(img, "carve", 12, 3, "25", 0.0, 135, 2, 40, "black,white", 125.0, 100.0, 1)
--       img = woodenImg
--     end

--     if ngx.var.arg_bevel then
--       img:bevel("inner", 135.0, 30.0, 100.0, 5.0, 4.0, "smooth", "lowered", "", "black", "dark")
--     end

--     if ngx.var.arg_fabric then
--       local cmp_x,cmp_y = images_x[j],images_y[j]
--       -- local tshirt = magick.load_image("html/product-images/54607c1317207c5f03d63af1/12323rdfcabc234/main/product-img-red.png")
--       -- tshirt:resize(tonumber(compose_w),tonumber(compose_h))

--       local cordinate = width_x[j] .. 'x' .. height_x[j] .. '+' .. cmp_x .. '+' .. cmp_y
--       img:tshirt(imgSrc, "", cordinate, "none", "center", 0, "", 0, 20, 1, 10, 1, 2, "no")    
--     end

--     if ngx.var.arg_deep_etch then
--       img:deep_etch()
--     end

--     if ngx.var.arg_leather_engrave then
--       -- local product = magick.load_image("html/7832_black.jpg")
--       img:leather_engrave(imgSrc)

--       -- local imgSrc = magick.load_image("html/7832_black.jpg")
--       imgSrc:composite(img, 120, 300, "OverCompositeOp")
--       img = imgSrc
--     end

--     if ngx.var.arg_four_colour then
--       img:four_colour()
--     end

--     if ngx.var.arg_dominant_color then
--       local color = img:dominant_color();
--       -- print(color)
--     end

--     if ngx.var.arg_foil then
--         -- local imgSrc = magick.load_image("html/yellow.gif.jpg")
--         imgSrc:composite(img, 0, 0, "AtopCompositeOp")
--         img = imgSrc
--     end

--     if ngx.var.arg_gel_dom then
--       img:gel_dom();
--     end

--     if ngx.var.arg_toneontoneImage then
--       img:toneontoneImage();
--       -- local imgSrc = magick.load_image("html/7832_black.jpg")
--       local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2
--       imgSrc:composite(img, x, y, "OverCompositeOp")
--       img = imgSrc
--     end

--     local x_cord, y_cord = 0, 0
--     if (width_x[j]+images_x[j]) > tonumber(artwork_width) then
--       x_cord = width_x[j]+images_x[j] - tonumber(artwork_width)
--     end

--     if (height_x[j]+images_y[j]) > tonumber(artwork_height) then
--       y_cord = height_x[j]+images_y[j] - tonumber(artwork_height)
--     end

--     if x_cord ~= 0 or y_cord ~= 0 then 
--       img:crop(tonumber(width_x[j]), tonumber(height_x[j]), -x_cord, -y_cord)
--     end

--     if background_a[j] ~= nil and background_a[j] ~= '' then 
--       for i in string.gmatch(background_a[j], '([^-]+)') do
--         img:transparent_background(i)
--       end
--     end

--     images[j] = img
--     j = j+1
--   end


--   for i, v in ipairs(images) do
--     cmp_x,cmp_y = images_x[i],images_y[i]
--     local x, y = (imgSrc:get_width()-v:get_width())/2, (imgSrc:get_height()-v:get_height())/2
--     if ngx.var.arg_fabric then
--       imgSrc:composite(v, 0, 0, "SrcOverCompositeOp")
--     else
--       imgSrc:composite(v, tonumber(cmp_x), tonumber(cmp_y), "SrcOverCompositeOp")
--     end
--     v = imgSrc
--     vv = v
--   end
-- end

-- if multiText ~= nil then
--   -- for text
--   if texts then
    
--     local area_w_x, area_h_x, font_size_x, text_width_x, text_height_x, text_compose_x, text_compose_y, textColor = {}, {}, {}, {}, {}, {}, {}, {}
--     local textsList, text_flip_a, text_flop_a = {}, {}, {}
--     local d = 1

--     area_w_x = stringToArray(area_w)
--     area_h_x = stringToArray(area_h)
--     font_size_x = stringToArray(font_size)
--     text_width_x = stringToArray(text_width)
--     text_height_x = stringToArray(text_height)
--     text_compose_x = stringToArray(text_composex)
--     text_compose_y = stringToArray(text_composey)
--     textColor = stringToArray(text_color)
--     text_flip_a = stringToArray(text_flip)
--     text_flop_a = stringToArray(text_flop)
--     text_rotate_a = stringToArray(text_rotate)
--     text_curve_a = stringToArray(text_curve)
    


--     for i in string.gmatch(texts, '([^,]+)') do

--       img = magick.new_image(tonumber(area_w_x[d]), tonumber(area_h_x[d]))
--       text_location = '/home/software/new/virtual-ssr/static/fonts/'
--       local fontF = text_location .. font_family

--       img:textToImage(ngx.unescape_uri(i), fontF, tonumber(font_size_x[d]), "#"..textColor[d], 1, {tonumber(text_curve_a[d])});
      
--       if ngx.var.arg_height and ngx.var.arg_crop ~= "1" then
--         img:resize(tonumber(text_width_x[d]), tonumber(text_height_x[d]))
--       end

--       -- blur image
--       if ngx.var.arg_blur then
--         img:blur(4, 0)
--       end

--       --rotate image
--       --Note: for graphicmagick, this is not available
--       if text_rotate_a[d] then
--         img:rotate(tonumber(text_rotate_a[d]), 0, 0, 1)
--       end

--       if ngx.var.arg_distort then
--         local xxx = img:distortImage()
--       end

--       if ngx.var.arg_crop then
--         img:resize_and_crop(tonumber(text_width_x[d]), tonumber(text_height_x[d]))
--       end

--       --image modulate
--       if ngx.var.arg_modulate then
--         img:modulate(100,100,200)
--       end

--       --set image quality
--       if ngx.var.arg_quality then
--         img:set_quality(tonumber(ngx.var.arg_quality))
--       end

--       --flop image

--       if text_flop_a[d] ~= '0' and text_flop_a[d] ~= nil then
--         img:flop()
--       end

--       --flip image
--       if text_flip_a[d] ~= '0' and text_flip_a[d] ~= nil then
--         img:flip()
--       end

--       --negate the image
--       if ngx.var.arg_negate then
--         img:negate(true)
--       end

--       --colorize image
--       if ngx.var.arg_colorize then
--         local hex = ngx.var.arg_colorize:gsub("#","")
--         local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
--         img:imageColor(r,g,b)
--       end

--       if ngx.var.arg_emboss then
--         img:custom_emboss(2, 90.0, 90.0, 8.0, 0.0, 42, 0.0)
--       end

--       if ngx.var.arg_debose then

--       end

--       -- if ngx.var.arg_single_color then
--       --   local hex = ngx.var.arg_single_color:gsub("#","")
--       --   local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
--       --   img:single_color("rgb("..r..","..g..","..b..")",20)
--       -- end

--       if ngx.var.arg_charcoal then
--         img:charcoalImage(0,0)
--       end

--       if ngx.var.arg_cylinder then
--          img:custom_cylinderize("vertical",250.03813405274, 100.029, 15.6667, 15.145578659481, 1.75, 0.0,90.00)
--          -- local imgSrc = magick.load_image("html/mugs.jpg")
--          imgSrc:resize(500,500)
--          imgSrc:composite(img, -120, 150, "SrcOverCompositeOp")
--          img = imgSrc
--       end

--       if ngx.var.arg_firebranded then
--         img:coloration(0.0,50.0,0.0);
--       end

--       if ngx.var.arg_wooden then
--         local woodenImg = magick.load_image("html/wood.jpg")
--         woodenImg:wooden(img, "carve", 12, 3, "25", 0.0, 135, 2, 40, "black,white", 125.0, 100.0, 1)
--         img = woodenImg
--       end

--       if ngx.var.arg_bevel then
--         img:bevel("inner", 135.0, 30.0, 100.0, 5.0, 4.0, "smooth", "lowered", "", "black", "dark")
--       end

--       if ngx.var.arg_fabric then
--         local cmp_x,cmp_y = text_compose_x[d],text_compose_y[d]
--         local tshirt  = magick.load_image("html/product-img-1.png")
--         tshirt:resize(tonumber(compose_w),tonumber(compose_h))
--         local cordinate = text_width_x[d] .. 'x' .. text_height_x[d] .. '+' .. cmp_x .. '+' .. cmp_y
--         img:tshirt(tshirt, "", cordinate, "none", "center", 0, "", 0, 20, 1, 10, 1, 2, "no")
--       end

--       if ngx.var.arg_deep_etch then
--         img:deep_etch()
--       end

--       if ngx.var.arg_leather_engrave then
--         -- local product = magick.load_image("html/7832_black.jpg")
--         img:leather_engrave(imgSrc)

--         -- local imgSrc = magick.load_image("html/7832_black.jpg")
--         imgSrc:composite(img, 120, 300, "OverCompositeOp")
--         img = imgSrc
--       end

--       if ngx.var.arg_four_colour then
--         img:four_colour()
--       end

--       if ngx.var.arg_dominant_color then
--         local color = img:dominant_color();
--         -- print(color)
--       end

--       if ngx.var.arg_foil then
--           -- local imgSrc = magick.load_image("html/yellow.gif.jpg")
--           imgSrc:composite(img, 0, 0, "AtopCompositeOp")
--           img = imgSrc
--       end

--       if ngx.var.arg_gel_dom then
--         img:gel_dom();
--       end

--       if ngx.var.arg_toneontoneImage then
--         img:toneontoneImage();
--         -- local imgSrc = magick.load_image("html/7832_black.jpg")
--         local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2
--         imgSrc:composite(img, x, y, "OverCompositeOp")
--         img = imgSrc
--       end

--       local x_cord, y_cord = 0, 0
--       if (text_width_x[d]+text_compose_x[d]) > tonumber(artwork_width) then
--         x_cord = text_width_x[d]+text_compose_x[d] - tonumber(artwork_width)
--       end

--       if (text_height_x[d]+text_compose_y[d]) > tonumber(artwork_height) then
--         y_cord = text_height_x[d]+text_compose_y[d] - tonumber(artwork_height)
--       end

--       if x_cord ~= 0 or y_cord ~= 0 then 
--         img:crop(tonumber(text_width_x[d]), tonumber(text_height_x[d]), -x_cord, -y_cord)
--       end
      
--       textsList[d] = img
--       d = d+1
--     end

--     for i, v in ipairs(textsList) do
--       cmp_x,cmp_y = text_compose_x[i],text_compose_y[i]
--       local x, y = (imgSrc:get_width()-v:get_width())/2, (imgSrc:get_height()-v:get_height())/2
--       if ngx.var.arg_fabric then
--         imgSrc:composite(v, 0, 0, "SrcOverCompositeOp")
--       else
--         imgSrc:composite(v, tonumber(cmp_x), tonumber(cmp_y), "SrcOverCompositeOp")
--       end
--       v = imgSrc
--       vvText = v
--     end
--   end
-- end


-- if vvText ~= nil then
--   vvText:write(dest_fname)
--   vvText:destroy()
-- else
--   vv:write(dest_fname)
--   vv:destroy()
-- end
-- ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)