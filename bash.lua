-- if ngx.var.arg_resize then
--   local handle = io.popen("convert html/input.jpg -resize 170x97 html/output.jpg")
--   local result = handle:read("*a")
--   handle:close()
-- end
--
-- if ngx.var.arg_cylinder then
--   local handle = io.popen("./cylinderize.sh -m vertical -r 366.34955984688 -l 188.179 -w 16.6667 -p 23.428692808745 -n 96.097053534591 -e 1.75 -a 0 -v background -b none -f none -o -86-80.8315 html/input.jpg html/output.jpg")
--   local result = handle:read("*a")
--   handle:close()
-- end
--
-- if ngx.var.arg_emboss then
--   local handle = io.popen("./bash/emboss.sh -m 2 -a 90 -e 90 -i 0 -d 8 -c linear_dodge html/lena.jpg html/output.jpg")
--   local result = handle:read("*a")
--   handle:close()
-- end

local handle = io.popen("convert html/input.jpg -resize 170x97 html/output.jpg")
local result = handle:read("*a")
handle:close()
-- ngx.exec("/output.jpg")
