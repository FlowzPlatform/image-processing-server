
local magick = require "magick"
local cjson = require "cjson"

-- ngx.header.content_type = 'application/json'

local img
img = magick.load_image("html/user-uploaded-images/" .. ngx.var.arg_image)

img:crop(tonumber(ngx.var.arg_w), tonumber(ngx.var.arg_h), tonumber(ngx.var.arg_x), tonumber(ngx.var.arg_y))

img:write("html/user-uploaded-images/" .. ngx.var.arg_image)
img:destroy()

local value = {}
value['message'] = 'Cropped successfully'
local response = cjson.encode(value)

ngx.say(response)
-- ngx.exec("/user-uploaded-images/" .. ngx.var.arg_image)
