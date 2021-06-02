GameOver = Core.class(Sprite)

function GameOver:init()
	-- BG
	application:setBackgroundColor(0x3042DB)
	-- LISTENERS
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- GAME LOOP
function GameOver:onEnterFrame(e)
end

-- EVENT LISTENERS
function GameOver:onTransitionInBegin() self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function GameOver:onTransitionInEnd() self:myKeysPressed() end
function GameOver:onTransitionOutBegin() self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function GameOver:onTransitionOutEnd() end

-- KEYS HANDLER
function GameOver:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		-- for mobiles and desktops
		if e.keyCode == KeyCode.BACK or e.keyCode == KeyCode.ESC then
			scenemanager:changeScene("menu", 1, transitions[2], easings[2])
		end
	end)
end
