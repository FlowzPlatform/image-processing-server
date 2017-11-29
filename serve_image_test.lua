
local sig, size, path, ext, height, width, emboss, cylinder, deboss, crop, fire, compose, rotate,
flip, flop, negate, wooden, single_color, bevel, fabric, deep_etch,
engrave, four_colour, dcolor, foil, geldom, toneontone = ngx.var.arg_sig, ngx.var.arg_size, ngx.var.path, ngx.var.ext,
(ngx.var.arg_height and ngx.var.arg_height or ""), (ngx.var.arg_width and ngx.var.arg_width or ""),
(ngx.var.arg_emboss and ngx.var.arg_emboss .. "emboss" or ""), (ngx.var.arg_cylinder and ngx.var.arg_cylinder .. "cylinder" or ""),
(ngx.var.arg_deboss and ngx.var.arg_deboss .. "deboss" or ""),
(ngx.var.arg_crop and ngx.var.arg_crop .. "crop" or ""), (ngx.var.arg_firebranded and ngx.var.arg_firebranded .. "firebranded" or ""),
(ngx.var.arg_compose and ngx.var.arg_compose .. "compose" or ""), (ngx.var.arg_rotate and ngx.var.arg_rotate .. "rotate" or ""),
(ngx.var.arg_flip and ngx.var.arg_flip .. "flip" or ""), (ngx.var.arg_flop and ngx.var.arg_flop .. "flop" or ""),
(ngx.var.arg_negate and ngx.var.arg_negate .. "negate" or ""), (ngx.var.arg_wooden and ngx.var.arg_wooden .. "wooden" or ""),
(ngx.var.arg_single_color and ngx.var.arg_single_color .. "single_color" or ""), (ngx.var.arg_bevel and ngx.var.arg_bevel .. "bevel" or ""),
(ngx.var.arg_fabric and ngx.var.arg_fabric .. "fabric" or ""), (ngx.var.arg_deep_etch and ngx.var.arg_deep_etch .. "deep_etch" or ""),
(ngx.var.arg_leather_engrave and ngx.var.arg_leather_engrave .. "engrave" or ""), (ngx.var.arg_four_colour and ngx.var.arg_four_colour .. "four_colour" or ""),
(ngx.var.arg_dominant_color and ngx.var.arg_dominant_color .. "dominant_color" or ""), (ngx.var.arg_foil and ngx.var.arg_foil .. "foil" or ""),
(ngx.var.arg_gel_dom and ngx.var.arg_gel_dom .. "gel_dom" or ""), (ngx.var.arg_toneontoneImage and ngx.var.arg_toneontoneImage .. "toneontoneImage" or "")

local compose_x, compose_y = (ngx.var.arg_compose_x and ngx.var.arg_compose_x or "") , (ngx.var.arg_compose_y and ngx.var.arg_compose_y or "")
local compose_w, compose_h = (ngx.var.arg_compose_w and ngx.var.arg_compose_w or 410) , (ngx.var.arg_compose_h and ngx.var.arg_compose_h or 500)
local cImages = (ngx.var.arg_images and ngx.var.arg_images or "")

local text, font_size = (ngx.var.arg_text and ngx.var.arg_text .. "text" or ""), (ngx.var.arg_font_size and ngx.var.arg_font_size or "")

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
.. engrave .. four_colour .. dcolor .. foil .. geldom .. toneontone .. compose_x .. compose_y .. text .. font_size)

if(calculate_signature("obVMC@123") ~= sig) then
  return_not_found("Invalid signature")
end

-- make sure destination already exists
local output_file = cache_dir .. calculated_sig .. "." .. ext
local ofile = io.open(output_file)
if ofile then
  ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)
end

local texts = ngx.var.arg_texts

-- for loop here
local magick = require "magick"

-- local example = "0e97c2c2f0abe742e28d06df5e18618fc9df2521-user-uploaded-image.png,3fe35aee5acc6c0afa7f5ac49900a87fc9254126-user-uploaded-image.png"
-- local example_x = "109,75,50"
-- local example_y = "209,100,150"
local multiText = nil
local multiImage = nil
local vv = nil
local vvText = nil

if texts and string.match(texts, ",") then
  multiText = 1
end

if cImages then
  multiImage = 1
end

local dest_fname = cache_dir .. calculated_sig .. "." .. ext




if multiImage ~= nil then

  cImages = path..','..cImages

  local images, images_x, images_y, height_x, width_x = {}, {}, {}, {}, {}

  local j,k,l,m,n = 1,1,1,1,1

  for i in string.gmatch(compose_x, '([^,]+)') do
    images_x[k] = i
    k = k+1
  end

  for i in string.gmatch(compose_y, '([^,]+)') do
    images_y[l] = i
    l =l+1
  end

  for i in string.gmatch(height, '([^,]+)') do
    height_x[m] = i
    m =m+1
  end

  for i in string.gmatch(width, '([^,]+)') do
    width_x[n] = i
    n =n+1
  end

  -- local dest_fname = cache_dir .. calculated_sig .. "." .. ext
  local img

  for i in string.gmatch(cImages, '([^,]+)') do
    local source_fname = images_dir .. i

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
    if ngx.var.arg_rotate then
      img:rotate(tonumber(ngx.var.arg_rotate), 0, 0, 1)
    end

    if ngx.var.arg_distort then
      local xxx = img:distortImage()
    end

    if ngx.var.arg_crop then
      img:resize_and_crop(tonumber(width_x[j]), tonumber(height_x[j]))
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
       local imgSrc = magick.load_image("html/mugs.jpg")
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
      local tshirt  = magick.load_image("html/product-img-1.png")
      tshirt:resize(tonumber(compose_w),tonumber(compose_h))
      local cordinate = width_x[j] .. 'x' .. height_x[j] .. '+' .. cmp_x .. '+' .. cmp_y
      img:tshirt(tshirt, "", cordinate, "none", "center", 0, "", 0, 20, 1, 10, 1, 2, "no")
    end

    if ngx.var.arg_deep_etch then
      img:deep_etch()
    end

    if ngx.var.arg_leather_engrave then
      local product = magick.load_image("html/7832_black.jpg")
      img:leather_engrave(product)

      local imgSrc = magick.load_image("html/7832_black.jpg")
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
        local imgSrc = magick.load_image("html/yellow.gif.jpg")
        imgSrc:composite(img, 0, 0, "AtopCompositeOp")
        img = imgSrc
    end

    if ngx.var.arg_gel_dom then
      img:gel_dom();
    end

    if ngx.var.arg_toneontoneImage then
      img:toneontoneImage();
      local imgSrc = magick.load_image("html/7832_black.jpg")
      local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2
      imgSrc:composite(img, x, y, "OverCompositeOp")
      img = imgSrc
    end
    
    images[j] = img
    j = j+1
  end

  
  local imgSrc = magick.load_image("html/product-img-1.png")
  imgSrc:resize(tonumber(compose_w),tonumber(compose_h))

  for i, v in ipairs(images) do
    cmp_x,cmp_y = images_x[i],images_y[i]
    local x, y = (imgSrc:get_width()-v:get_width())/2, (imgSrc:get_height()-v:get_height())/2
    if ngx.var.arg_fabric then
      imgSrc:composite(v, 0, 0, "SrcOverCompositeOp")
    else
      imgSrc:composite(v, tonumber(cmp_x), tonumber(cmp_y), "SrcOverCompositeOp")
    end
    v = imgSrc
    vv = v
  end
  print(multiText)
  -- vv:write(dest_fname)
  -- vv:destroy()
  -- ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)

  -- if vvText ~= nil then
  --   vvText:write(dest_fname)
  --   vvText:destroy()
  -- else
  --   vv:write(dest_fname)
  --   vv:destroy()
  -- end
  -- ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)

elseif multiText ~= nil then
  -- for text
  if texts then
    local area_w, area_h = ngx.var.arg_area_w, ngx.var.arg_area_h
    local font_size,text_height,text_width,text_composex,text_composey = ngx.var.arg_area_w, ngx.var.arg_area_h, ngx.var.arg_text_width, ngx.var.arg_text_height, ngx.var.arg_text_composex, ngx.var.arg_text_composey

    local area_w_x, area_h_x, font_size_x, text_width_x, text_height_x, text_compose_x, text_compose_y= {}, {}, {}, {}, {}, {}, {}
    local textsList = {}
    local a,b,c,d,e,f,g,h = 1,1,1,1,1,1,1,1
    
    for i in string.gmatch(area_w, '([^,]+)') do
      area_w_x[a] = i
      a =a+1
    end
    
    for i in string.gmatch(area_h, '([^,]+)') do
      area_h_x[b] = i
      b =b+1
    end
    
    for i in string.gmatch(font_size, '([^,]+)') do
      font_size_x[c] = i
      c =c+1
    end

    for i in string.gmatch(text_width, '([^,]+)') do
      text_width_x[e] = i
      e = e+1
    end

    for i in string.gmatch(text_height, '([^,]+)') do
      text_height_x[f] = i
      f =f+1
    end

    for i in string.gmatch(text_composex, '([^,]+)') do
      text_compose_x[g] = i
      g =g+1
    end

    for i in string.gmatch(text_composey, '([^,]+)') do
      text_compose_y[h] = i
      h =h+1
    end

    for i in string.gmatch(texts, '([^,]+)') do

      img = magick.new_image(tonumber(area_w_x[d]), tonumber(area_h_x[d]))

      img:textToImage(ngx.unescape_uri(i),"Noto-Sans-Mono-CJK-SC-Bold", tonumber(font_size_x[d]));
      
      if ngx.var.arg_height and ngx.var.arg_crop ~= "1" then
        img:resize(tonumber(text_width_x[d]), tonumber(text_height_x[d]))
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
         local imgSrc = magick.load_image("html/mugs.jpg")
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
        local product = magick.load_image("html/7832_black.jpg")
        img:leather_engrave(product)

        local imgSrc = magick.load_image("html/7832_black.jpg")
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
          local imgSrc = magick.load_image("html/yellow.gif.jpg")
          imgSrc:composite(img, 0, 0, "AtopCompositeOp")
          img = imgSrc
      end

      if ngx.var.arg_gel_dom then
        img:gel_dom();
      end

      if ngx.var.arg_toneontoneImage then
        img:toneontoneImage();
        local imgSrc = magick.load_image("html/7832_black.jpg")
        local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2
        imgSrc:composite(img, x, y, "OverCompositeOp")
        img = imgSrc
      end
      
      textsList[d] = img
      d = d+1
    end

    for i, v in ipairs(textsList) do
      cmp_x,cmp_y = text_compose_x[i],text_compose_y[i]
      local x, y = (imgSrc:get_width()-v:get_width())/2, (imgSrc:get_height()-v:get_height())/2
      if ngx.var.arg_fabric then
        imgSrc:composite(v, 0, 0, "SrcOverCompositeOp")
      else
        imgSrc:composite(v, tonumber(cmp_x), tonumber(cmp_y), "SrcOverCompositeOp")
      end
      v = imgSrc
      vvText = v
    end

    -- vvText:write(dest_fname)
    -- vvText:destroy()
    -- ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)

  end
  -- end text

else

  if ngx.var.arg_text then
    local area_w, area_h = ngx.var.arg_area_w, ngx.var.arg_area_h
    img = magick.new_image(tonumber(area_w), tonumber(area_h))
  else

    local source_fname = images_dir .. path
    local file = io.open(source_fname)

    if not file then
      return_not_found()
    end

    file:close()
    img = magick.load_image(source_fname)
  end

  if ngx.var.arg_text then
    img:textToImage(ngx.unescape_uri(ngx.var.arg_text),"Noto-Sans-Mono-CJK-SC-Bold", tonumber(ngx.var.arg_font_size));
  end

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
     local imgSrc = magick.load_image("html/mugs.jpg")
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


  if ngx.var.arg_deep_etch then
    img:deep_etch()
  end

  if ngx.var.arg_leather_engrave then
    local product = magick.load_image("html/7832_black.jpg")
    img:leather_engrave(product)

    local imgSrc = magick.load_image("html/7832_black.jpg")
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
      local imgSrc = magick.load_image("html/yellow.gif.jpg")
      imgSrc:composite(img, 0, 0, "AtopCompositeOp")
      img = imgSrc
  end

  if ngx.var.arg_gel_dom then
    img:gel_dom();
  end

  if ngx.var.arg_toneontoneImage then
    img:toneontoneImage();
    local imgSrc = magick.load_image("html/7832_black.jpg")
    local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2
    imgSrc:composite(img, x, y, "OverCompositeOp")
    img = imgSrc
  end

  
  if ngx.var.arg_fabric then
    tshirtImage = magick.load_image("html/product-img-1.png")
    tshirtImage:resize(tonumber(compose_w),tonumber(compose_h))
    local cordinate = width .. 'x' .. height .. '+' .. compose_x .. '+' .. compose_y
    img:tshirt(tshirtImage, "", cordinate, "none", "center", 0, "", 0, 20, 1, 10, 1, 2, "no")
  end

  if ngx.var.arg_compose then
    local imgSrc = magick.load_image("html/product-img-1.png")
    imgSrc:resize(tonumber(compose_w),tonumber(compose_h))
    if ngx.var.arg_fabric then
      tshirtImage:composite(img, 0, 0, "SrcOverCompositeOp")
      img = tshirtImage
    else
      imgSrc:composite(img, tonumber(compose_x), tonumber(compose_y), "SrcOverCompositeOp")
      img = imgSrc
    end
  end

end


-- if vvText ~= nil then
--     
--   else
--     vv:write(dest_fname)
--     vv:destroy()
--   end
--   ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)

if vvText ~= nil then
  vvText:write(dest_fname)
  vvText:destroy()
elseif vv ~= nil then
  vv:write(dest_fname)
  vv:destroy()
else
  img:write(dest_fname)
  img:destroy()
end
-- vv:write(dest_fname)
-- vv:destroy()
ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)