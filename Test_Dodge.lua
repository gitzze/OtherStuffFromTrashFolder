require("libs.Utils")
require("libs.Dodge")

sleep = {}

function Tick(tick)

	if not client.connected or client.loading or client.console or not SleepCheck() or not LatSleepCheck(lat) then return end
	
	local me = entityList:GetMyHero()
	
	if not me then return end
			
	local enemy = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,illusion=false,visible=true})
	
	for i,v in ipairs(enemy) do
		if v.team ~= me.team then

			if AnimationList[v.name] then
				local Spell = MySpell(AnimationList[v.name].ability,me)
				local Items = MyItem(AnimationList[v.name].items,me)
				local animation = v:GetProperty("CBaseAnimating","m_nSequence")
				if animation == AnimationList[v.name].animation then					
					if GetDistance2D(v,me) < AnimationList[v.name].range then						
						local toface = AnimationList[v.name].toface
						if not toface or (toface and ToFace(me,v)) then						
							if Spell and Spell.state == -1 then
								local latency = AnimationList[v.name].spellLat
								if latency and Spell.name ~= "slark_dark_pact" then
									if sleep[v.handle] == false then
										if me.name == "npc_dota_hero_ember_spirit" then
											me:Attack(v)
										end
										SmartSleep(latency,v,me)
										sleep[v.handle] = true
										return
									else
										sleep[v.handle] = false
										SmartCast(Spell,AnimationList[v.name].ability,AnimationList[v.name].vector,v,me) Sleep(500)
										break
									end
								else 
									SmartCast(Spell,AnimationList[v.name].ability,AnimationList[v.name].vector,v,me) Sleep(500)
									break
								end	
							elseif Items and Items.state == -1 then								
								local latency1 = AnimationList[v.name].itemLat
								if latency1 then														
									if sleep[v.handle] == false then
										SmartSleep(latency1,v,me)
										sleep[v.handle] = true
										return
									else
										sleep[v.handle] = false
										
										SmartCast(Items,AnimationList[v.name].items,AnimationList[v.name].vectors,v,me) Sleep(500)
										break
									end
								else
									SmartCast(Items,AnimationList[v.name].items,AnimationList[v.name].vectors,v,me) Sleep(500)
									break
								end	
							end
						else
							sleep[v.handle] = false
						end
					end
				else
					sleep[v.handle] = false	
				end	
			end

			--counter spell based on modifier
			if ModifierList[v.name] then
				local Spell = MySpell(ModifierList[v.name].ability,me)
				local Items = MyItem(ModifierList[v.name].items,me)
				if me.name == "npc_dota_hero_phoenix" or me.name == "npc_dota_hero_abaddon" or (Items and Items.name == "item_bloodstone") then					
					if v:GetAbility(4).level ~= 0 then
						if v:FindItem("item_ultimate_scepter") then dmg = "damage_scepter" else dmg = "damage" end
						local Dmg = v:GetAbility(4):GetSpecialData(dmg,v:GetAbility(4).level)
						if me.health < v:DamageTaken(Dmg, DAMAGE_MAGC, me) then							
							if me:DoesHaveModifier(ModifierList[v.name].modifier) then							
								if Spell and Spell.state == - 1 then
									SmartCast(Spell,ModifierList[v.name].ability,ModifierList[v.name].vector,v,me)
									Sleep(250)
									break
								elseif ItemsM then									
									SmartCast(Items,ModifierList[v.name].items,ModifierList[v.name].vectors,v,me)
									Sleep(250)
									break
								end
							end
						end
					end
				end
				if me.name ~= "npc_dota_hero_phoenix" or me.name ~= "npc_dota_hero_abaddon" then
					if me:DoesHaveModifier(ModifierList[v.name].modifier) then	
						if Spell and Spell.state == - 1 then
							SmartCast(Spell,ModifierList[v.name].ability,ModifierList[v.name].vector,v,me)
							Sleep(250)
							break
						elseif Items and Items.name ~= "item_bloodstone" then							
							SmartCast(Items,ModifierList[v.name].items,ModifierList[v.name].vectors,v,me)
							Sleep(250)
							break
						end
					end
				end
			end
			--counter any iniciate
			if InitiativeList[v.name] then
				local SpellI = MySpell(InitiativeList[v.name].ability,me)
				local blink = v:FindItem("item_blink")
				if blink and blink.cd > 11 then					
					local Spell = v:FindSpell(InitiativeList[v.name].spells)
					if Spell and Spell.state == -1 then
						if GetDistance2D(v,me) < Spell.castRange + 50 then
							SmartCast(SpellI,InitiativeList[v.name].ability,InitiativeList[v.name].vector,v,me)
							Sleep(250)
							break
						end
					end
				end
			end	
			--enemy mod
			if EnemyModifier[v.name] then
				local SkillE = MySpell(EnemyModifier[v.name].ability,me)
				local ItemsE = MyItem(EnemyModifier[v.name].items,me)
				if SkillE and SkillE.state == -1 then
					local Range = EnemyModifier[v.name].range
					local Distance = GetDistance2D(me,v)
					if Distance < Range then
						local Modifier = v:DoesHaveModifier(EnemyModifier[v.name].modifier)
						if Modifier then
							if ToFace(me,v) then
								SmartCast(SkillE,EnemyModifier[v.name].ability,EnemyModifier[v.name].vector,v,me)
								Sleep(250)	
								break								
							end
						end
					end
				elseif ItemsE and ItemsE.state == -1 then
					local Range = EnemyModifier[v.name].range
					local Distance = GetDistance2D(me,v)
					if Distance < Range then
						local Modifier = v:DoesHaveModifier(EnemyModifier[v.name].modifier)
						if Modifier then
							if ToFace(me,v) then
								SmartCast(ItemsE,EnemyModifier[v.name].items,EnemyModifier[v.name].vectors,v,me)
								Sleep(250)
								break
							end
						end
					end
				end
			end	
			
		end			
	end	
	
end

function SmartSleep(ms,target,me)

	if type(ms) == "string" then
		LatSleep(tonumber(ms)+(GetDistance2D(me,target)/9),lat)
	elseif type(ms) == "number" then
		LatSleep(ms,lat)
	end
	
end

function MySpell(tab,me)
	local tab = tab
	if tab then
		for i,v in ipairs(tab) do
			local abilities = me.abilities
			for _,spell in ipairs(abilities) do
				if spell and spell.name == v then
					return spell
				end
			end
		end
	end
	return nil
end

function MyItem(tab,me)
	local tab = tab
	if tab then
		for i,v in ipairs(tab) do
			local items = me.items
			for _,item in ipairs(items) do
				if item and item.name == v then
					return item
				end
			end
		end
	end
	return nil	
end

function SmartCast(spell,tab1,tab2,target,me)
	for i,v in ipairs(tab2) do		
		for a, ability in ipairs(tab1) do
			if ability == spell.name then
				local vector = tab2[a]
				if vector == "aoe" then
					me:CastAbility(spell,target.position)
				elseif vector == "me" then
					me:CastAbility(spell,me.position)
				elseif vector == "ONme" then
					me:CastAbility(spell,me)
				elseif vector == "target" then
					me:CastAbility(spell,target)
				elseif vector == "non" then
					me:CastAbility(spell)
				elseif vector == "specialE" then
					EmberSpecialCast(spell,target,me)
				elseif vector == "specialS" then
					StormSpecialCast(spell)
				elseif vector == "home" then
					GoHome(spell,me)
				end
			end
		end
	end
end

function EmberSpecialCast(spell,target,me)
	local bonusRange = {250,350,450,550}
	if GetDistance2D(me,target) < 750 + bonusRange[spell.level] and GetDistance2D(me,target) > 750 then
		LongCast(spell,me,target,bonusRange[spell.level])
	elseif GetDistance2D(me,target) < 750 then
		me:CastAbility(spell,target.position)
	end
end

function GoHome(spell,me)
	local v = entityList:GetEntities({classId = CDOTA_Unit_Fountain,team = me.team})[1]
	me:CastAbility(spell,Vector((v.position.x - me.position.x) * 1100 / GetDistance2D(v,me) + me.position.x,(v.position.y - me.position.y) * 1100 / GetDistance2D(v,me) + me.position.y,v.position.z))
end

function StormSpecialCast(spell,me)
	FrontCast(spell,me,100)
end

function LongCast(spell,my,target,range)
	me:CastAbility(spell,Vector((my.position.x - target.position.x) * range / GetDistance2D(target,my) + target.position.x,(my.position.y - target.position.y) * range / GetDistance2D(target,my) + target.position.y,target.position.z))
end

function FrontCast(spell,my,range)
	me:CastAbility(spell,Vector(my.position.x + range * math.cos(my.rotR), my.position.y + range * math.sin(my.rotR),my.position.z))
end

function ToFace(my,t_)
	if ((FindAngle(my,t_)) % (2 * math.pi)) * 180 / math.pi >= 350 or ((FindAngle(my,t_)) % (2 * math.pi)) * 180 / math.pi <= 10 then
		return true
	end
	return false
end

function RotationToSleep(my,t_)

	local Rot = ((FindAngle(my,t_)) % (2 * math.pi)) * 180 / math.pi
	if  Rot >= 30 and ((FindAngle(my,t_)) % (2 * math.pi)) * 180 / math.pi <= 180 then
		return Rot
	elseif  Rot >= 180 and ((FindAngle(my,t_)) % (2 * math.pi)) * 180 / math.pi <= 330 then
		return 360-Rot
	end

end

function FindAngle(my,t_)
	return ((math.atan2(my.position.y-t_.position.y,my.position.x-t_.position.x) - t_.rotR + math.pi) % (2 * math.pi)) - math.pi
end

function GameClose()
	sleep = {}
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Tick)
