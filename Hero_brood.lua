require("libs.Utils")

local eff = {}
local pic = {}

function Tick(tick)

    if not (IsIngame() or SleepCheck()) then return end

	local me = entityList:GetMyHero() 
	if not me then return end

	if me.classId ~= CDOTA_Unit_Hero_Broodmother then
		script:Disable()
	else
		local web = entityList:GetEntities({classId = CDOTA_Unit_Broodmother_Web,team = me.team})
		for _,v in ipairs(web) do
			if not eff[v.handle] then					
				eff[v.handle] = Effect(v,"range_display")
				eff[v.handle]:SetVector(1,Vector(900,0,0))
				pic[v.handle] = drawMgr:CreateRect(0,0,35,35,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/translucent/broodmother_spin_web_t50"))
				pic[v.handle].entity = v pic[v.handle].entityPosition = Vector(0,0,200)	
			end
		end
		Sleep(1000)
	end	
	
end

function GameClose()
	eff = {}
	pic = {}
end

script:RegisterEvent(EVENT_TICK, Tick)
script:RegisterEvent(EVENT_CLOSE,GameClose)
