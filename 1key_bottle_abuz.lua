--on/off - "K"
--include early gang courer protection

require("libs.Utils")
require("libs.SideMessage")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Active", "K", config.TYPE_HOTKEY)
config:Load()

local toggleKey = config.Active
local active = false
local stage = nil

function Tick(tick)
	if IsIngame() and SleepCheck() and active then
		local me = entityList:GetMyHero()
		if me then
			local cour = entityList:FindEntities({classId = CDOTA_Unit_Courier,team = me.team,alive = true})[1]
			local fount = entityList:FindEntities({classId = CDOTA_Unit_Fountain,team = me.team})[1]
			if cour then			
				if cour:GetAbility(6).state == LuaEntityAbility.STATE_READY then
					cour:CastAbility(cour:GetAbility(6))
				end
				if not stage then	
					local notsafedistance = GetDistance2D(cour,fount)
					if cour.visibleToEnemy and notsafedistance < 6900 and notsafedistance > 4500 and not cour:GetProperty("CDOTA_Unit_Courier","m_bFlyingCourier") then
						cour:CastAbility(cour:GetAbility(1))
						stage = nil
						active = false
						CourerSideMessage()
					end
					local player = entityList:GetMyPlayer()
					local phys = entityList:GetEntities(function (bl) return bl.type==LuaEntity.TYPE_ITEM_PHYSICAL and bl.itemHolds.name== "item_bottle" end)[1]
					local bot = me:FindItem("item_bottle")
					if cour then							
						local distance = GetDistance2D(cour,me)
						if SleepCheck("fol") then
							cour:Follow(me) Sleep(5000,"fol")
						end				
						if distance < 200 and bot and not phys then
							player:Select(me)
							player:DropItem(bot,me.position)
						elseif phys then
							player:Select(cour)
							player:TakeItem(phys)
							player:Select(me)
							stage = 1
						end
					end
				elseif stage == 1 then
					local CourerB = cour:FindItem("item_bottle")
					if CourerB then
						if CourerB.charges ~= 3 then
							if cour.courState ~= LuaEntityCourier.STATE_B2BASE then
								cour:CastAbility(cour:GetAbility(1))
							end
						elseif cour.courState ~= LuaEntityCourier.STATE_DELIVER then
							cour:CastAbility(cour:GetAbility(4))
							cour:CastAbility(cour:GetAbility(5))
							entityList:GetMyPlayer():Select(me)
							stage = nil
							active = false
						end
					end
				end			
			end
		end
		Sleep(250)
	end	
end

function Key()
	if client.chat then return end
	if IsKeyDown(toggleKey) then
		active = not active
	end
end

function CourerSideMessage()
	local test = sideMessage:CreateMessage(200,60)	
	test:AddElement(drawMgr:CreateRect(20,13,30,30,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/courier")))
	test:AddElement(drawMgr:CreateText(90,13,-1,"Care!",drawMgr:CreateFont("defaultFont","Arial",25,500)))
end

script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_KEY,Key)
