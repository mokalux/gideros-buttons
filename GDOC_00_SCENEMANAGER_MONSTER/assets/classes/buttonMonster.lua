--[[ *** Monster Button ***
	A Button Class with Text, Pixel, Images 9patch (Up, Down, Disabled), Tooltip Sfx and Keyboard navigation!
	github: mokalux, this code is CC0

	v 0.1.0: 2021-06-01 total recall, this class has become a Monster! best used in menus but who knows?
	v 0.0.1: 2020-03-28 init (based on the initial gideros generic button class)
]]
--[[
-- SAMPLE
	local mybtn06 = ButtonMonster.new({
		scalexup=1, scalexdown=1.2,
		pixelcolorup=0xff00ff,
		isautoscale=true,
		pixelpaddingx=32*5, pixelpaddingy=32*2.5, imgpaddingx=32*5, imgpaddingy=32*2.5,
		imgup="gfx/ui/Cross grey.png",
		text="YYY", ttf=font01, textcolorup=textcolorup, textcolordown=textcolordown,
	}, 6)
	mybtn06:setPosition(1*myappwidth/2, 1*myappheight/10)
	self:addChild(mybtn06)
	-- a btns table
	self.btns = {}
	self.btns[#self.btns + 1] = mybtn06
	-- ui btns listeners
	for k, v in ipairs(self.btns) do
		v:addEventListener("clicked", function() self:goto() end) -- click event
		v.btns = self.btns -- ui navigation update
	end
]]

ButtonMonster = Core.class(Sprite)

function ButtonMonster:init(xparams, xselector)
	-- the params table
	self.params = xparams or {}
	self.selector = xselector or nil -- for keyboard navigation
	self.btns = nil -- assign this value directly from your class, you assign it a list of navigatable buttons
	-- button
	-- add btn color up and down? sprite:setColorTransform(255/255, ...)
	self.params.btnalphaup = xparams.btnalphaup or 1 -- number between 0 and 1
	self.params.btnalphadown = xparams.btnalphadown or self.params.btnalphaup -- number between 0 and 1
	self.params.btnscalexup = xparams.btnscalexup or nil -- number
	self.params.btnscaleyup = xparams.btnscaleyup or self.params.btnscalexup -- number
	self.params.btnscalexdown = xparams.btnscalexdown or self.params.btnscalexup -- number
	self.params.btnscaleydown = xparams.btnscaleydown or self.params.btnscalexdown -- number
	-- pixel?
	self.params.pixelcolorup = xparams.pixelcolorup or nil -- color
	self.params.pixelcolordown = xparams.pixelcolordown or self.params.pixelcolorup -- color
	self.params.pixelcolordisabled = xparams.pixelcolordisabled or 0x555555 -- color
	self.params.pixelalphaup = xparams.pixelalphaup or 1 -- number between 0 and 1
	self.params.pixelalphadown = xparams.pixelalphadown or self.params.pixelalphaup -- number between 0 and 1
	self.params.pixelscalexup = xparams.pixelscalexup or 1 -- number
	self.params.pixelscaleyup = xparams.pixelscaleyup or self.params.pixelscalexup -- number
	self.params.pixelscalexdown = xparams.pixelscalexdown or self.params.pixelscalexup -- number
	self.params.pixelscaleydown = xparams.pixelscaleydown or self.params.pixelscalexdown -- number
	self.params.pixelpaddingx = xparams.pixelpaddingx or 32 -- number
	self.params.pixelpaddingy = xparams.pixelpaddingy or self.params.pixelpaddingx -- number
	-- textures?
	self.params.imgup = xparams.imgup or nil -- img tex up path
	self.params.imgdown = xparams.imgdown or self.params.imgup -- img tex down path
	self.params.imgdisabled = xparams.imgdisabled or nil -- img tex disabled path
	self.params.imgalphaup = xparams.imgalphaup or 1 -- number between 0 and 1
	self.params.imgalphadown = xparams.imgalphadown or self.params.imgalphaup -- number between 0 and 1
	self.params.imgpaddingx = xparams.imgpaddingx or 32 -- number
	self.params.imgpaddingy = xparams.imgpaddingy or self.params.imgpaddingx -- number
	-- text?
	self.params.text = xparams.text or nil -- string
	self.params.ttf = xparams.ttf or nil -- ttf
	self.params.textcolorup = xparams.textcolorup or 0x0 -- color
	self.params.textcolordown = xparams.textcolordown or self.params.textcolorup -- color
	self.params.textcolordisabled = xparams.textcolordisabled or 0x777777 -- color
	self.params.textalphaup = xparams.textalphaup or 1 -- number between 0 and 1
	self.params.textalphadown = xparams.textalphaup or self.params.textalphaup -- number between 0 and 1
	self.params.textscalexup = xparams.textscalexup or 1 -- number
	self.params.textscaleyup = xparams.textscaleyup or self.params.textscalexup -- number
	self.params.textscalexdown = xparams.textscalexdown or self.params.textscalexup -- number
	self.params.textscaleydown = xparams.textscaleydown or self.params.textscalexdown -- number
	-- tool tip?
	self.params.tooltiptext = xparams.tooltiptext or nil -- string
	self.params.tooltipttf = xparams.tooltipttf or nil -- ttf
	self.params.tooltiptextcolor = xparams.tooltiptextcolor or 0xff00ff -- color
	self.params.tooltiptextscale = xparams.tooltiptextscale or 3 -- number
	self.params.tooltipoffsetx = xparams.tooltipoffsetx or 0 -- number
	self.params.tooltipoffsety = xparams.tooltipoffsety or 0 -- number
	-- audio?
	self.params.channel = xparams.channel or nil -- sound channel
	self.params.sound = xparams.sound or nil -- sound fx
	-- EXTRAS
	self.params.hover = xparams.hover or (xparams.hover == nil) -- boolean (default = true)
	self.params.isautoscale = xparams.isautoscale or (xparams.isautoscale == nil) -- boolean (default = true)
	self.params.fun = xparams.fun or nil -- function (please check function name if not working!)
	-- set warnings, errors
	local errors = false
	if not self.params.imgup and not self.params.imgdown and not self.params.imgdisabled
		and not self.params.pixelcolorup and not self.params.text and not self.params.tooltiptext then
		print("*** ERROR ***", "YOUR BUTTON IS EMPTY!", "ON BUTTON: "..self.selector)
		errors = true
	end
	if self.params.sound and not self.params.channel then
		print("*** ERROR ***", "YOU HAVE A SOUND BUT NO CHANNEL!", "ON BUTTON: "..self.selector)
		errors = true
	end
	if self.params.fun ~= nil and type(self.params.fun) ~= "function" then
		print("*** ERROR ***", "YOU ARE NOT PASSING A FUNCTION", "ON BUTTON: "..self.selector)
		errors = true
	end
	if errors then
		if self.params.text then self.params.text = self.params.text.." (error)"
		else self.params.text = "error"
		end
		self.params.ttf = nil self.params.textscalexup = 4 self.params.textscaleyup = 4
		self.params.textcolorup = 0xff0000
	end
	-- button sprite holder
	self.sprite = Sprite.new()
	self:addChild(self.sprite)
	-- let's go!
	self:setButton()
	self:updateVisualState()
	-- update visual state
	self.isclicked = nil
	self.ishovered = nil
	self.isdisabled = nil
	self.onenter = nil -- flag to execute a function only once *
	self.ismoving = nil -- * flag to execute a function only once
	self.iskeyboard = nil -- to set a different tooltip position for the keyboard
	-- event listeners
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
	self:addEventListener(Event.MOUSE_HOVER, self.onMouseHover, self)
	if not self.params.hover and not self.params.tooltiptext then
		self:removeEventListener(Event.MOUSE_HOVER, self.onMouseHover, self)
	end
end

-- FUNCTIONS
function ButtonMonster:setButton()
	local textwidth, textheight
	local bmps = {}
	-- text
	if self.params.text then
		self.text = TextField.new(self.params.ttf, self.params.text, self.params.text)
		self.text:setAnchorPoint(0.5, 0.5)
		self.text:setScale(self.params.textscalexup, self.params.textscaleyup)
		self.text:setTextColor(self.params.textcolorup)
		self.text:setAlpha(self.params.textalphaup)
		textwidth, textheight = self.text:getWidth(), self.text:getHeight()
	end
	-- first add pixel
	if self.params.pixelcolorup then
		if self.params.isautoscale and self.params.text then
			self.pixel = Pixel.new(
				self.params.pixelcolorup, self.params.pixelalphaup,
				textwidth + self.params.pixelpaddingx,
				textheight + self.params.pixelpaddingy)
		else
			self.pixel = Pixel.new(
				self.params.pixelcolorup, self.params.pixelalphaup,
				self.params.pixelpaddingx,
				self.params.pixelpaddingy)
		end
		self.pixel:setAnchorPoint(0.5, 0.5)
		self.pixel:setScale(self.params.pixelscalexup, self.params.pixelscaleyup)
		self.sprite:addChild(self.pixel)
	end
	-- then images
	if self.params.imgup then
		local texup = Texture.new(self.params.imgup)
		if self.params.isautoscale and self.params.text then
			self.bmpup = Pixel.new(texup,
				textwidth + (self.params.imgpaddingx),
				textheight + (self.params.imgpaddingy))
		else
			self.bmpup = Pixel.new(texup, self.params.imgpaddingx, self.params.imgpaddingy)
		end
		bmps[self.bmpup] = 1
	end
	if self.params.imgdown then
		local texdown = Texture.new(self.params.imgdown)
		if self.params.isautoscale and self.params.text then
			self.bmpdown = Pixel.new(texdown,
				textwidth + (self.params.imgpaddingx),
				textheight + (self.params.imgpaddingy))
		else
			self.bmpdown = Pixel.new(texdown, self.params.imgpaddingx, self.params.imgpaddingy)
		end
		bmps[self.bmpdown] = 2
	end
	if self.params.imgdisabled then
		local texdisabled = Texture.new(self.params.imgdisabled)
		if self.params.isautoscale and self.params.text then
			self.bmpdisabled = Pixel.new(texdisabled,
				textwidth + (self.params.imgpaddingx),
				textheight + (self.params.imgpaddingy))
		else
			self.bmpdisabled = Pixel.new(texdisabled, self.params.imgpaddingx, self.params.imgpaddingy)
		end
		bmps[self.bmpdisabled] = 3
	end
	-- image batch
	for k, _ in pairs(bmps) do
		k:setAnchorPoint(0.5, 0.5)
		k:setAlpha(self.params.imgalphaup)
		local split = 9 -- magik number
		k:setNinePatch(math.floor(k:getWidth()/split), math.floor(k:getWidth()/split),
			math.floor(k:getHeight()/split), math.floor(k:getHeight()/split))
		self.sprite:addChild(k)
	end
	-- finally add text on top of all
	if self.params.text then self.sprite:addChild(self.text) end
	-- and the tooltip text
	if self.params.tooltiptext then
		self.tooltiptext = TextField.new(self.params.tooltipttf, self.params.tooltiptext, self.params.tooltiptext)
		self.tooltiptext:setScale(self.params.tooltiptextscale)
		self.tooltiptext:setTextColor(self.params.tooltiptextcolor)
		self.tooltiptext:setVisible(false)
		self:addChild(self.tooltiptext)
	end
end

-- isdisabled
function ButtonMonster:setDisabled(xdisabled)
	if self.isdisabled == xdisabled then return end
	self.isdisabled = xdisabled
	self:updateVisualState()
end
function ButtonMonster:isDisabled() return self.isdisabled end

-- VISUAL STATE
function ButtonMonster:updateVisualState()
	if self.btns then -- navigatable buttons
		for k, v in ipairs(self.btns) do
			if v.isdisabled then -- button is isdisabled
				if v.params.imgup ~= nil then v.bmpup:setVisible(false) end
				if v.params.imgdown ~= nil then v.bmpdown:setVisible(false) end
				if v.params.imgdisabled ~= nil then v.bmpdisabled:setVisible(true) end
				if v.params.pixelcolordisabled ~= nil then v.pixel:setColor(v.params.pixelcolordisabled) end
				if v.params.text ~= nil then v.text:setTextColor(v.params.textcolordisabled) end
			elseif v.selector == v:getParent().selector then -- button is focused (down state)
				if v.params.hover then -- can hover option
					if v.params.btnscalexdown ~= nil then v:setScale(v.params.btnscalexdown, v.params.btnscaleydown) end
					if v.params.imgup ~= nil then v.bmpup:setVisible(false) end
					if v.params.imgdown ~= nil then v.bmpdown:setVisible(true) end
					if v.params.imgdisabled ~= nil then v.bmpdisabled:setVisible(false) end
					if v.params.pixelcolordown ~= nil then v.pixel:setColor(v.params.pixelcolordown, v.params.pixelalphadown) v.pixel:setScale(v.params.pixelscalexdown, v.params.pixelscaleydown) end
					if v.params.text ~= nil then v.text:setTextColor(v.params.textcolordown) v.text:setScale(v.params.textscalexdown, v.params.textscaleydown) end
				end
			else -- button is not focused (up state)
				if v.params.btnscalexup ~= nil then v:setScale(v.params.btnscalexup, v.params.btnscaleyup) end
				if v.params.imgup ~= nil then v.bmpup:setVisible(true) end
				if v.params.imgdown ~= nil then v.bmpdown:setVisible(false) end
				if v.params.imgdisabled ~= nil then v.bmpdisabled:setVisible(false) end
				if v.params.pixelcolorup ~= nil then v.pixel:setColor(v.params.pixelcolorup, v.params.pixelalphaup) v.pixel:setScale(v.params.pixelscalexup, v.params.pixelscaleyup) end
				if v.params.text ~= nil then v.text:setTextColor(v.params.textcolorup) v.text:setScale(v.params.textscalexup, v.params.textscaleyup) end
			end
			-- tool tip
--			if v.params.tooltiptext and not v.isdisabled then -- OPTION 1: hides tooltip when button is disabled
			if v.params.tooltiptext then -- OPTION 2: shows tooltip even if button is disabled
				if v.selector == v:getParent().selector then -- button is focused
					if v.isdisabled then v.tooltiptext:setText("("..v.params.tooltiptext..")")
					else v.tooltiptext:setText(v.params.tooltiptext)
					end v.tooltiptext:setVisible(true)
				else -- button is not focused
					v.tooltiptext:setVisible(false)
				end
				if v.iskeyboard then -- reposition the tooltip when keyboard navigating
					v.tooltiptext:setPosition(
						v:getParent():getX() + v.params.tooltipoffsetx,
						v:getParent():getY() + v.params.tooltipoffsety
					)
				end
			end
		end
	else -- non navigatable buttons
		if self.isdisabled then -- button is disabled
			if self.params.imgup ~= nil then self.bmpup:setVisible(false) end
			if self.params.imgdown ~= nil then self.bmpdown:setVisible(false) end
			if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(true) end
			if self.params.pixelcolordisabled ~= nil then self.pixel:setColor(self.params.pixelcolordisabled) end
			if self.params.text ~= nil then self.text:setTextColor(self.params.textcolordisabled) end
		elseif self.ishovered then -- button is focused (down state)
			if self.params.btnscalexdown ~= nil then self:setScale(self.params.btnscalexdown, self.params.btnscaleydown) end
			if self.params.imgup ~= nil then self.bmpup:setVisible(false) end
			if self.params.imgdown ~= nil then self.bmpdown:setVisible(true) end
			if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(false) end
			if self.params.pixelcolordown ~= nil then self.pixel:setColor(self.params.pixelcolordown, self.params.pixelalphadown) self.pixel:setScale(self.params.pixelscalexdown, self.params.pixelscaleydown) end
			if self.params.text ~= nil then self.text:setTextColor(self.params.textcolordown) self.text:setScale(self.params.textscalexdown, self.params.textscaleydown) end
		else -- button is not focused (up state)
			if self.params.btnscalexup ~= nil then self:setScale(self.params.btnscalexup, self.params.btnscaleyup) end
			if self.params.imgup ~= nil then self.bmpup:setVisible(true) end
			if self.params.imgdown ~= nil then self.bmpdown:setVisible(false) end
			if self.params.imgdisabled ~= nil then self.bmpdisabled:setVisible(false) end
			if self.params.pixelcolorup ~= nil then self.pixel:setColor(self.params.pixelcolorup, self.params.pixelalphaup) self.pixel:setScale(self.params.pixelscalexup, self.params.pixelscaleyup) end
			if self.params.text ~= nil then self.text:setTextColor(self.params.textcolorup) self.text:setScale(self.params.textscalexup, self.params.textscaleyup) end
		end

--		if self.params.tooltiptext and not self.isdisabled then -- OPTION 1: hides tooltip when button is disabled
		if self.params.tooltiptext then -- OPTION 2: shows tooltip even if button is disabled
			if self.ishovered then -- button is focused
				if self.isdisabled then self.tooltiptext:setText("("..self.params.tooltiptext..")")
				else self.tooltiptext:setText(self.params.tooltiptext)
				end self.tooltiptext:setVisible(true)
			else -- button is not focused
				self.tooltiptext:setVisible(false)
			end
			if self.iskeyboard then -- reposition the tooltip when keyboard navigating
				self.tooltiptext:setPosition(
					self:getParent():getX() + self.params.tooltipoffsetx,
					self:getParent():getY() + self.params.tooltipoffsety
				)
			end
		end
	end
end

-- MOUSE LISTENERS
function ButtonMonster:onMouseDown(e)
--	if self.sprite:hitTestPoint(e.x, e.y, true) then -- XXX use this code when hitTestPoint bug is fixed!
	if self.sprite:hitTestPoint(e.x, e.y) and self:getParent():isVisible() then -- XXX
		self.isclicked = true
		if self.selector then self:getParent().selector = self.selector end -- update the parent id selector
		if self.params.fun then self.params.fun(self:getParent()) end -- YOU CAN ADD THIS HERE
		e:stopPropagation()
	end
	self:updateVisualState()
end
function ButtonMonster:onMouseMove(e)
--	if self.sprite:hitTestPoint(e.x, e.y, true) then -- XXX use this code when hitTestPoint bug is fixed!
	if self.sprite:hitTestPoint(e.x, e.y) and self:getParent():isVisible() then -- XXX
		self.isclicked = true
		if self.selector then self:getParent().selector = self.selector end -- update the parent id selector
		-- this bit prevents sound or function to repeat itself
		self.onenter = not self.onenter
		if not self.onenter then self.ismoving = true end
		if not self.ismoving then
			if self.params.channel ~= nil and self.params.sound ~= nil then self:selectionSfx() end
			if self.params.fun then self.params.fun(self:getParent()) end -- OR HERE?
		end
		e:stopPropagation()
	else
		self.isclicked = false
		self.onenter = false
		self.ismoving = false
	end
	self:updateVisualState()
end
function ButtonMonster:onMouseUp(e)
	if self.isclicked then
		self.isclicked = false
		if not self.isdisabled then self:dispatchEvent(Event.new("clicked")) end
		if self.params.fun then self.params.fun(self:getParent()) end -- OR EVEN HERE?
		e:stopPropagation()
	end
end
function ButtonMonster:onMouseHover(e)
--	if self.sprite:hitTestPoint(e.x, e.y, true) then -- XXX use this code when hitTestPoint bug is fixed!
	if self.sprite:hitTestPoint(e.x, e.y) and self.sprite:isVisible() then -- XXX
		if self.params.tooltiptext then
			self.tooltiptext:setPosition(
				self.sprite:globalToLocal(e.x + self.params.tooltipoffsetx, e.y + self.params.tooltipoffsety)
			)
		end
		self.ishovered = true
		if self.selector then self:getParent().selector = self.selector end -- update parent id selector
		-- this bit prevents sound or function to repeat itself
		self.onenter = not self.onenter
		if not self.onenter then self.ismoving = true end
		if not self.ismoving then
			if self.params.channel ~= nil and self.params.sound ~= nil then self:selectionSfx() end
			if self.params.fun then self.params.fun(self:getParent()) end -- HERE COULD ALSO BE USEFUL?
		end
		self:updateVisualState() -- here will save some frames but won't update everything!
		e:stopPropagation()
	else
		self.ishovered = false
		self.iskeyboard = false
		self.onenter = false
		self.ismoving = false
	end
--	self:updateVisualState() -- here will use more frames but will update everything! you decide :-)
end

-- audio
function ButtonMonster:selectionSfx()
	-- mouse ui buttons sound fx
	if not self.params.channel:isPlaying() then self.params.channel = self.params.sound:play() end
end
