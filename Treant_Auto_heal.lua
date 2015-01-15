require("libs.Utils")

--[[    CONFIG			]]
toggleKey = string.byte("T")
allyheroHealth = 0.8 -- Mimimum hp to start healing. 0.6 = heal hero if its hp lower than 60%
towerHealth = 0.8 
barracksHealth = 0.8
meHealth = 0.6
--[[ 			Code			]]

activated = true
myFont = drawMgr:CreateFont("manabarsFont","Arial",14,500)
main = drawMgr:CreateText(20,50,0xFFFFFFff,"AutoHealOn",myFont)
main.visible = false
text = drawMgr:CreateText(20,65,0xFFFFFFff,"No target",myFont)
text.visible = false

function Tick( tick )

	if not client.connected or client.loading or client.console or not SleepCheck() then return end
		 
	local me = entityList:GetMyHero()
	local player = entityList:GetMyPlayer()
	
	if not me then return end
		
	if me.name ~= "npc_dota_hero_treant" then
	
		text.visible = false
		main.visible = false
		script:Disable()
		
	elseif activated then
	
		main.text = "AutoHealOn"
		text.visible = true
		main.visible = true		
		
		local heal = me:GetAbility(3)
	
		if heal.state == -1 then
		
			if me.health/me.maxHealth < meHealth then
				text.text = ""..me.name
				player:UseAbility(heal,me)
				Sleep(1000)
				return
			end		
			
			local allyhero = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = me.team,alive=true,visible=true,illusion=false})
			table.sort( allyhero, function (a,b) return a.health < b.health end )
			for i,v in ipairs(allyhero) do
				if v.health/v.maxHealth < allyheroHealth then
					text.text = ""..v.name:gsub("npc_dota_hero_","")
					player:UseAbility(heal,v)
					Sleep(1000)
					return
				end
			end
			
			local tower = entityList:GetEntities({classId=CDOTA_BaseNPC_Tower,team = me.team,alive=true,visible=true})
			table.sort( tower, function (a,b) return a.health < b.health end )
			for i,v in ipairs(tower) do
				if v.health/v.maxHealth < towerHealth then
					text.text = ""..v.name
					player:UseAbility(heal,v)
					Sleep(1000)
					return
				end
			end
			
			local barracks = entityList:GetEntities({classId=CDOTA_BaseNPC_Barracks,team = me.team,alive=true,visible=true})
			table.sort( barracks, function (a,b) return a.health < b.health end )
			for i,v in ipairs(barracks) do
				if v.health/v.maxHealth < barracksHealth then
					text.text = ""..v.name
					player:UseAbility(heal,v)
					Sleep(1000)
					return
				end
			end

		end
	else
		main.text = "AutoHealOff"
		text.visible = false
	end
	
end

function Key()
    if IsKeyDown(toggleKey) then   
       activated = (not activated)
	end
end

function GameClose()
	activated = true
	text.visible = false
	main.visible = false	
end
 
script:RegisterEvent(EVENT_CLOSE, GameClose)
script:RegisterEvent(EVENT_KEY,Key)
script:RegisterEvent(EVENT_TICK,Tick)
