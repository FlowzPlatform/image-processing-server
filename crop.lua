local magick = require "magick"
local cjson = require "cjson"

ngx.header["Content-Type"] = 'application/json; charset=utf-8'
ngx.header["Access-Control-Allow-Origin"] = ngx.var.http_origin
ngx.header["Access-Control-Allow-Credentials"] = "true"

local img
img = magick.load_image("html/user-uploaded-images/" .. ngx.var.arg_image)

img:crop(tonumber(ngx.var.arg_w), tonumber(ngx.var.arg_h), tonumber(ngx.var.arg_x), tonumber(ngx.var.arg_y))

img:write("html/user-uploaded-images/" .. ngx.var.arg_image)
img:destroy()

ngx.say(cjson.encode({ message = 'Cropped successfully' }))
