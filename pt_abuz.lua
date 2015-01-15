require("libs.Utils")

local itemKey = {"4"," ","J","3","X","C"}
local spellKey = {"R","E","W","F","T","Q"}
local noKey = "P"
local stopKey = "D"

function Tick(tick)

	if not client.connected or client.loading or client.console or not SleepCheck() then return end	
	
	local me = entityList:GetMyHero() if not me then return end

	if not key then	script:RegisterEvent(EVENT_KEY,Key)	key = true	end
	
	if not list then
		local ability = me.abilities
		if #ability > 4 and #ability < 6 then
			list = {spellKey[1],spellKey[2],spellKey[3],spellKey[6]}
		elseif #ability == 6 then
			list = {spellKey[1],spellKey[2],spellKey[3],spellKey[4],spellKey[6]}
		elseif #ability > 6 and #ability < 10 then
			list = {spellKey[1],spellKey[2],spellKey[3],spellKey[4],spellKey[5],spellKey[6]}
		else
			list = {noKey,noKey,noKey,spellKey[4],spellKey[5],spellKey[6]}
		end
	end
	
	local pt = me:FindItem("item_power_treads")
	
	if pt then
		local bottle = me:FindModifier("modifier_bottle_regeneration")
		if bottle then
			if not StateSave then
				StateSave = pt.bootsState
			end
			UsePT(pt,me,2)
		elseif StateSave then
			if not sleep  or (sleep and me:GetAbility(sleep).cd ~= 0) then
				if not me:IsChanneling() and not me.invisible then
					UsePT(pt,me,StateSave)
					sleep = nil			
					StateSave = nil
				end
			end
		end		
		if StickSave and StickTick < tick then
			UsePT(pt,me,StickSave)
			StickSave = nil
			StickTick = nil
		end
	end
	
	Sleep(200)

end

function Key(msg)

	if client.chat or msg == KEY_UP then return end

	local me = entityList:GetMyHero()	
	local player = entityList:GetMyPlayer()
	local pt = me:FindItem("item_power_treads")

	if pt then
		if entityList:GetMyPlayer().selection[1].handle == me.handle then
			for i,v in ipairs(itemKey) do
				if IsKeyDown(string.byte(v)) then					
					local item = me:GetItem(i)
					if item and item.name == "item_magic_wand" or item.name == "item_magic_stick" then
						if item.cd == 0 and item.charges > 0 then
							if not StickSave then
								StickSave = pt.bootsState
								StickTick = GetTick() + client.latency + 50
							end
							UsePT(pt,me,2)
							player:UseAbility(item)		
							return true
						end
					end
				end
			end
			for i,v in ipairs(list) do
				if IsKeyDown(string.byte(v)) then	
					kode = v
					local Spell = me:GetAbility(i)				
					if Spell.manacost > 0 and Spell:CanBeCasted() and Spell:CanBeCasted() then					
						sleep = i
						if not StateSave then
							StateSave = pt.bootsState
						end
						if Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) then
							local target = entityList:GetMouseover()
							if target then
								UsePT(pt,me,1)
								player:UseAbility(Spell,target)
								return true
							end
						end
						if Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
							UsePT(pt,me,1)
							player:UseAbility(Spell)
							return true
						elseif Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) then
							UsePT(pt,me,1)
							player:UseAbility(Spell,client.mousePosition)
							return true
						else
							StateSave = nil
						end					
					end				
				end
			end
			if IsKeyDown(string.byte(stopKey)) then
				player:HoldPosition()
				if StateSave then
					UsePT(pt,me,StateSave)
					sleep = nil			
					StateSave = nil
				end
				return true
			end
		end
	end

end

function UsePT(pt,me,state)
	if pt.bootsState ~= state then
		local prev = SelectUnit(me)
		for i = 1, (state - pt.bootsState) % 3 do
			entityList:GetMyPlayer():UseAbility(pt)				
		end
		SelectBack(prev)
	end
end

function GameClose()
	list = nil
	sleep = nil			
	StateSave = nil
	StickSave = nil
	StickTick = nil
	if key then
		script:UnregisterEvent(Key)
		key = false
	end
end

script:RegisterEvent(EVENT_CLOSE, GameClose)
script:RegisterEvent(EVENT_TICK,Tick)
