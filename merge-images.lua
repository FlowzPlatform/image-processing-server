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

local images, cylinder, height, width, fabric, compose_x, compose_y, area_left, area_top, area_w, area_h = 
(ngx.var.arg_images and ngx.var.arg_images or ""), (ngx.var.arg_cylinder and ngx.var.arg_cylinder or ""),
(ngx.var.arg_height and ngx.var.arg_height or ""), (ngx.var.arg_width and ngx.var.arg_width or ""),
(ngx.var.arg_fabric and ngx.var.arg_fabric or ""), (ngx.var.arg_compose_x and ngx.var.arg_compose_x or ""),
(ngx.var.arg_compose_y and ngx.var.arg_compose_y or ""), (ngx.var.arg_area_left and ngx.var.arg_area_left or ""),
(ngx.var.arg_area_top and ngx.var.arg_area_top or ""), (ngx.var.arg_area_w and ngx.var.arg_area_w or ""),
(ngx.var.arg_area_h and ngx.var.arg_area_h or "")

local calculated_sig = calculate_signature(path .. height .. width .. cylinder .. compose .. bevel .. fabric
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

local magick = require "magick"

function stringToArray (str)
    local j = 1
    local arr = {}

    for i in string.gmatch(str, '([^,]+)') do
        arr[j] = i
        j = j+1
    end
    return arr
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

function process_img()
    orders_x = stringToArray(orders)
    for i, v in ipairs(orders_x) do      
        local tt = explode("-", v)
        image(tonumber(tt[2]), imgSrc)
    end
end

function image()
    if ngx.var.arg_fabric then
        local cmp_x,cmp_y = images_x[j],images_y[j]  
        local cordinate = width_x[j] .. 'x' .. height_x[j] .. '+' .. cmp_x .. '+' .. cmp_y
        img:tshirt(imgSrc, "", cordinate, "none", "center", 0, "", 0, 20, 1, 10, 1, 2, "no")    
    end

    if ngx.var.arg_leather_engrave then
        img:leather_engrave(imgSrc)
        imgSrc:composite(img, 120, 300, "OverCompositeOp")
        img = imgSrc
    end

    x_cord_x = artwork_left - images_x[j]
    y_cord_x = artwork_top - images_y[j]

    -- print(x_cord_x .. y_cord_x)
    -- print(artwork_width .. artwork_height)


    img:crop(tonumber(artwork_width), tonumber(artwork_height), x_cord_x, y_cord_x)
    
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

    if background_a ~= nil and background_a ~= '' then
        for i in string.gmatch(background_a, '([^-]+)') do
            img:transparent_background(i)
        end
    end

end


local dest_fname = cache_dir .. calculated_sig .. "." .. ext
local imgSrc = magick.load_image("html/product-images/" .. path)
imgSrc:resize(tonumber(compose_w),tonumber(compose_h))