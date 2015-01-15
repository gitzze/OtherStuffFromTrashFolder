require("libs.Utils")
require("libs.SideMessage")

local key = string.byte("T")
local start = false
local play = false

function Key(msg,code)
	if msg ~= KEY_UP or code ~= key or client.chat then	return end	
	if not start then
		start = true CampBlockSideMessage("Enabled")
		return true
	else
		start = false CampBlockSideMessage("Disabled")
		return true
	end
end

function Tick(tick)
	if client.chat or not SleepCheck() then return end
	Sleep(250)
	local me = entityList:GetMyHero() 	
	if not me then return end
	local gameTime = client.gameTime
	if gameTime > 6600 then
		script:Disable()
	end
	if start then	
		local vector = GetVector(me.team)
		local distance = me:GetDistance2D(vector)
		local time = (gameTime % 60) + distance/1500+client.latency/100+0.3
		if time >= 61 and time <= 62 then
			me:SafeCastSpell("rattletrap_rocket_flare",(vector - me.position) * (distance+1000) / distance + me.position)
			start = false CampBlockSideMessage("Disabled")
		end		
	end	
end

function CampBlockSideMessage(text)
	local test = sideMessage:CreateMessage(200,60)	
	test:AddElement(drawMgr:CreateRect(5,5,80,50,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/spellicons/rattletrap_rocket_flare")))
	test:AddElement(drawMgr:CreateText(90,3,-1,"Spawn blocking",drawMgr:CreateFont("defaultFont","Arial",18,500)) )
	test:AddElement(drawMgr:CreateText(100,25,-1,text,drawMgr:CreateFont("defaultFont","Arial",22,500)) )
end

function GetVector(team)
	if team == LuaEntity.TEAM_DIRE then	
		return Vector(3073, -4505, 256)
	else
		return Vector(-3056,4529,256)
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId == CDOTA_Unit_Hero_Rattletrap then		
			play = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		else
			script:Disable()
		end
	end
end

function GameClose()
	if play then
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)