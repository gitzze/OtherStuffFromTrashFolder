--use abilities to target under the cursor
require("libs.Utils")
local re = string.byte("W") -- select bear and return
local sel = string.byte("3") -- select bear + lone
local mjol = string.byte("T") -- fast use mjolnir on bear (i increased the delay, because the hero did it too fast.)

local stage = 0
local sleeptick = 0

function Key()

	if not client.connected or client.loading or client.console or client.chat then return end

	local me = entityList:GetMyHero()	
	
	if not me then return end

	if me.classId ~= CDOTA_Unit_Hero_LoneDruid then
		script:Disable()
	else
		local bear = entityList:GetEntities({classId=CDOTA_Unit_SpiritBear,alive = true,team = me.team})[1]
		local spell = me:GetAbility(1).level
		local player = entityList:GetMyPlayer()
		
		if bear then
			if IsKeyDown(re) then				
				if spell > 1 and bear:GetAbility(1).state == -1 then
					player:Select(bear)
					player:UseAbility(bear:GetAbility(1))
					player:AttackMove(me.position,true)
					player:Select(me)
				end
			elseif IsKeyDown(sel) then
				player:Select(me)
				player:SelectAdd(bear)
			elseif IsKeyDown(mjol) then
				script:RegisterEvent(EVENT_TICK,Tick)
			end
		end
	end

end

function Tick(tick)

	if tick < sleeptick then return end
	sleeptick = tick + 200	
	local me = entityList:GetMyHero()
	local player = entityList:GetMyPlayer()
	local bear = entityList:GetEntities({classId=CDOTA_Unit_SpiritBear,alive = true,team = me.team})[1]
	local phys = entityList:GetEntities(function (mj) return mj.type==LuaEntity.TYPE_ITEM_PHYSICAL and mj.itemHolds.name== "item_mjollnir" end)[1]	
	local mjollnirB = bear:FindItem("item_mjollnir")
	local mjollnirM = me:FindItem("item_mjollnir")
	if mjollnirB and stage == 0 then
		player:Select(bear)
		player:UseAbility(bear:GetAbility(1),true)
		if GetDistance2D(me,bear) < 100 then
			player:DropItem(mjollnirB,me.position)
			player:Select(me)
			stage = 1
			sleeptick = tick + 500	
			return
		end
	end
	if stage == 1 then
		if phys~=nil then
			player:TakeItem(phys)
		end
		if mjollnirM then
			player:UseAbility(mjollnirM,bear)
			if bear:DoesHaveModifier("modifier_item_mjollnir_static") then
				player:DropItem(mjollnirM,me.position)
				player:Select(bear)
				stage = 2
				sleeptick = tick + 500
				return
			end
		end
	end
	if stage == 2 and phys~=nil then
		player:Select(bear)
		player:TakeItem(phys)
		stage = 0
		script:UnregisterEvent(Tick)	
	end	
end

script:RegisterEvent(EVENT_KEY,Key)
