Menu = Core.class(Sprite)

function Menu:init()
	-- audio
	self.sound = Sound.new("audio/DM-CGS-16.ogg")
	self.channel = self.sound:play(0, nil, true)
	-- bg color
	application:setBackgroundColor(0x4182F2)
	-- bg image
	local bg = Bitmap.new(Texture.new("gfx/menu/bg.png"))
	bg:setAnchorPoint(0.5, 0.5)
	bg:setPosition(myappwidth/2, myappheight/2)
	bg:setScale(2)
	self:addChild(bg)
	-- app title
	self.mytitle = ButtonBeast.new({
		text="MY\n  APP TITLE", ttf=font00, textcolorup=0xD16A2F,
		hover=0,
	})
	self.mytitle:setPosition(0.65*myappwidth/2, 3.5*myappheight/10)
	self.mytitle:setRotation(-12)
	self:addChild(self.mytitle)
	-- logo
	local logo = ButtonBeast.new({
		scalexup=1, scalexdown=1.1,
		text="my logo (c)", ttf=font10, textcolorup=0x7EF6DD, textcolordown=0xffffff,
	})
	logo:setPosition(0.15*myappwidth/2, 0.97*myappheight)
	self:addChild(logo)
	-- ui buttons
	self.selector = 1
	local pixelcolor = 0x3d2e33 -- shared amongst ui buttons
	local textcolorup = 0x0009B3 -- shared amongst ui buttons
	local textcolordown = 0x45d1ff -- shared amongst ui buttons
	local mybtn = ButtonBeast.new({
		scalexup=1, scalexdown=1.2,
		pixelcolorup=pixelcolor,
		text="    GAME   ", ttf=font01, textcolorup=textcolorup, textcolordown=textcolordown,
		tooltiptext="let's go!", tooltipoffsetx=-2*128,
		channel=self.channel, sound=self.sound,
	}, 1)
	local mybtn02 = ButtonBeast.new({
		scalexup=1, scalexdown=1.2,
		pixelcolorup=pixelcolor,
		text="OPTIONS", ttf=font01, textcolorup=textcolorup, textcolordown=textcolordown,
		tooltiptext="disabled", tooltiptextscale=4, tooltipoffsetx=-2*128,
		channel=self.channel, sound=self.sound,
	}, 2)
	mybtn02:setDisabled(true)
	local mybtn03 = ButtonBeast.new({
		scalexup=1, scalexdown=1.2,
		pixelcolorup=pixelcolor,
		text="    QUIT    ", ttf=font01, textcolorup=textcolorup, textcolordown=textcolordown,
		tooltiptext="you sure?", tooltipoffsetx=-2*128,
		hover=false,
		fun=self.updateUiSfx,
	}, 3)
	local mybtn04 = ButtonBeast.new({
		pixelscalexup=1.2, pixelcolorup=pixelcolor,
		text="OTHER BTN", ttf=font01, textcolorup=textcolorup, textcolordown=textcolordown,
	}, 4)
	local mybtn05 = ButtonBeast.new({
		scalexup=1, scalexdown=1.5,
		pixelcolorup=0xff0000,
		isautoscale=false, imgpaddingx=128,
		imgup="gfx/ui/Cross grey.png",
		text="XXX", ttf=font01, textcolorup=textcolorup, textcolordown=textcolordown,
		tooltiptext="X", tooltipoffsetx=-1*128,
	}, 5)
	-- ui positions
	mybtn:setPosition(1.5*myappwidth/2, 3.5*myappheight/10)
	mybtn02:setPosition(1.5*myappwidth/2, 5*myappheight/10)
	mybtn03:setPosition(1.5*myappwidth/2, 6.5*myappheight/10)
	mybtn04:setPosition(1.5*myappwidth/2, 8*myappheight/10)
	mybtn05:setPosition(0.5*myappwidth/2, 7*myappheight/10)
	-- ui order
	self:addChild(mybtn)
	self:addChild(mybtn02)
	self:addChild(mybtn03)
	self:addChild(mybtn04)
	self:addChild(mybtn05)
	-- a btns table
	self.btns = {}
	self.btns[#self.btns + 1] = mybtn
	self.btns[#self.btns + 1] = mybtn02
	self.btns[#self.btns + 1] = mybtn03
	self.btns[#self.btns + 1] = mybtn04
	self.btns[#self.btns + 1] = mybtn05
	-- ui btns listeners
	for k, v in ipairs(self.btns) do
		v:addEventListener("clicked", function() self:goto() end) -- click event
		v.btns = self.btns -- ui navigation update
	end
	-- let's go!
	self:updateUiVfx()
	-- scene listeners
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- game loop
local timer = 0
function Menu:onEnterFrame(e)
	timer += 1
	-- title fx
	self.mytitle:setRotation(2*math.cos(timer/60))
end

-- EVENT LISTENERS
function Menu:onTransitionInBegin() self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function Menu:onTransitionInEnd() self:myKeysPressed() end
function Menu:onTransitionOutBegin() self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function Menu:onTransitionOutEnd() end

-- KEYS HANDLER
function Menu:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		-- for mobiles and desktops
		if e.keyCode == KeyCode.BACK or e.keyCode == KeyCode.ESC then application:exit() end
		-- keyboard
		if e.keyCode == KeyCode.I then
			self.selector -= 1 if self.selector < 1 then self.selector = #self.btns end
			self:updateUiVfx() self:updateUiSfx()
		elseif e.keyCode == KeyCode.K then
			self.selector += 1 if self.selector > #self.btns then self.selector = 1 end
			self:updateUiVfx() self:updateUiSfx()
		end
		if e.keyCode == KeyCode.ENTER then self:goto() end
	end)
end

-- fx
function Menu:updateUiVfx()
	for k, v in ipairs(self.btns) do v.iskeyboard = true v:updateVisualState() end
end
function Menu:updateUiSfx()
	for k, v in ipairs(self.btns) do
		if k == self.selector then self.channel = self.sound:play() end
	end
end

-- scenes ui keyboard navigation
function Menu:goto()
	for k, v in ipairs(self.btns) do
		if k == self.selector then
			if v.isdisabled then print("btn disabled!", k)
			elseif k == 1 then scenemanager:changeScene("levelX", 1, transitions[2], easings[2])
			elseif k == 2 then print(k)
			elseif k == 3 then print(k)
			else print("nothing here!", k)
			end
		end
	end
end
