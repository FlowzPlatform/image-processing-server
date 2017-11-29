-- local upload = require "resty.upload"

-- local chunk_size = 4096
-- local form,err = upload:new(chunk_size)
-- -- ngx.say("form------",err)
-- -- ngx.say("boundary :",form.boundary)

-- local file
-- local filelen=0
-- form:set_timeout(1000) -- 1 sec
-- local filename

-- function getFilename(res)
--     local filename = ngx.re.match(res,'(.+)filename="(.+)"(.*)')
--     if filename then
--         return filename[2]
--     end
-- end

-- -- local osfilepath = "C:\\lua\\openresty-1.9.7.5-win32\\html\\"
-- local osfilepath = "/home/software/Desktop/"
-- local i=0

-- while true do
--     local typ, res, err = form:read()
--     if not typ then
--         ngx.say("failed to read: ", err)
--         return
--     end
--     if typ == "header" then
--         if res[1] ~= "Content-Type" then
--             filename = getFilename(res[2])
--             if filename then
--                 i=i+1
--                 filepath = osfilepath  .. filename
--                 file = io.open(filepath,"w+")
--                 if not file then
--                     ngx.say("failed to open file ")
--                     return
--                 end
--             else
--             end
--         end
--     elseif typ == "body" then
--         if file then
--             filelen= filelen + tonumber(string.len(res))
--             file:write(res)
--         else
--         end
--     elseif typ == "part_end" then
--         if file then
--             file:close()
--             file = nil
--             ngx.say("file upload success")
--         end
--     elseif typ == "eof" then
--         break
--     else
--     end
-- end
-- if i==0 then
--     ngx.say("please upload at least one file!")
--     return
-- end

-- lua_package_path "/usr/local/openresty/lualib/resty/?.lua"

-- local post = require "resty.post":new()
--  local method = ngx.var.request_method

--  if method == "OPTIONS" then
--    local header = ngx.header
--    header['Access-Control-Allow-Origin'] = '*'
--    header['Access-Control-Allow-Methods'] = 'GET,POST,PUT,DELETE,HEAD,OPTIONS'
--  elseif method == "POST" then
--    local m = post:read()
--    -- process your files
--  end





local resty_post = require 'resty.post'
local cjson = require 'cjson'

-- local post = resty_post:new()

local post = resty_post:new({
 path = "/home/software/openresty-lua/upload/",           -- path upload file will be saved
 chunk_size = 10240,          -- default 8192
 no_tmp = true,               -- if set original name will uses or generate random name
 name = function(name, field) -- overide name with user defined function
  return name.."_"..field 
 end
})

local m = post:read()

-- local mystring
-- for key, val in pairs(m) do
--     -- print(key)
--     -- print(val)
    
--     if type(val) == "table" then
--         ngx.say(key, ": ", table.concat(val, ", "))
--     else
--         ngx.say(key, ": ", val)
--         mystring = val
--     end
-- end

-- ngx.say(mystring)
ngx.say(cjson.encode(m))
