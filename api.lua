local magick = require "magick"
img = magick.load_image("html/Bill_Murray_small.jpg")
-- img:size(100x100)
-- img:resize(170, 97)
-- img:custom_emboss(2, 90.0, 90.0, 8.0, 0.0, 42, 0.0)
-- local place = magick.load_image("html/shirt-1490420206-a15bc00a09077730c2a8dd98907d1b10.jpg")
-- img:tshirt(place, "", "250x250+350+200", "none", "center", 0, "", 0, 20, 1, 10, 1, 2, "no")

-- img:custom_cylinderize("vertical",250.03813405274, 100.029, 15.6667, 15.145578659481, 1.75, 0.0,90.00)

-- local woodenImg = magick.load_image("html/wood.jpg")
-- woodenImg:wooden(img, "carve", 12, 3, "25", 0.0, 135, 2, 40, "black,white", 125.0, 100.0, 1)
-- img = woodenImg

-- img:bevel("inner", 135.0, 30.0, 100.0, 5.0, 4.0, "smooth", "lowered", "", "black", "dark")

-- local color = img:dominant_color();
-- ngx.say(color)

-- img:crop(100, 100, 0, 0);

-- local hex = ngx.var.arg_single_color:gsub("#","")
-- local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
-- img:single_color("rgb(244,66,170)",20)

-- img:flop()

-- img:flip()

-- img:negate(true)

-- local product = magick.load_image("html/7832_black.jpg")
-- img:leather_engrave(product)
-- img:resize(170, 97)

-- local imgSrc = magick.load_image("html/7832_black.jpg")
-- product:composite(img, 120, 300, "OverCompositeOp")
-- img = product


-- glass


-- img:single_color("rgb(229,229,229)",20)
-- img:custom_emboss(1, 135.0, 40.0, 10.0, 0.0, 42, 0.0)
-- 'convert '. $newimage .' -alpha set -evaluate set 90% '.$newimage

img:toneontoneImage();

-- img:gel_dom();
-- print(img:get_height())
-- print(img:get_width())

-- img:blur(4, 0)

-- img:four_colour()
-- img:gel_dom()

-- img:set_quality(50)

-- local imgSrc = magick.load_image("html/yellow.gif.jpg")
-- img:composite(imgSrc, 0, 0, "AtopCompositeOp")

img:write("html/resize.jpg")
img:destroy()
ngx.exec("/resize.jpg")
