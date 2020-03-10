--[[
A Button class with text and/or image with Up state, Down state, Disabled state (UDD)
This code is MIT licensed, see http://www.opensource.org/licenses/mit-license.php
github: mokalux
v 0.1.0: 2020-03-09 init (based on the initial gideros generic button class)
]]
--[[
-- sample usage
	local button = ButtonTextUDD.new(
		{
			text="01", textscalex=4, textcolorup=0x0, textcolordown=0xffff00,
			imgdown="gfx/ui/Blue.png",
			nohover=false,
		}
	)
	button:setPosition(64, 2 * 16)
	stage:addChild(button)

	local button2 = ButtonTextUDD.new(
		{
			text="02 CAN DO", textscalex=4, textcolorup=0x0, textcolordown=0xffff00,
			imgup="gfx/ui/blue (2).png", imgdown="gfx/ui/Blue.png", imgdisabled="gfx/ui/blocker2.png",
			nohover=true,
		}
	)
	button2:setPosition(64, 4 * 16)
	stage:addChild(button2)

	button:addEventListener("click", function()
		button2:setDisabled(not button2:isDisabled())
	end)
	button2:addEventListener("click", function()
		-- your code here
	end)
]]
ButtonTextUDD = Core.class(Sprite)

function ButtonTextUDD:init(xparams)
	-- the params
	self.params = xparams or {}
	self.params.imgup = xparams.imgup or nil -- img up path
	self.params.imgdown = xparams.imgdown or self.params.imgup -- img down path
	self.params.imgdisabled = xparams.imgdisabled or self.params.imgup -- img disabled path
	self.params.imgscalex = xparams.imgscalex or nil -- number or nil = autoscale
	self.params.imgscaley = xparams.imgscaley or nil -- number or nil = autoscale
	self.params.text = xparams.text or nil -- string
	self.params.font = xparams.font or nil -- ttf font path
	self.params.fontsize = xparams.fontsize or 16 -- number
	self.params.textcolorup = xparams.textcolorup or 0x0 -- color
	self.params.textcolordown = xparams.textcolordown or self.params.textcolorup -- color
	self.params.textcolordisabled = xparams.textcolordisabled or 0x555555 -- color
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
	-- button has text?
	if self.params.text ~= nil then
		self:setText(self.params.text)
		self.hastext = true
	else
		self.hastext = false
	end
	-- warnings
	if not self.hasbmpup and not self.hasbmpdown and not self.hasbmpdisabled and not self.hastext then
		print("*** WARNING: BUTTONTEXT NEEDS AT LEAST SOME TEXT OR SOME BITMAPS! ***")
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
		print("*** no mouse hover effect ***")
		self:removeEventListener(Event.MOUSE_HOVER, self.onMouseHover, self)
	end
	-- mobile
	self:addEventListener(Event.TOUCHES_BEGIN, self.onTouchesBegin, self)
	self:addEventListener(Event.TOUCHES_MOVE, self.onTouchesMove, self)
	self:addEventListener(Event.TOUCHES_END, self.onTouchesEnd, self)
	self:addEventListener(Event.TOUCHES_CANCEL, self.onTouchesCancel, self)
end

-- FUNCTIONS
function ButtonTextUDD:setText(xtext)
	if self.params.font ~= nil then
		self.font = TTFont.new(self.params.font, self.params.fontsize)
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
	-- scale image
	if self.hasbmpup then
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
end

function ButtonTextUDD:setTextColor(xcolor)
	self.text:setTextColor(xcolor or 0x0)
end

-- VISUAL STATE
function ButtonTextUDD:updateVisualState(xstate)
	if self.disabled then -- button disabled state
		if self.params.imgup ~= nil then self.bmpup:setVisible(false) end
		if self.params.imgdown ~= nil then self.bmpdown:setVisible(false) end
		if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(true) end
		if self.params.text ~= nil then self.text:setTextColor(self.params.textcolordisabled) end
	else
		if xstate then -- button down state
			if self.params.imgup ~= nil then self.bmpup:setVisible(false) end
			if self.params.imgdown ~= nil then self.bmpdown:setVisible(true) end
			if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(false) end
			if self.params.text ~= nil then self.text:setTextColor(self.params.textcolordown) end
		else -- button up state
			if self.params.imgup ~= nil then self.bmpup:setVisible(true) end
			if self.params.imgdown ~= nil then self.bmpdown:setVisible(false) end
			if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(false) end
			if self.params.text ~= nil then self.text:setTextColor(self.params.textcolorup) end
		end
	end
end

function ButtonTextUDD:setDisabled(xdisabled)
	if self.disabled == xdisabled then
		return
	end
	self.disabled = xdisabled
	self.focus = false
	self:updateVisualState(false)
end

function ButtonTextUDD:isDisabled()
	return self.disabled
end

-- BUTTON LISTENERS
-- mouse
function ButtonTextUDD:onMouseDown(e)
	if self:hitTestPoint(e.x, e.y) then
		self.focus = true
		self:updateVisualState(true)
		e:stopPropagation()
	end
end
function ButtonTextUDD:onMouseMove(e)
	if self:hitTestPoint(e.x, e.y) then
		self.focus = true
		self:updateVisualState(true)
		e:stopPropagation()
	end
	if self.focus then
		if not self:hitTestPoint(e.x, e.y) then
			self.focus = false
			self:updateVisualState(false)
			e:stopPropagation()
		end
	end
end
function ButtonTextUDD:onMouseUp(e)
	if self.focus then
		self.focus = false
		self:updateVisualState(false)
		if not self.disabled then
			self:dispatchEvent(Event.new("click"))	-- button is clicked, dispatch "click" event
		end
		e:stopPropagation()
	end
end
function ButtonTextUDD:onMouseHover(e)
	if self:hitTestPoint(e.x, e.y) then
		self.focus = true
		self:updateVisualState(true)
	else
		self.focus = false
		self:updateVisualState(false)
	end
end
-- touch
function ButtonTextUDD:onTouchesBegin(e)
	if self.focus then
		e:stopPropagation()
	end
end
function ButtonTextUDD:onTouchesMove(e)
	if self.focus then
		e:stopPropagation()
	end
end
function ButtonTextUDD:onTouchesEnd(e)
	if self.focus then
		e:stopPropagation()
	end
end
function ButtonTextUDD:onTouchesCancel(e)
	if self.focus then
		self.focus = false
		self:updateVisualState(false)
		e:stopPropagation()
	end
end
