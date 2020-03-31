--[[
ButtonTextPUDD
A Button class with text, Pixel, images: Up, Down, Disabled
This code is MIT licensed, see http://www.opensource.org/licenses/mit-license.php
github: mokalux
v 0.1.0: 2020-03-28 init (based on the initial gideros generic button class)
]]
--[[
-- SAMPLES
local button = ButtonTextPUDD.new({
	imgup="gfx/ui/btn_01_up.png", imgdown="gfx/ui/btn_01_down.png",
	text="BUTTON 1", textscalex=4, textcolorup=0x0, textcolordown=0xffff00,
})
local button2 = ButtonTextPUDD.new({
	imgup="gfx/ui/btn_02_up.png", imgdown="gfx/ui/btn_02_down.png", imgdisabled="gfx/ui/btn_02_disabled.png",
	text="BUTTON 2", textscalex=4, textcolorup=0x0, textcolordown=0xffff00, font = "fonts/Kenney Future Narrow.ttf", fontsize = 10,
	nohover=true,
})
button:addEventListener("clicked", function()
	button2:setDisabled(not button2:isDisabled())
end)
button2:addEventListener("click", function()
	-- your code here
end)

local button3 = ButtonTextPUDD.new({
	pixelcolorup = "0xffddff", pixelcolordown = "0xff0000",
	text = "BUTTON 3", textscalex = 4,
})
button:setPosition(2.25 * 64, 2 * 32)
button2:setPosition(2.25 * 64, 4.5 * 32)
button3:setPosition(2.25 * 64, 7 * 32)
stage:addChild(button)
stage:addChild(button2)
stage:addChild(button3)
]]
ButtonTextPUDD = Core.class(Sprite)

function ButtonTextPUDD:init(xparams)
	-- the params
	self.params = xparams or {}
	-- textures?
	self.params.imgup = xparams.imgup or nil -- img up path
	self.params.imgdown = xparams.imgdown or self.params.imgup -- img down path
	self.params.imgdisabled = xparams.imgdisabled or self.params.imgup -- img disabled path
	self.params.imgscalex = xparams.imgscalex or nil -- number or nil = autoscale
	self.params.imgscaley = xparams.imgscaley or nil -- number or nil = autoscale
	-- pixel?
	self.params.pixelcolorup = xparams.pixelcolorup or nil -- color
	self.params.pixelcolordown = xparams.pixelcolordown or self.params.pixelcolorup -- color
	self.params.pixelcolordisabled = xparams.pixelcolordisabled or 0x555555 -- color
	self.params.pixelscalex = xparams.pixelscalex or nil -- number or nil = autoscale
	self.params.pixelscaley = xparams.pixelscaley or nil -- number or nil = autoscale
	-- text?
	self.params.text = xparams.text or nil -- string
	self.params.font = xparams.font or nil -- ttf font path
	self.params.fontsize = xparams.fontsize or 16 -- number
	self.params.textcolorup = xparams.textcolorup or 0x0 -- color
	self.params.textcolordown = xparams.textcolordown or self.params.textcolorup -- color
	self.params.textcolordisabled = xparams.textcolordisabled or 0x777777 -- color
	self.params.textscalex = xparams.textscalex or 1 -- number
	self.params.textscaley = xparams.textscaley or self.params.textscalex -- number
	self.params.nohover = xparams.nohover or nil -- boolean
	-- let's go
	self.sprite = Sprite.new()
	self.sprite:setAnchorPoint(0.5,0.5)
	self:addChild(self.sprite)
	-- button has up state image?
	if self.params.imgup ~= nil then
		self.bmpup = Bitmap.new(Texture.new(self.params.imgup))
		self.bmpup:setAnchorPoint(0.5, 0.5)
		self.bmpupwidth = self.bmpup:getWidth()
		self.bmpupheight = self.bmpup:getHeight()
		self.sprite:addChild(self.bmpup)
		self.hasbmpup = true
	else
		self.hasbmpup = false
	end
	-- button has down state image?
	if self.params.imgdown ~= nil then
		self.bmpdown = Bitmap.new(Texture.new(self.params.imgdown))
		self.bmpdown:setAnchorPoint(0.5, 0.5)
		self.bmpdownwidth = self.bmpdown:getWidth()
		self.bmpdownheight = self.bmpdown:getHeight()
		self.sprite:addChild(self.bmpdown)
		self.hasbmpdown = true
	else
		self.hasbmpdown = false
	end
	-- button has disabled state image?
	if self.params.imgdisabled ~= nil then
		self.bmpdisabled = Bitmap.new(Texture.new(self.params.imgdisabled))
		self.bmpdisabled:setAnchorPoint(0.5, 0.5)
		self.bmpdisabledwidth = self.bmpdown:getWidth()
		self.bmpdisabledheight = self.bmpdown:getHeight()
		self.sprite:addChild(self.bmpdisabled)
		self.hasbmpdisabled = true
	else
		self.hasbmpdisabled = false
	end
	-- button has pixel?
	if self.params.pixelcolorup ~= nil then
		self.pixel = Pixel.new(self.params.pixelcolor, 1, 48, 48)
		self.pixel:setAnchorPoint(0.5, 0.5)
		self.pixel:setScale(self.params.pixelscalex or 1, self.params.pixelscaley or 1)
		self.pixelwidth, self.pixelheight = self.pixel:getSize()
		self.sprite:addChild(self.pixel)
		self.haspixel = true
	else
		self.haspixel = false
	end
	-- button has text?
	if self.params.text ~= nil then
		self:setText(self.params.text)
		self.hastext = true
	else
		self.hastext = false
	end
	-- warnings
	if not self.hasbmpup and not self.hasbmpdown and not self.hasbmpdisabled and not self.haspixel and not self.hastext then
		print("*** WARNING: BUTTON NEEDS AT LEAST A TEXTURE, A PIXEL OR SOME TEXT! ***")
	end
	-- update visual state
	self.focus = false
	self.disabled = false
	self:updateVisualState(false)
	-- event listeners
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
	self:addEventListener(Event.MOUSE_HOVER, self.onMouseHover, self)
	if self.params.nohover then
--		print("*** no mouse hover effect ***")
		self:removeEventListener(Event.MOUSE_HOVER, self.onMouseHover, self)
	end
	-- mobile
	self:addEventListener(Event.TOUCHES_BEGIN, self.onTouchesBegin, self)
	self:addEventListener(Event.TOUCHES_MOVE, self.onTouchesMove, self)
	self:addEventListener(Event.TOUCHES_END, self.onTouchesEnd, self)
	self:addEventListener(Event.TOUCHES_CANCEL, self.onTouchesCancel, self)
end

-- FUNCTIONS
function ButtonTextPUDD:setText(xtext)
	if self.params.font ~= nil then
--		self.font = TTFont.new(self.params.font, self.params.fontsize, "", true, 1) -- , filtering, outline (number)
		self.font = TTFont.new(self.params.font, self.params.fontsize, "")
	end
	if self.text ~= nil then
		self.text:setText(xtext)
	else
		self.text = TextField.new(self.font, xtext, xtext)
	end
	self.text:setAnchorPoint(0.5, 0.5)
	self.text:setScale(self.params.textscalex, self.params.textscaley)
	self.text:setTextColor(self.params.textcolorup)
	self.textwidth = self.text:getWidth()
	self.textheight = self.text:getHeight()
	self.sprite:addChild(self.text)
	-- has image
	if self.hasbmpup then
		-- scale image
		local sx, sy = 1, 1
		if self.bmpupwidth < self.textwidth then
			sx = self.params.imgscalex or (self.textwidth/self.bmpupwidth * 1.25)
			sy = self.params.imgscaley or (self.textheight/self.bmpupheight * 2)
		end
		self.bmpup:setScale(sx, sy)
	end
	if self.hasbmpdown then
		local sx, sy = 1, 1
		if self.bmpdownwidth < self.textwidth then
			sx = self.params.imgscalex or (self.textwidth/self.bmpdownwidth * 1.25)
			sy = self.params.imgscaley or (self.textheight/self.bmpdownheight * 2)
		end
		self.bmpdown:setScale(sx, sy)
	end
	if self.hasbmpdisabled then
		local sx, sy = 1, 1
		if self.bmpdisabledwidth < self.textwidth then
			sx = self.params.imgscalex or (self.textwidth/self.bmpdisabledwidth * 1.25)
			sy = self.params.imgscaley or (self.textheight/self.bmpdisabledheight * 2)
		end
		self.bmpdisabled:setScale(sx, sy)
	end
	-- has pixel
	if self.haspixel then
		local sx, sy = 1, 1
		if self.pixelwidth < self.textwidth then
			sx = self.textwidth/self.pixelwidth * 1.25
			sy = self.textheight/self.pixelheight * 2
		end
		self.pixel:setScale(sx, sy)
	end
end

function ButtonTextPUDD:setTextColor(xcolor)
	self.text:setTextColor(xcolor or 0x0)
end

-- VISUAL STATE
function ButtonTextPUDD:updateVisualState(xstate)
	if self.disabled then -- button disabled state
		if self.params.imgup ~= nil then self.bmpup:setVisible(false) end
		if self.params.imgdown ~= nil then self.bmpdown:setVisible(false) end
		if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(true) end
		if self.params.pixelcolorup ~= nil then self.pixel:setColor(self.params.pixelcolordisabled) end
		if self.params.text ~= nil then self.text:setTextColor(self.params.textcolordisabled) end
	else
		if xstate then -- button down state
			if self.params.imgup ~= nil then self.bmpup:setVisible(false) end
			if self.params.imgdown ~= nil then self.bmpdown:setVisible(true) end
			if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(false) end
			if self.params.pixelcolorup ~= nil then self.pixel:setColor(self.params.pixelcolordown) end
			if self.params.text ~= nil then self.text:setTextColor(self.params.textcolordown) end
		else -- button up state
			if self.params.imgup ~= nil then self.bmpup:setVisible(true) end
			if self.params.imgdown ~= nil then self.bmpdown:setVisible(false) end
			if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(false) end
			if self.params.pixelcolorup ~= nil then self.pixel:setColor(self.params.pixelcolorup) end
			if self.params.text ~= nil then self.text:setTextColor(self.params.textcolorup) end
		end
	end
end

function ButtonTextPUDD:setDisabled(xdisabled)
	if self.disabled == xdisabled then
		return
	end
	self.disabled = xdisabled
	self.focus = false
	self:updateVisualState(false)
end

function ButtonTextPUDD:isDisabled()
	return self.disabled
end

-- BUTTON LISTENERS
-- mouse
function ButtonTextPUDD:onMouseDown(e)
	if self:hitTestPoint(e.x, e.y) then
		self.focus = true
		self:updateVisualState(true)
		e:stopPropagation()
	end
end
function ButtonTextPUDD:onMouseMove(e)
	if self:hitTestPoint(e.x, e.y) then
		self.focus = true
		self:updateVisualState(true)
		e:stopPropagation()
	end
	if self.focus then
		if not self:hitTestPoint(e.x, e.y) then
			self.focus = false
			self:updateVisualState(false)
--			e:stopPropagation() -- you may want to comment this line
		end
	end
end
function ButtonTextPUDD:onMouseUp(e)
	if self.focus then
		self.focus = false
		self:updateVisualState(false)
		if not self.disabled then
			self:dispatchEvent(Event.new("clicked"))	-- button is clicked, dispatch "click" event
		end
		e:stopPropagation()
	end
end
function ButtonTextPUDD:onMouseHover(e)
	if self:hitTestPoint(e.x, e.y) then
		self.focus = true
		self:updateVisualState(true)
	else
		self.focus = false
		self:updateVisualState(false)
	end
end
-- touch
function ButtonTextPUDD:onTouchesBegin(e)
	if self.focus then
		e:stopPropagation()
	end
end
function ButtonTextPUDD:onTouchesMove(e)
	if self.focus then
		e:stopPropagation()
	end
end
function ButtonTextPUDD:onTouchesEnd(e)
	if self.focus then
		e:stopPropagation()
	end
end
function ButtonTextPUDD:onTouchesCancel(e)
	if self.focus then
		self.focus = false
		self:updateVisualState(false)
		e:stopPropagation()
	end
end
