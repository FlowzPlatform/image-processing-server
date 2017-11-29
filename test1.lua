
-- local name = ngx.req.get_uri_args().name or ""
-- name = htmlescape(name)
-- print(name)
-- ngx.header.content_type = "text/html"
-- ngx.say(name)

-- local name = ngx.req.get_uri_args().name or ""
--    ngx.header.content_type = "text/html"
--    local html = string.format([[
--     ngx.say("Hello, %s")
--     ngx.say("Today is "..os.date())
--    ]], name)
--    loadstring(html)()
--

-- local ffi = require("ffi")
-- ffi.cdef([[
--   int * getRandom();
-- ]])
-- local lib = ffi.load('/home/software/openresty/image-server-tutorial-master/libhello.so')
-- print("logging")
-- local x = lib.getRandom()
--
-- print(ffi.sizeof(x))
-- for i=1, ffi.sizeof(x) do
--       print(x[i])
-- end

-- local str_array_C = C.ffi.tArr(x)
-- print(str_array_C)
ngx.say("Success!!!!!")
