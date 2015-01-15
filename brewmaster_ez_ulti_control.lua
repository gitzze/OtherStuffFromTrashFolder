--use abilities to target under the cursor
--1-3 earth,storm,fire

require("libs.Utils")

--key config
local play = false
local activated = false
local stun = string.byte("R")
local clap = string.byte("F")
local drink = string.byte("T")
local tornado = string.byte("E")
local dispell = string.byte("W")
local invis = string.byte("Q")
local sufferbitch = string.byte("C")
local all = string.byte(" ")

--other
local hero = {}
local spell = {}
local F12 = drawMgr:CreateFont("F12","Arial",15,500)
local xx = -65
local yy = 50

--Brew
function BrewTick(tick)

	if client.console or not SleepCheck() then return end

	local me = entityList:GetMyHero()	
	
	if not me then return end
	
	if me:DoesHaveModifier("modifier_brewmaster_primal_split") and not me:DoesHaveModifier("modifier_brewmaster_primal_split_delay") then
		if not activated then client:ExecuteCmd("dota_player_units_auto_attack 1") end
		activated = true	
		local splits = entityList:GetEntities(function (ent) return ent.classId == CDOTA_Unit_Brewmaster_PrimalEarth or ent.classId == CDOTA_Unit_Brewmaster_PrimalStorm and ent.controllable end)
		for i,v in ipairs(splits) do			
			local offset = v.healthbarOffset
			if offset == -1 then return end		
			if not hero[v.handle] then hero[v.handle] = {} end
			for a= 1, 4 do
				if not spell[a] then spell[a] = {} end
				if not hero[v.handle].spell then hero[v.handle].spell = {} end									
				if not hero[v.handle].spell[a] then hero[v.handle].spell[a] = {}
					hero[v.handle].spell[a].bg = drawMgr:CreateRect(-65 +a*23,50,20,20,0x00000095) hero[v.handle].spell[a].bg.visible = false hero[v.handle].spell[a].bg.entity = v hero[v.handle].spell[a].bg.entityPosition = Vector(0,0,offset)
					hero[v.handle].spell[a].nl = drawMgr:CreateRect(-65 +a*23-1,50 - 1,22,22,0x00000090,true) hero[v.handle].spell[a].nl.visible = false hero[v.handle].spell[a].nl.entity = v hero[v.handle].spell[a].nl.entityPosition = Vector(0,0,offset)			
					hero[v.handle].spell[a].fon = drawMgr:CreateRect(-65 +a*23-1,50,20,20,0x00000099) hero[v.handle].spell[a].fon.visible = false hero[v.handle].spell[a].fon.entity = v hero[v.handle].spell[a].fon.entityPosition = Vector(0,0,offset)
					hero[v.handle].spell[a].textT = drawMgr:CreateText(-65 +a*23+8,50+2,0xFFFFFFff,"",F12) hero[v.handle].spell[a].textT.visible = false hero[v.handle].spell[a].textT.entity = v hero[v.handle].spell[a].textT.entityPosition = Vector(0,0,offset)
				end				
				local Spell = v:GetAbility(a)				
				if v.alive and Spell ~= nil then
					hero[v.handle].spell[a].bg.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..Spell.name)
					hero[v.handle].spell[a].bg.visible = true
					hero[v.handle].spell[a].nl.visible = true
					if Spell.state == LuaEntityAbility.STATE_READY then
						hero[v.handle].spell[a].textT.visible = false
						hero[v.handle].spell[a].fon.visible = false
					elseif Spell.cd > 0 then
						local cooldown = math.ceil(Spell.cd)
						local shift1 = nil
						if cooldown > 10 then shift1 = -5 else shift1 = 0 end
						hero[v.handle].spell[a].textT.x = -65 +a*23+8 + shift1
						hero[v.handle].spell[a].textT.text = ""..cooldown hero[v.handle].spell[a].textT.visible = true
						hero[v.handle].spell[a].fon.visible = true
					elseif hero[v.handle].spell[a].nl.visible then
						hero[v.handle].spell[a].nl.visible = false
						hero[v.handle].spell[a].textT.visible = false
						hero[v.handle].spell[a].fon.visible = false
					end
				else
					if hero[v.handle].spell[a].bg.visible then
						hero[v.handle].spell[a].bg.visible = false
						hero[v.handle].spell[a].nl.visible = false
						hero[v.handle].spell[a].textT.visible = false
						hero[v.handle].spell[a].fon.visible = false
					end
				end
			end			
		end
	elseif activated then
		client:ExecuteCmd("dota_player_units_auto_attack 0")
		activated = false
	end 
	
	Sleep(250)	
	
end

function BrewKey(msg,code)

	if msg == KEY_UP or client.chat then return end
	
	if activated then
		local target = entityList:GetMouseover()
		local player = entityList:GetMyPlayer()	
		local splits = entityList:GetEntities(function (ent) return ent.classId == CDOTA_Unit_Brewmaster_PrimalEarth or ent.classId == CDOTA_Unit_Brewmaster_PrimalFire or ent.classId == CDOTA_Unit_Brewmaster_PrimalStorm and ent.controllable end)
		for i,v in ipairs(splits) do
			if v.alive and v.health > 0 then
				if code == all then
					player:SelectAdd(v)					
				end				
				if v.classId == CDOTA_Unit_Brewmaster_PrimalEarth then
					if code == stun then
						player:Select(v)
						if target then
							v:CastAbility(v:GetAbility(1),target)
						end
						return true
					elseif code == clap then
						v:CastAbility(v:GetAbility(4))
						return true
					elseif code == string.byte("1") then
						player:Select(v)
						return true
					end
				elseif v.classId == CDOTA_Unit_Brewmaster_PrimalStorm then
					if code == drink then
						if target then
							v:CastAbility(v:GetAbility(4),target)
						end
						return true
					elseif code == tornado then
						if target then
							v:CastAbility(v:GetAbility(2),target)
						end
						return true
					elseif code == dispell then		
						v:CastAbility(v:GetAbility(1),client.mousePosition)
						return true
					elseif code == invis then
						player:Select(v)
						v:CastAbility(v:GetAbility(3))
						return true
					elseif code == string.byte("2") then
						player:Select(v)	
						return true
					end
				elseif v.classId == CDOTA_Unit_Brewmaster_PrimalFire then	
					if code == sufferbitch then
						if target then
							v:Attack(target)
							player:Unselect(v)
						end
					elseif code == string.byte("3") then
						player:Select(v)
						return true
					end
				end
			end
		end
	end
	
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId == CDOTA_Unit_Hero_Brewmaster then			
			play = true
			script:RegisterEvent(EVENT_TICK,BrewTick)
			script:RegisterEvent(EVENT_KEY,BrewKey)
			script:UnregisterEvent(Load)		
		else
			script:Disable()
		end
	end
end

function GameClose()	
	if play then	
		hero = {}
		spell = {}
		activated,play = false,false
		collectgarbage("collect")	
		script:UnregisterEvent(BrewTick)
		script:UnregisterEvent(BrewKey)
		script:RegisterEvent(EVENT_TICK,Load)		
		
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)