
--include("CombineMech3RdPerson.lua")

// Never and I repeat NEVER make CalcView hooks in an autorun file. Always create them inside the entity when it's spawned and add a self-deleting check to the hook. This is waaaaaay more optimized and effecient than anything else!
-- hook.Add("CalcView", "CombineMech CalcView", function(ply, position, angles, fov)


	-- if !ply:Alive() then return end
	-- if(ply:GetActiveWeapon() == NULL or ply:GetActiveWeapon() == "Camera") then return end
	-- if GetViewEntity() != ply then return end
	
	-- local useCam = ply:GetNetworkedInt("ControlsCombineMech")
	
	-- if (useCam && useCam == 1 or useCam == 2) && ply:InVehicle() then
	
	-- 	local ent = ply:GetNetworkedEntity("CombineMechEnt")
	-- 	local saw = ply:GetNetworkedEntity("CombineMechSawEnt")

	-- 	if ent != NULL && ent:IsValid() then
	
	-- 		if useCam == 1 then
	-- 			local pos = ent:GetPos() +(angles:Forward() *-300)
				
	-- 			local Trace = {}
	-- 			Trace.start = ent:GetPos() +(angles:Forward() *-100)
	-- 			Trace.endpos = pos
	-- 			Trace.filter = {ply,ent,saw}
	-- 			local tr = util.TraceLine(Trace)
				
	-- 			if tr.Hit then	
	-- 				pos = tr.HitPos
	-- 			end	
				
	-- 			position = pos
	-- 			return GAMEMODE:CalcView(ply, position, angles, fov)
	-- 		elseif useCam == 2 then
	-- 			local pos = saw:GetPos()
	-- 			local ang = saw:GetAngles()
	-- 			ang.p = angles.p
	-- 			ang.y = angles.y
	-- 			angles = ang
	-- 			pos = pos +saw:GetForward() *50 +saw:GetUp() *-20

	-- 			position = pos
	-- 			return GAMEMODE:CalcView(ply, position, angles, fov)
	-- 		end
	-- 	end
	-- end
	
	-- if (useCam && useCam == 1 or useCam == 2) && !(ply:InVehicle()) then
	-- 	ply:SetNetworkedInt("ControlsCombineMech",0)
	-- end


-- end)