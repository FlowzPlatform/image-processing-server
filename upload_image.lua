-- local ltn12 = require "ltn12"
-- local mime = require "mime"

ngx.req.read_body()
local args, err = ngx.req.get_post_args()

local file = ngx.req.get_body_file()
if file then
 ngx.say("body is in file ", file)
 local fh = assert(io.open(file, "rb"))
  local len = assert(fh:seek("end"))
  fh:close()
  ngx.say(len)

 -- length_of_file(file)
else
 ngx.say("no body found")
end

-- function length_of_file(filename)
--   local fh = assert(io.open(filename, "rb"))
--   local len = assert(fh:seek("end"))
--   fh:close()
--   return len
-- end

if not args then
    ngx.say("failed to get post args: ", err)
    return
end
local mystring
for key, val in pairs(args) do
    if type(val) == "table" then
        ngx.say(key, ": ", table.concat(val, ", "))
    else
        -- ngx.say(key, ": ", val)
        mystring = val
    end
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end
-- local mystring = "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"
local test = dec(mystring)

ngx.say(test)