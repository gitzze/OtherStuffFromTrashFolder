--x mark return after torrent

require("libs.Utils")

function Tick(tick)

	if not client.connected or client.loading or client.console or not SleepCheck() then return end
	
	local me = entityList:GetMyHero() if not me then return end
	
	if me.name ~= "npc_dota_hero_kunkka" then
		script:Disable()
	else		
		local q_ = me:GetAbility(1)
		local e_ = me:GetAbility(3)	
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = (5-me.team),illusion=false})
		if e_.name == "kunkka_return" and q_.cd ~= 0 and me:CanCast() then
			if math.floor(q_.cd*10) == 110 + math.floor((client.latency/100)) then
				entityList:GetMyPlayer():UseAbility(e_)
				Sleep(1000)
			end
		end
	end
	
end

script:RegisterEvent(EVENT_TICK,Tick)
