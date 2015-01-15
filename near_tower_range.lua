local eff = {}
local play = false

function Tick(tick)

	if not SleepCheck() then return end

	local me = entityList:GetMyHero()	
	local towers = entityList:FindEntities({classId=CDOTA_BaseNPC_Tower,alive=true})
	
	local clear = false
	
	for i,v in ipairs(towers) do
		if GetDistance2D(me,v) < 1400 then
			if not eff[v.handle] then
				eff[v.handle] = Effect(v,"range_display")
				eff[v.handle]:SetVector( 1, Vector(850,0,0) )
			end
		elseif eff[v.handle] then
			eff[v.handle] = nil
			clear = true
		end
	end
	
	if clear then
		collectgarbage("collect")
	end
	
	Sleep(1000)
end

function Load()
	if PlayingGame() then
		play = true
		script:RegisterEvent(EVENT_TICK,Tick)
		script:UnregisterEvent(Load)
	end
end

function GameClose()
	if play then
		eff = {}
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
		collectgarbage("collect")
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)