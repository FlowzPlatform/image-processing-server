local resty_post = require "resty.post"
local post = resty_post:new({
  path = "/home/software/openresty-lua/html/user-uploaded-images/", -- path upload file will be saved
  name = function(name, field) -- overide name with user defined function
    return name.."_"..field 
  end
})
local m = post:read()