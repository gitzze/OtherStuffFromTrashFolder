require("libs.Utils")
require("libs.SideMessage")

local stuff = {}
stuff.play = {}
stuff.activated = false

--Phoenix
stuff.toggle = false
stuff.toggle_1 = false
stuff.text = drawMgr:CreateText(5,0-45, 0xF30E0E99, "P",drawMgr:CreateFont("F14","Calibri",18,500)) stuff.text.visible = false
stuff.angle = 30 -- if the angle between the target and the hero is more then 30* phoenix stops
stuff.distance = 700 -- min distance for move

--Lone
stuff.keyL1 = string.byte("W") -- select bear and return then bear:attack to me.position
stuff.keyL2 = string.byte("3") -- select bear + lone

--Brood
stuff.eff = {}
stuff.pic = {}
stuff.keyB1 = string.byte("T") -- abuz
stuff.stage = 0

--Brew
--key config
stuff.stun = string.byte("R")
stuff.clap = string.byte("F")
stuff.drink = string.byte("T")
stuff.tornado = string.byte("E")
stuff.dispell = string.byte("W")
stuff.invis = string.byte("Q")
stuff.sufferbitch = string.byte("C")
stuff.all = string.byte(" ")
--other
local hero = {}
local spell = {}
stuff.F12 = drawMgr:CreateFont("F12","Arial",15,500)

--Clock
stuff.keyClock = string.byte("T")

--Ember
stuff.keyEmber = string.byte("E")

--Phoenix
function PhoenixTick(tick)

	if client.console or not SleepCheck() then return end

	local me = entityList:GetMyHero()	
	
	if not me then return end
	
	local forward = FindMove(me)
	
	if forward ~= nil then
		if me:DoesHaveModifier("modifier_phoenix_sun_ray") then
			stuff.activated = true
			local target = nil		
			if test then
				target = entityList:GetEntity(test.handle)
			end			
			if target then
				if target.healthbarOffset ~= -1 then
					stuff.text.visible = true stuff.text.entity = target stuff.text.entityPosition = Vector(0,0,target.healthbarOffset)
				end
				if (target.activity == LuaEntityNPC.ACTIVITY_MOVE and ToFace(target,me)) or target:GetDistance2D(me) > stuff.distance or not target.visible then
					if not (forward and stuff.toggle) then
						me:CastAbility(me:GetAbility(4))
						stuff.toggle,stuff.toggle_1 = true,false					
					end
					me:Follow(target)					
				else 
					if forward and not stuff.toggle_1 then
						me:CastAbility(me:GetAbility(4))
						stuff.toggle,stuff.toggle_1 = false,true
					end
					me:Follow(target)
				end
			end
		elseif stuff.activated then
			stuff.activated,stuff.toggle,stuff.toggle_1,stuff.text.visible = false,false,false,false
		end		
	end
	Sleep(250)	
	
end

function PhoenixKey(msg)

	if msg == RBUTTON_DOWN and stuff.activated then		
		test = entityList:GetMouseover()
	elseif not stuff.activated then
		test = nil
	end
	
end

function FindMove(me)
	if not p then 
		a1 = me.position 
		p = true 
	else 
		a2 = me.position
		p = false
	end
	if a1 == a2 then 
		return false
	else
		return true
	end
	return nil
end

function ToFace(my,t_)
	if ((FindAngel(my,t_)) % (2 * math.pi)) * 180 / math.pi >= (360-stuff.angle) or ((FindAngel(my,t_)) % (2 * math.pi)) * 180 / math.pi <= stuff.angle then
		return true
	end
	return false
end

function FindAngel(my,t_)
	return ((math.atan2(my.position.y-t_.position.y,my.position.x-t_.position.x) - t_.rotR + math.pi) % (2 * math.pi)) - math.pi
end


--Lone
function LoneKey(msg,code)

	if msg ~= KEY_UP or client.chat then return end

	local me = entityList:GetMyHero()	
	
	if not me then return end
	
	local bear = entityList:GetEntities({classId=CDOTA_Unit_SpiritBear,alive = true,team = me.team})[1]	
	
	if bear then
		if code == stuff.keyL1 then	
			local spell = me:GetAbility(1).level
			local player = entityList:GetMyPlayer()
			if spell > 1 and bear:GetAbility(1).state == -1 then
				player:Select(bear)
				player:UseAbility(bear:GetAbility(1))
				player:AttackMove(me.position,true)
				player:Select(me)
				return true
			end
		elseif code == stuff.keyL2 then
			client:ExecuteCmd("dota_select_all")
			return true
		end
	end

end


--Brood
function BroodTick(tick)

    if client.conlose or not SleepCheck() then return end
	
	local me = entityList:GetMyHero() 
	if not me then return end

	local web = entityList:GetEntities({classId = CDOTA_Unit_Broodmother_Web,team = me.team})
	for _,v in ipairs(web) do
		if not stuff.eff[v.handle] then					
			stuff.eff[v.handle] = Effect(v,"range_display")
			stuff.eff[v.handle]:SetVector(1,Vector(900,0,0))
			stuff.pic[v.handle] = drawMgr:CreateRect(0,0,35,35,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/translucent/broodmother_spin_web_t50"))
			stuff.pic[v.handle].entity = v stuff.pic[v.handle].entityPosition = Vector(0,0,200)	
		end
	end
	
	Sleep(1000)		
	
end

function BroodKey(msg,code)
	if stuff.stage == 2 or code ~= stuff.keyB1 or client.chat then return end
	local me = entityList:GetMyHero() 
	if not me then return end
	local pl = entityList:GetMyPlayer()
	local rob = me:FindItem("item_ring_of_basilius")
	if rob and stuff.stage == 0 then
		local player = entityList:GetEntities({classId=CDOTA_PlayerResource})[1]		
		local gold = player:GetGold(me.playerId)
		if gold > 350 then
			pl:Select(me)
			pl:DisassembleItem(rob)
			pl:BuyItem(27)
			stuff.stage = 1
		end
	elseif stuff.stage == 1 and not rob then
		local rb = entityList:GetEntities(function (v) return v.type == LuaEntity.TYPE_ITEM_PHYSICAL and v.itemHolds.name == "item_sobi_mask" end)[1]
		local rp = entityList:GetEntities(function (v) return v.type == LuaEntity.TYPE_ITEM_PHYSICAL and v.itemHolds.name == "item_ring_of_protection" end )[1]
		if rb then
			pl:TakeItem(rb)
			pl:TakeItem(rp,true)
			stuff.stage = 2
		end
	end
end


--Brew
function BrewTick(tick)

	if client.console or not SleepCheck() then return end

	local me = entityList:GetMyHero()	
	
	if not me then return end
	
	if me:DoesHaveModifier("modifier_brewmaster_primal_split") and not me:DoesHaveModifier("modifier_brewmaster_primal_split_delay") then
		if not stuff.activated then client:ExecuteCmd("dota_player_units_auto_attack 1") end
		stuff.activated = true	
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
					hero[v.handle].spell[a].textT = drawMgr:CreateText(-65 +a*23+8,50+2,0xFFFFFFff,"",stuff.F12) hero[v.handle].spell[a].textT.visible = false hero[v.handle].spell[a].textT.entity = v hero[v.handle].spell[a].textT.entityPosition = Vector(0,0,offset)
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
	elseif stuff.activated then
		client:ExecuteCmd("dota_player_units_auto_attack 0")
		stuff.activated = false
	end 
	
	Sleep(250)	
	
end

function BrewKey(msg,code)

	if msg == KEY_UP or client.chat then return end
	
	if stuff.activated then
		local target = entityList:GetMouseover()
		local player = entityList:GetMyPlayer()	
		local splits = entityList:GetEntities(function (ent) return ent.classId == CDOTA_Unit_Brewmaster_PrimalEarth or ent.classId == CDOTA_Unit_Brewmaster_PrimalFire or ent.classId == CDOTA_Unit_Brewmaster_PrimalStorm and ent.controllable end)
		for i,v in ipairs(splits) do
			if v.alive and v.health > 0 then
				if code == stuff.all then
					player:SelectAdd(v)					
				end				
				if v.classId == CDOTA_Unit_Brewmaster_PrimalEarth then
					if code == stuff.stun then
						player:Select(v)
						if target then
							v:CastAbility(v:GetAbility(1),target)
						end
						return true
					elseif code == stuff.clap then
						v:CastAbility(v:GetAbility(4))
						return true
					elseif code == string.byte("1") then
						player:Select(v)
						return true
					end
				elseif v.classId == CDOTA_Unit_Brewmaster_PrimalStorm then
					if code == stuff.drink then
						if target then
							v:CastAbility(v:GetAbility(4),target)
						end
						return true
					elseif code == stuff.tornado then
						if target then
							v:CastAbility(v:GetAbility(2),target)
						end
						return true
					elseif code == stuff.dispell then		
						v:CastAbility(v:GetAbility(1),client.mousePosition)
						return true
					elseif code == stuff.invis then
						player:Select(v)
						v:CastAbility(v:GetAbility(3))
						return true
					elseif code == string.byte("2") then
						player:Select(v)	
						return true
					end
				elseif v.classId == CDOTA_Unit_Brewmaster_PrimalFire then	
					if code == stuff.sufferbitch then
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


--Clock
function ClockTick(tick)
	if client.chat or not SleepCheck() then return end
	Sleep(250)
	local me = entityList:GetMyHero() 	
	if not me then return end
	local gameTime = client.gameTime
	if gameTime > 600 then
		script:Disable()
	end
	if stuff.activated then	
		local vector = GetVector(me.team)
		local dist = me:GetDistance2D(vector)
		local time = (gameTime % 60) + dist/1500+client.latency/100+0.3
		if time >= 61 and time <= 62 then
			me:SafeCastSpell("rattletrap_rocket_flare",(vector - me.position) * (dist+1000) / dist + me.position)
			stuff.activated = false CampBlockSideMessage("Disabled")
		end		
	end	
end

function ClockKey(msg,code)
	if msg ~= KEY_UP or code ~= stuff.keyClock or client.chat then return end	
	if not stuff.activated then
		stuff.activated = true CampBlockSideMessage("Enabled")
		return true
	else
		stuff.activated = false CampBlockSideMessage("Disabled")
		return true
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


--Ember

function EmberKey(msg,code)

	if msg == KEY_DOWN and not client.chat and code == stuff.keyEmber then
		stuff.activated = true
	else
		stuff.activated = false
	end

end

function EmberTick(tick)

	if not stuff.activated or not SleepCheck() then return end

	local me = entityList:GetMyHero()

	local enemy = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive = true,team = (5-me.team),illusion = false})
	local w_ = me:GetAbility(1)
	if w_.state == -1 and me:DoesHaveModifier("modifier_ember_spirit_sleight_of_fist_caster") then
		for i,v in ipairs(enemy) do
			if v.health > 0 and not v:IsMagicDmgImmune() and me:GetDistance2D(v) < 400 then
				me:CastAbility(w_)
				stuff.activated = false
				Sleep(1000)
			end
		end
	end			

end



--Venomancer
function VenoTick(tick)

	if client.console or not SleepCheck() then return end

	local me = entityList:GetMyHero()   
	if not me then return end 
	
	Sleep(125)
	
	local ward = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard,alive = true,visible = true,controllable=true})
	

	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,visible = true, alive = true, team = me:GetEnemyTeam(),illusion=false})
	for i,v in ipairs(enemies) do
		if not v:DoesHaveModifier("modifier_venomancer_poison_sting_ward") and v.health > 0 then
			for l,k in ipairs(ward) do
				if GetDistance2D(v,k) < k.attackRange and SleepCheck(k.handle) then						
					k:Attack(v)
					Sleep(1000,k.handle)
					break
				end
			end
		end
	end

	
end

--Axe
function AxeKey(msg,code)
	if msg ~= KEY_UP or client.chat then return end
	if code == string.byte("W") then
		local me = entityList:GetMyHero()
		DropItems(me)
		UpItems(me)
	end
end

function DropItems(im)
	for i,v in ipairs(im.items) do	
		if v.name == "item_tranquil_boots" then
			entityList:GetMyPlayer():DropItem(v,im.position)
		end		
	end
end

function UpItems(im)
	local DownItems = entityList:FindEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})
	for i,v in ipairs(DownItems) do
		if v.itemHolds.name == "item_tranquil_boots" then
			entityList:GetMyPlayer():TakeItem(v)
		end
	end
end


--TuskKey
function TuskKey(msg,code)
	if msg ~= KEY_UP or client.chat then return end
	if code == string.byte("1") then
		local me = entityList:GetMyHero()
		local sigil = entityList:GetEntities({classId=CDOTA_BaseNPC_Tusk_Sigil,alive = true,controllable=true,team=me.team})[1]
		if sigil then
			entityList:GetMyPlayer():Select(sigil)
			return true
		end
	end
end

function JugKey(msg,code)
	if msg ~= KEY_UP or client.chat then return end
	if code == string.byte("1") then
		local me = entityList:GetMyHero()
		local sigil = entityList:GetEntities({classId=297,alive = true,team=me.team})[1]
		if sigil then
			entityList:GetMyPlayer():Select(sigil)
			return true
		end
	end
end

function BeastKey(msg,code)
	if msg ~= KEY_UP or client.chat then return end
	if code == string.byte("1") then
		client:ExecuteCmd("dota_select_all_others")
		local player = entityList:GetMyPlayer()
		for i,v in ipairs(player.selection) do
			if v.classid == CDOTA_Unit_Hero_Beastmaster_Hawk then
				player:Unselect(v)
			end
		end		
		--[[local me = entityList:GetMyHero()
		local boar = entityList:GetEntities({classId=CDOTA_Unit_Hero_Beastmaster_Boar,alive = true,team=me.team})
		if #boar ~= 0 then
			if #boar == 2 then
				entityList:GetMyPlayer():Select(boar[1])
				entityList:GetMyPlayer():SelectAdd(boar[2])				
			else
				entityList:GetMyPlayer():Select(boar[1])
			end
			return true
		end]]
		return true
	elseif code == string.byte("3") then
		local me = entityList:GetMyHero()
		local hawk = entityList:GetEntities({classId=CDOTA_Unit_Hero_Beastmaster_Hawk,alive = true,team = me.team})
		table.sort( hawk, function (a,b) return GetDistance2D(me,a) < GetDistance2D(me,b) end )
		if hawk[1] then
			entityList:GetMyPlayer():Select(hawk[1])
			return true
		end
	end
end

function LCKey(msg,code)
	if msg ~= KEY_UP or client.chat then return end
	if code == string.byte("W") then
		local me = entityList:GetMyHero()
		local bm = me:FindItem("item_blade_mail")
		local ms = me:FindItem("item_mjollnir")
		if bm then
			me:CastAbility(bm)
		end
		if ms then
			me:CastAbility(ms)
		end
		return true
	end
end
	


function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId == CDOTA_Unit_Hero_Phoenix then			
			stuff.play[1] = true
			script:RegisterEvent(EVENT_TICK,PhoenixTick)
			script:RegisterEvent(EVENT_KEY,PhoenixKey)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_LoneDruid then			
			stuff.play[2] = true
			script:RegisterEvent(EVENT_KEY,LoneKey)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_Broodmother then			
			stuff.play[3] = true
			script:RegisterEvent(EVENT_TICK,BroodTick)
			script:RegisterEvent(EVENT_KEY,BroodKey)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_Brewmaster then			
			stuff.play[4] = true
			script:RegisterEvent(EVENT_TICK,BrewTick)
			script:RegisterEvent(EVENT_KEY,BrewKey)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_Rattletrap then			
			stuff.play[5] = true
			script:RegisterEvent(EVENT_TICK,ClockTick)
			script:RegisterEvent(EVENT_KEY,ClockKey)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_EmberSpirit then			
			stuff.play[6] = true
			script:RegisterEvent(EVENT_KEY,EmberKey)
			script:RegisterEvent(EVENT_TICK,EmberTick)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_Venomancer then			
			stuff.play[7] = true
			script:RegisterEvent(EVENT_TICK,VenoTick)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_Axe then			
			stuff.play[8] = true
			script:RegisterEvent(EVENT_KEY,AxeKey)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_Tusk  then			
			stuff.play[9] = true
			script:RegisterEvent(EVENT_KEY,TuskKey)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_Juggernaut then			
			stuff.play[10] = true
			script:RegisterEvent(EVENT_KEY,JugKey)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_Beastmaster then			
			stuff.play[11] = true
			script:RegisterEvent(EVENT_KEY,BeastKey)
			script:UnregisterEvent(Load)
		elseif me.classId == CDOTA_Unit_Hero_Legion_Commander then			
			stuff.play[12] = true
			script:RegisterEvent(EVENT_KEY,LCKey)
			script:UnregisterEvent(Load)
		--[[elseif me.classId == CDOTA_Unit_Hero_DarkSeer then			
			stuff.play[13] = true
			script:RegisterEvent(EVENT_KEY,DSTick)
			script:UnregisterEvent(Load)]]
		else
			script:Disable()
		end
	end
end

function GameClose()	
	stuff.activated = false
	if stuff.play[1] then
		stuff.toggle = false
		stuff.toggle_1 = false
		script:UnregisterEvent(PhoenixTick)
		script:UnregisterEvent(PhoenixKey)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[1] = false
	elseif stuff.play[2] then
		script:UnregisterEvent(LoneKey)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[2] = false
	elseif stuff.play[3] then
		stuff.eff = {}
		stuff.pic = {}
		stuff.stage = 0
		script:UnregisterEvent(BroodTick)
		script:UnregisterEvent(BroodKey)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[3] = false
	elseif stuff.play[4] then
		hero = {}
		spell = {}
		script:UnregisterEvent(BrewTick)
		script:UnregisterEvent(BrewKey)
		script:RegisterEvent(EVENT_TICK,Load)		
		stuff.play[4] = false
	elseif stuff.play[5] then
		script:UnregisterEvent(ClockTick)
		script:UnregisterEvent(ClockKey)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[5] = false
	elseif stuff.play[6] then
		script:UnregisterEvent(EmberKey)
		script:UnregisterEvent(EmberTick)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[6] = false
	elseif stuff.play[7] then
		script:UnregisterEvent(VenoTick)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[7] = false
	elseif stuff.play[8] then
		script:UnregisterEvent(AxeKey)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[8] = false
	elseif stuff.play[9] then
		script:UnregisterEvent(TuskKey)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[9] = false
	elseif stuff.play[10] then
		script:UnregisterEvent(JugKey)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[10] = false
	elseif stuff.play[11] then
		script:UnregisterEvent(BeastKey)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[11] = false
	elseif stuff.play[12] then
		script:UnregisterEvent(LCKey)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[12] = false
	elseif stuff.play[13] then
		script:UnregisterEvent(DSTick)
		script:RegisterEvent(EVENT_TICK,Load)
		stuff.play[13] = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)