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

local images, cylinder, height, width, fabric, compose_x, compose_y, 
area_left, area_top, area_w, area_h, cropped, orders, background, 
four_colour, engrave, sig = 
(ngx.var.arg_images and ngx.var.arg_images or ""), (ngx.var.arg_cylinder and ngx.var.arg_cylinder or ""),
(ngx.var.arg_height and ngx.var.arg_height or ""), (ngx.var.arg_width and ngx.var.arg_width or ""),
(ngx.var.arg_fabric and ngx.var.arg_fabric or ""), (ngx.var.arg_c_x and ngx.var.arg_c_x or ""),
(ngx.var.arg_c_y and ngx.var.arg_c_y or ""), (ngx.var.arg_a_l and ngx.var.arg_a_l or ""),
(ngx.var.arg_a_t and ngx.var.arg_a_t or ""), (ngx.var.arg_a_w and ngx.var.arg_a_w or ""),
(ngx.var.arg_a_h and ngx.var.arg_a_h or ""), (ngx.var.arg_cropped and ngx.var.arg_cropped or ""),
(ngx.var.arg_orders and ngx.var.arg_orders or ""), (ngx.var.arg_back and ngx.var.arg_back or ""),
(ngx.var.arg_f_color and ngx.var.arg_f_color or ""), (ngx.var.arg_engrave and ngx.var.arg_engrave or ""),
(ngx.var.arg_sig and ngx.var.arg_sig or "")

local product_w, product_h = (ngx.var.arg_p_w and ngx.var.arg_p_w or 410) , (ngx.var.arg_p_h and ngx.var.arg_p_h or 500)


local ext, path = ngx.var.ext, ngx.var.path

local calculated_sig = calculate_signature(path .. height .. width .. cylinder .. fabric
.. engrave .. four_colour .. compose_x .. compose_y .. area_w .. area_h      
.. background .. orders .. cropped .. area_left .. area_top)

if(calculate_signature("obVMC@123") ~= sig) then
  return_not_found("Invalid signature")
end

-- make sure destination already exists
local output_file = cache_dir .. calculated_sig .. "." .. ext
local ofile = io.open(output_file)
if ofile then
--   ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)
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
    -- print(orders)
    orders_x = stringToArray(orders)
    for i, v in ipairs(orders_x) do      
        local order = explode("-", v)
        image(tonumber(order[2]))
    end
end

local images_x, images_y, height_x, width_x, images_a  = {}, {}, {}, {}, {}
images_x = stringToArray(compose_x)
images_y = stringToArray(compose_y)
height_x = stringToArray(height)
width_x = stringToArray(width)
images_a = stringToArray(images)

local dest_fname = cache_dir .. calculated_sig .. "." .. ext

local imgSrc = magick.load_image("html/product-images/" .. path)
imgSrc:resize(tonumber(product_w),tonumber(product_h))

local img
function image(j)
    img = magick.load_image("cache/" .. images_a[j])
    local height, width = img:get_height(), img:get_width()

    -- print(area_left .. '===' .. images_x[j])
    -- print(area_top .. '===' .. images_y[j])

    x_cord_x = tonumber(area_left) - tonumber(images_x[j])
    y_cord_x = tonumber(area_top) - tonumber(images_y[j])

    print(images_a[j])
    print(x_cord_x .. '===' .. y_cord_x)
    print(area_w .."===".. area_h)


    img:crop(tonumber(area_w), tonumber(area_h), x_cord_x, y_cord_x)
    
    if ngx.var.arg_fabric then
        local cmp_x,cmp_y = images_x[j],images_y[j]

        local cordinate = width .. 'x' .. height .. '+' .. cmp_x .. '+' .. cmp_y
        img:tshirt(imgSrc, "", cordinate, "none", "center", 0, "", 0, 20, 1, 10, 1, 2, "no")    
    end

    if ngx.var.arg_leather and ngx.var.arg_leather ~= '' then
        img:leather_engrave(imgSrc)
        -- imgSrc:composite(img, 120, 300, "OverCompositeOp")
        -- img = imgSrc
    end

    if background ~= nil and background ~= '' then 
        img:transparent_background(background)
    end

    cmp_x,cmp_y = images_x[j],images_y[j]
    local x, y = (imgSrc:get_width()-img:get_width())/2, (imgSrc:get_height()-img:get_height())/2

    if ngx.var.arg_fabric  and ngx.var.arg_fabric ~= '' then
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
        -- imgSrc:composite(img, 0, 0, "SrcOverCompositeOp")
    end

    if background_a ~= nil and background_a ~= '' then
        for i in string.gmatch(background_a, '([^-]+)') do
            img:transparent_background(i)
        end
    end
end


process_img()

imgSrc:write(dest_fname)
imgSrc:destroy()
ngx.exec(ngx.var.request_uri .. '&image=' .. calculated_sig)