require("libs.Utils")

local stuff = {}
stuff.play = {}
stuff.activated = false

--Phoenix
stuff.toggle = false
stuff.toggle_1 = false
stuff.text = drawMgr:CreateText(5,0-45, 0xF30E0E99, "P",drawMgr:CreateFont("F14","Calibri",18,500)) stuff.text.visible = false
stuff.angle = 30 -- if the angle between the target and the hero is more then 30* phoenix stops
stuff.distance = 700 -- min distance for move


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

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId == CDOTA_Unit_Hero_Phoenix then			
			stuff.play[1] = true
			script:RegisterEvent(EVENT_TICK,PhoenixTick)
			script:RegisterEvent(EVENT_KEY,PhoenixKey)	
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
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)