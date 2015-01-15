require("libs.Utils")

local gsm = false
local play = false

function AutoMidas(tick)

	if not client.connected or client.loading or client.console or not SleepCheck() then
		return 
	end

	local me = entityList:GetMyHero()	
	
	if not me then return end
	
	local midas = FindMidas(me)
	
	if midas then
	
		local owner = FindOwner(midas)
		
		if not owner:IsChanneling() and not owner:IsInvisible()  then
			if midas and midas:CanBeCasted() and owner:CanUseItems() then
				if not gsm then
					local name = GetOwnerName(owner)
					GenerateSideMessage(name)
					gsm = true
				end
				local creeps = entityList:GetEntities(function (v) return v.type == LuaEntity.TYPE_CREEP and v.team ~= owner.team and v.alive and v.visible and v.spawned and not v.ancient and v.health > 0 and v.attackRange < 650 and v:GetDistance2D(owner) < midas.castRange + 25 end)
				if #creeps ~= 0 then
					table.sort(creeps, function (a,b) return a.health > b.health end )
					local prev = SelectUnit(owner)
					entityList:GetMyPlayer():UseAbility(midas,creeps[1])
					SelectBack(prev)
				end
			elseif gsm then
				gsm = false
			end
		end
		
	end
	
	Sleep(500)

end

function GetOwnerName(entity)
	if entity.type == LuaEntity.TYPE_HERO then
		return entity.name:gsub("npc_dota_hero_","")
	else
		return "spirit_bear"
	end
end

function FindMidas(entity)
	if entity.classId == CDOTA_Unit_Hero_LoneDruid then
		local heroMidas = entity:FindItem("item_hand_of_midas")
		if heroMidas then
			return heroMidas
		else
			local bear = entityList:FindEntities({classId=CDOTA_Unit_SpiritBear,alive=true,controllable = true})[1]
			if bear then
				local bearMidas = bear:FindItem("item_hand_of_midas")
				if bearMidas then
					return bearMidas
				end
			end
		end
	else
		local heroMidas = entity:FindItem("item_hand_of_midas")
		if heroMidas then
			return heroMidas
		end
	end
	return nil
end

function FindOwner(item)
	if item then
		return item.owner
	end
	return nil
end

function GenerateSideMessage(heroName)
	local test = sideMessage:CreateMessage(200,60)
	test:AddElement(drawMgr:CreateRect(10,10,72,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
	test:AddElement(drawMgr:CreateRect(85,16,62,31,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/arrow_usual")))
	test:AddElement(drawMgr:CreateRect(145,11,70,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/items/hand_of_midas")))
end	

function Load()
	if PlayingGame() then
		play = true
		script:RegisterEvent(EVENT_TICK,AutoMidas)
		script:UnregisterEvent(Load)
	end
end

function GameClose()
	if play then
		script:UnregisterEvent(AutoMidas)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)