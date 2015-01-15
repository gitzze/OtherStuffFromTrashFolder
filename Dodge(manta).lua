require("libs.Utils")

local Modif = {"modifier_lion_finger_of_death","modifier_lina_laguna_blade"}
local Cast = {"sniper_assassinate","lich_chain_frost"}

function Tick(tick)

	if not client.connected or client.loading or client.console then return end

	local me = entityList:GetMyHero()

	if not me then return end
	
	local item = me:FindItem("item_manta")
	
	if item and item:CanBeCasted() and me:CanUseItems() then
		
		for i,v in ipairs(Modif) do			
			local modifier = me:FindModifier(v)		
			if modifier and modifier.remainingTime - client.latency/1000 < 0 then
				me:CastAbility(item)				
			end
		end
		local projectiles = entityList:GetProjectiles({target=me})	
		for i,v in ipairs(projectiles) do
			for z,x in ipairs(Cast) do
				if v.name == x then
					local timing = GetDistance2D(me,v.position)/v.speed - client.latency/1000
					if timing < 0.1 then
						me:CastAbility(item)						
					end
				end
			end
		end
		
	end

end
script:RegisterEvent(EVENT_ENTITY_ADD,Tick)
script:RegisterEvent(EVENT_TICK,Tick)
