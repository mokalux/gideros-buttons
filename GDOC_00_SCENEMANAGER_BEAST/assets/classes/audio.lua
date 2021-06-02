--[[
	=============
	Bismillahirahmanirrahim
	Audio control class for Gideros
	by: Edwin Zaniar Putra (zaniar@nightspade.com)
	This code is MIT licensed, see http://www.opensource.org/licenses/mit-license.php
	Copyright � 2012 Nightspade (http://nightspade.com).

	=============
	Audio control class for Gideros

	This class provides:
	* easy way to mute/unmute
	* easy way to manage and play BGM
	* easy way to manage and play SFX

	=============
	Simple example:
	```
	audio = Audio.new()
	audio.setBgms{
		["mainmenu"] = "path/to/mainmenu.mp3",
		["gameplay"] = "path/to/gameplay.mp3",
	}
	audio.setSfx{
		["explosion"] = "path/to/explosion.mp3",
		["ding"] = "path/to/ding.mp3",
	}
	audio:playBgm("mainmenu")
	audio:playSfx("explosion")
	```
]]

Audio = Core.class()

function Audio:init()
	self.bgmChannel = nil self.bgmCurrentName = nil self.bgmCurrent = nil self.bgmPos = 0
	self.bgmMute = false self.sfxMute = false
	self.bgms = {} self.sfxs = {}
end

function Audio:setBgms(bgms) self.bgms = bgms end
function Audio:setSfxs(sfxs) for name, path in pairs(sfxs) do self.sfxs[name] = Sound.new(path) end end

function Audio:clearBgms() self.bgms = {} end
function Audio:clearSfxs() self.sfxs = {} end

function Audio:addBgm(name, path) self.bgms[name] = path end
function Audio:addSfx(name, path) self.sfxs[name] = Sound.new(path) end

function Audio:removeBgm(name) self.bgms[name] = nil end
function Audio:removeSfx(name) self.sfxs[name] = nil end

function Audio:playBgm(name, force)
	if name ~= self.bgmCurrentName or force then
		if self.bgmChannel then
			self.bgmChannel:stop()
			self.bgmChannel = nil
			self.bgmCurrentName = nil
			self.bgmCurrent = nil
			self.bgmPos = 0
		end
		if not self.bgmMute and not self.bgmChannel then
			self.bgmCurrentName = name
			self.bgmCurrent = Sound.new(self.bgms[name])
			self.bgmChannel = self.bgmCurrent:play(self.bgmPos, math.huge)
		end
	end
end
function Audio:playSfx(name) if not self.sfxMute then return self.sfxs[name]:play() end end

function Audio:muteBgm()
	self.bgmMute = true
	if self.bgmChannel then
		self.bgmPos = self.bgmChannel:getPosition()
		self.bgmChannel:stop()
		self.bgmChannel = nil
	end
end
function Audio:muteSfx() self.sfxMute = true end

function Audio:unmuteBgm()
	self.bgmMute = false
	self.bgmChannel = self.bgmCurrent:play(self.bgmPos, math.huge)
end
function Audio:unmuteSfx() self.sfxMute = false end
