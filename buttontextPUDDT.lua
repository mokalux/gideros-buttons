--[[
ButtonTextPUDDT
A Button class with text, Pixel, images (Up, Down, Disabled) and Tooltip
This code is CC0
github: mokalux
v 0.1.3: 2020-03-30 added tooltip
v 0.1.2: 2020-03-29 added nine patch
v 0.1.1: 2020-03-28 added pixel
v 0.1.0: 2020-03-28 init (based on the initial gideros generic button class)
]]
--[[
-- SAMPLES
-- BUTTON QUIT
local mybtnquit = ButtonTextPUDDT.new({
	imgup="gfx/ui/btn_01_up.png", imgdown="gfx/ui/btn_01_down.png",imgdisabled="gfx/ui/btn_01_disabled.png",
	text="QUIT", font=g_font1, fontsize=32, textcolorup=mytextcolorup, textcolordown=mytextcolordown,
	tooltip="QUIT?",
})
self:addChild(mybtnquit)
mybtnquit:addEventListener("clicked", function() self:goExit() end)
mybtnquit:setDisabled(true)
]]
ButtonTextPUDDT = Core.class(Sprite)

function ButtonTextPUDDT:init(xparams)
	-- the params
	self.params = xparams or {}
	-- textures?
	self.params.imgup = xparams.imgup or nil -- img up path
	self.params.imgdown = xparams.imgdown or self.params.imgup -- img down path
	self.params.imgdisabled = xparams.imgdisabled or self.params.imgup -- img disabled path
	self.params.imagealpha = xparams.imagealpha or 1 -- number
	self.params.imgscalex = xparams.imgscalex or 1 -- number
	self.params.imgscaley = xparams.imgscaley or 1 -- number
	self.params.imagepaddingx = xparams.imagepaddingx or nil -- number (nil = auto, the image width)
	self.params.imagepaddingy = xparams.imagepaddingy or nil -- number (nil = auto, the image height)
	-- pixel?
	self.params.pixelcolorup = xparams.pixelcolorup or nil -- color
	self.params.pixelcolordown = xparams.pixelcolordown or self.params.pixelcolorup -- color
	self.params.pixelcolordisabled = xparams.pixelcolordisabled or 0x555555 -- color
	self.params.pixelalpha = xparams.pixelalpha or 1 -- number
	self.params.pixelscalex = xparams.pixelscalex or 1 -- number
	self.params.pixelscaley = xparams.pixelscaley or 1 -- number
	self.params.pixelpaddingx = xparams.pixelpaddingx or 12 -- number
	self.params.pixelpaddingy = xparams.pixelpaddingy or 12 -- number
	-- text?
	self.params.text = xparams.text or nil -- string
	self.params.font = xparams.font or nil -- ttf font path
	self.params.fontsize = xparams.fontsize or 16 -- number
	self.params.textcolorup = xparams.textcolorup or 0x0 -- color
	self.params.textcolordown = xparams.textcolordown or self.params.textcolorup -- color
	self.params.textcolordisabled = xparams.textcolordisabled or 0x777777 -- color
	self.params.textscalex = xparams.textscalex or 1 -- number
	self.params.textscaley = xparams.textscaley or self.params.textscalex -- number
	-- EXTRAS
	self.params.isautoscale = xparams.isautoscale or 1 -- number (default 1 = true)
	self.params.hover = xparams.hover or 1 -- number (default 1 = true)
	self.params.defaultpadding = xparams.defaultpadding or 12 -- number
	self.params.tooltip = xparams.tooltip or nil -- string
	-- LET'S GO!
	-- button has images/pixel/text?
	if self.params.imgup ~= nil then self.hasbmpup = true else self.hasbmpup = false end
	if self.params.imgdown ~= nil then self.hasbmpdown = true else self.hasbmpdown = false end
	if self.params.imgdisabled ~= nil then self.hasbmpdisabled = true else self.hasbmpdisabled = false end
	if self.params.pixelcolorup ~= nil then self.haspixel = true else self.haspixel = false end
	if self.params.text ~= nil then self.hastext = true else self.hastext = false end
	-- EXTRAS
	if self.params.isautoscale == 0 then self.params.isautoscale = false else self.params.isautoscale = true end
	if self.params.hover == 0 then self.params.hover = false else self.params.hover = true end
	if self.params.tooltip ~= nil then self.hastooltip = true else self.hastooltip = false end
	-- warnings
	if not self.hasbmpup and not self.hasbmpdown and not self.hasbmpdisabled
		and not self.haspixel and not self.hastext and not self.hastooltip then
		print("*** WARNING: YOUR BUTTON IS EMPTY! ***")
	else
		-- mouse catcher
		self.catcher = Pixel.new(0x0, 0, 1, 1)
		self:addChild(self.catcher)
		-- sprite holder
		self.sprite = Sprite.new()
		self:addChild(self.sprite)
		self:setButton()
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
	if not self.params.hover and not self.hastooltip then
		print("*** no mouse hover effect ***")
		self:removeEventListener(Event.MOUSE_HOVER, self.onMouseHover, self)
	end
end

-- FUNCTIONS
function ButtonTextPUDDT:setButton()
	local textwidth, textheight
	local bmps = {}
	-- text
	if self.hastext then
		local font
		if self.params.font ~= nil then
	--		font = TTFont.new(self.params.font, self.params.fontsize, "", true, 1) -- filtering, outline (number)
			font = TTFont.new(self.params.font, self.params.fontsize, "")
		end
		if self.text ~= nil then
			self.text:setButton(self.params.text)
		else
			self.text = TextField.new(font, self.params.text, self.params.text)
		end
		self.text:setAnchorPoint(0.5, 0.5)
		self.text:setScale(self.params.textscalex, self.params.textscaley)
		self.text:setTextColor(self.params.textcolorup)
		textwidth, textheight = self.text:getWidth(), self.text:getHeight()
	end
	-- first add pixel
	if self.haspixel then
		if self.params.isautoscale and self.hastext then
			self.pixel = Pixel.new(
				self.params.pixelcolor, self.params.pixelalpha,
				textwidth + self.params.pixelpaddingx,
				textheight + self.params.pixelpaddingy)
		else
			self.pixel = Pixel.new(
				self.params.pixelcolor, self.params.pixelalpha,
				self.params.pixelpaddingx,
				self.params.pixelpaddingy)
		end
		self.pixel:setAnchorPoint(0.5, 0.5)
		self.pixel:setScale(self.params.pixelscalex, self.params.pixelscaley)
		self.sprite:addChild(self.pixel)
	end
	-- then images
	if self.hasbmpup then
		local texup = Texture.new(self.params.imgup)
		if self.params.isautoscale and self.hastext then
			self.bmpup = Pixel.new(texup,
				textwidth + (self.params.imagepaddingx or self.params.defaultpadding),
				textheight + (self.params.imagepaddingy or self.params.defaultpadding))
		else
			self.bmpup = Pixel.new(texup, self.params.imagepaddingx, self.params.imagepaddingy)
		end
		bmps[self.bmpup] = 1
	end
	if self.hasbmpdown then
		local texdown = Texture.new(self.params.imgdown)
		if self.params.isautoscale and self.hastext then
			self.bmpdown = Pixel.new(texdown,
				textwidth + (self.params.imagepaddingx or self.params.defaultpadding),
				textheight + (self.params.imagepaddingy or self.params.defaultpadding))
		else
			self.bmpdown = Pixel.new(texdown, self.params.imagepaddingx, self.params.imagepaddingy)
		end
		bmps[self.bmpdown] = 2
	end
	if self.hasbmpdisabled then
		local texdisabled = Texture.new(self.params.imgdisabled)
		if self.params.isautoscale and self.hastext then
			self.bmpdisabled = Pixel.new(texdisabled,
				textwidth + (self.params.imagepaddingx or self.params.defaultpadding),
				textheight + (self.params.imagepaddingy or self.params.defaultpadding))
		else
			self.bmpdisabled = Pixel.new(texdisabled, self.params.imagepaddingx, self.params.imagepaddingy)
		end
		bmps[self.bmpdisabled] = 3
	end
	-- image batch
	for k, _ in pairs(bmps) do
		k:setAnchorPoint(0.5, 0.5)
		k:setAlpha(self.params.imagealpha)
		local split = 9 -- magik number
		k:setNinePatch(math.floor(k:getWidth()/split), math.floor(k:getWidth()/split),
			math.floor(k:getHeight()/split), math.floor(k:getHeight()/split))
		self.sprite:addChild(k)
	end
	-- finally add text on top of all
	if self.hastext then self.sprite:addChild(self.text) end
	-- and the tooltip
	if self.hastooltip then
		self.tooltip = TextField.new(nil, self.params.tooltip)
		self.tooltip:setScale(2)
		self.tooltip:setTextColor(0xffff00)
		self.tooltip:setVisible(false)
--		self.sprite:addChild(self.tooltip) -- best to add here?
		self:addChild(self.tooltip) -- or best to add to self?
	end
	-- mouse catcher
	self.catcher:setDimensions(self.sprite:getWidth() + 8 * 2, self.sprite:getHeight() + 8 * 2) -- magik number
	self.catcher:setAnchorPoint(0.5, 0.5)
end

--function ButtonTextPUDDT:setTextColor(xcolor)
--	self.text:setTextColor(xcolor or 0x0)
--end

-- VISUAL STATE
function ButtonTextPUDDT:updateVisualState(xstate)
	if self.disabled then -- button disabled state
		if self.params.imgup ~= nil then self.bmpup:setVisible(false) end
		if self.params.imgdown ~= nil then self.bmpdown:setVisible(false) end
		if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(true) end
		if self.params.pixelcolorup ~= nil then self.pixel:setColor(self.params.pixelcolordisabled) end
		if self.params.text ~= nil then self.text:setTextColor(self.params.textcolordisabled) end
	elseif not self.params.hover then -- button does not hover
		if self.params.imgup ~= nil then self.bmpup:setVisible(true) end
		if self.params.imgdown ~= nil then self.bmpdown:setVisible(false) end
		if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(false) end
		if self.params.pixelcolorup ~= nil then self.pixel:setColor(self.params.pixelcolorup) end
		if self.params.text ~= nil then self.text:setTextColor(self.params.textcolorup) end
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
--	if self.hastooltip and not self.disabled then -- you can choose this option
	if self.hastooltip then -- or this option :-)
		if xstate then -- button hover state
			if self.disabled then
				self.tooltip:setText("( "..self.params.tooltip.." )")
			else
				self.tooltip:setText(self.params.tooltip)
			end
			self.tooltip:setVisible(true)
		else -- button no hover state
			self.tooltip:setText("")
			self.tooltip:setVisible(false)
		end
	end
end

function ButtonTextPUDDT:setDisabled(xdisabled)
	if self.disabled == xdisabled then return end
	self.disabled = xdisabled
	self.focus = false
	self:updateVisualState(false)
end

function ButtonTextPUDDT:isDisabled()
	return self.disabled
end

-- BUTTON LISTENERS
-- mouse
function ButtonTextPUDDT:onMouseDown(e)
	if self:hitTestPoint(e.x, e.y) then
		self.focus = true
		self:updateVisualState(true)
		e:stopPropagation()
	end
end
function ButtonTextPUDDT:onMouseMove(e)
	if self:hitTestPoint(e.x, e.y) then
		self.focus = true
		e:stopPropagation()
	else
		self.focus = false
--		e:stopPropagation() -- you may want to comment this line
	end
	self:updateVisualState(self.focus)
end
function ButtonTextPUDDT:onMouseUp(e)
	if self.focus then
		self.focus = false
		self:updateVisualState(false)
		if not self.disabled then
			self:dispatchEvent(Event.new("clicked")) -- button is clicked, dispatch "clicked" event
		end
		e:stopPropagation()
	end
end
function ButtonTextPUDDT:onMouseHover(e)
	if self.catcher:hitTestPoint(e.x, e.y) then
		self.focus = false
	end
	if self.sprite:hitTestPoint(e.x, e.y) then
		if self.hastooltip then self.tooltip:setPosition(self.sprite:globalToLocal(e.x, e.y)) end
		self.focus = true
	end
	self:updateVisualState(self.focus)
end
