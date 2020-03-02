--[[
A Button class with text and/or image
This code is MIT licensed, see http://www.opensource.org/licenses/mit-license.php
mokalux
v.1: 2020-03-02
]]
ButtonText = Core.class(Sprite)

function ButtonText:init(xparams)
	-- the params
	self.params = xparams or {}
	self.params.upstate = xparams.upstate or nil -- img path
	self.params.downstate = xparams.downstate or nil -- img path
	self.params.imgscalex = xparams.imagescalex or nil -- number
	self.params.imgscaley = xparams.imagescaley or nil -- number
	self.params.text = xparams.text or nil -- text
	self.params.font = xparams.font or nil -- ttf font path
	self.params.fontsize = xparams.fontsize or 16 -- number
	self.params.textcolorup = xparams.textcolorup or 0x0 -- color
	self.params.textcolordown = xparams.textcolordown or self.params.textcolorup -- color
	self.params.textscalex = xparams.textscalex or 1 -- number
	self.params.textscaley = xparams.textscaley or self.params.textscalex -- number
	-- let's go
	self.sprite = Sprite.new()
	self.sprite:setAnchorPoint(0.5,0.5)
	self:addChild(self.sprite)
	-- button has image?
	if self.params.upstate ~= nil then
		self.upstate = Bitmap.new(Texture.new(self.params.upstate))
		self.downstate = Bitmap.new(Texture.new(self.params.downstate or self.params.upstate))
		self.upstate:setAnchorPoint(0.5, 0.5)
		self.downstate:setAnchorPoint(0.5, 0.5)
		self.bmpwidth = self.upstate:getWidth()
		self.bmpheight = self.upstate:getHeight()
		self.sprite:addChild(self.upstate)
		self.sprite:addChild(self.downstate)
		self.hasbmp = true
	else
		self.hasbmp = false
	end
	-- button has text?
	if self.params.text ~= nil then
		self:setText(self.params.text)
		self.hastext = true
	else
		self.hastext = false
	end
	-- warnings
	if not self.hasbmp and not self.hastext then
		print("*** WARNING: BUTTONTEXT NEEDS AT LEAST SOME TEXT OR SOME BITMAP! ***")
	end
	-- update visual state
	self.focus = false
	if self.hasbmp then
		self:updateVisualState(false)
	end
	-- event listeners
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
	self:addEventListener(Event.MOUSE_HOVER, self.onMouseHover, self)
	-- mobile
	self:addEventListener(Event.TOUCHES_BEGIN, self.onTouchesBegin, self)
	self:addEventListener(Event.TOUCHES_MOVE, self.onTouchesMove, self)
	self:addEventListener(Event.TOUCHES_END, self.onTouchesEnd, self)
	self:addEventListener(Event.TOUCHES_CANCEL, self.onTouchesCancel, self)
end

-- FUNCTIONS
function ButtonText:setText(xtext)
	if self.params.font ~= nil then
		self.font = TTFont.new(self.params.font, self.params.fontsize)
	end
	if self.text == nil then
		self.text = TextField.new(self.font, xtext, xtext)
	else
		self.text:setText(xtext)
	end
	self.text:setAnchorPoint(0.5, 0.5)
	self.text:setScale(self.params.textscalex, self.params.textscaley)
	self.text:setTextColor(self.params.textcolorup)
	self.textwidth = self.text:getWidth()
	self.textheight = self.text:getHeight()
	self.sprite:addChild(self.text)
	-- scale image
	if self.hasbmp then
		local sx = self.params.imgscalex or (self.textwidth/self.bmpwidth * 1.25)
		local sy = self.params.imgscaley or (self.textheight/self.bmpheight * 2)
		self.upstate:setScale(sx, sy)
		self.downstate:setScale(sx, sy)
	end
end

function ButtonText:setTextColor(xcolor)
	self.text:setTextColor(xcolor or 0x0)
end

-- VISUAL STATE
function ButtonText:updateVisualState(xisdown)
	if self.hasbmp then
		if xisdown then
			self.upstate:setVisible(false)
			self.downstate:setVisible(true)
			self.text:setTextColor(self.params.textcolordown)
		else
			self.upstate:setVisible(true)
			self.downstate:setVisible(false)
			self.text:setTextColor(self.params.textcolorup)
		end
	end
end

-- BUTTON LISTENERS
-- mouse
function ButtonText:onMouseDown(event)
	if self:hitTestPoint(event.x, event.y) then
		self.focus = true
		self:updateVisualState(true)
		event:stopPropagation()
	end
end
function ButtonText:onMouseMove(event)
	if self:hitTestPoint(event.x, event.y) then
		self.focus = true
		self:updateVisualState(true)
	end
	if not self:hitTestPoint(event.x, event.y) then
		self.focus = false
		self:updateVisualState(false)
	end
	event:stopPropagation()
end
function ButtonText:onMouseUp(event)
	if self.focus then
		self.focus = false
		self:updateVisualState(false)
		self:dispatchEvent(Event.new("click"))
		event:stopPropagation()
	end
end
function ButtonText:onMouseHover(event)
	if self:hitTestPoint(event.x, event.y) then
		self.focus = true
		self:updateVisualState(true)
	else
		self.focus = false
		self:updateVisualState(false)
	end
	event:stopPropagation()
end
-- mobile
function ButtonText:onTouchesBegin(event)
	if self.focus then
		event:stopPropagation()
	end
end
function ButtonText:onTouchesMove(event)
	if self.focus then
		event:stopPropagation()
	end
end
function ButtonText:onTouchesEnd(event)
	if self.focus then
		event:stopPropagation()
	end
end
function ButtonText:onTouchesCancel(event)
	if self.focus then
		self.focus = false
		self:updateVisualState(false)
		event:stopPropagation()
	end
end
--[[
-- usage
local btn1 = ButtonText.new(
	{text="Hello -- World", textcolorup=0xff00ff, textscalex=4,
	upstate="gfx/btns/mid_up.png", downstate="gfx/btns/mid_down.png"}
)
btn1:setText("START")
btn1:setPosition(128,128)
stage:addChild(btn1)
local x=0
btn1:addEventListener("click", function()
	x+=1
	print("clicked: "..x)
end)
]]
