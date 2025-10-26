
overlay = canvas:newLayer(canvas:width(), canvas:height())
painter = image.newPainter(overlay.image)
painter:setFill(true)
painter:setFillColor(0)

function fart()
	-- aaaaaaeugh
	painter:drawText("Hello World", 1, 1)
	overlay:update()
end


callbacks:add("frame", fart)