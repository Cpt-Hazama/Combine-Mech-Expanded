--Copyright (c) 2010 Sakarias Johansson

AddCSLuaFile("autorun/client/CombineMech3RdPerson.lua")

hook.Add("GravGunPickupAllowed", "CombineMech GravGunPickupAllowed", function(ply, ent)
	if ent != NULL && ent:IsValid() then
		if ent:GetClass() == "prop_ragdoll" then
			if ent:GetModel() == "models/cm/cmbnmch.mdl" then
				return false 
			end
		end
		
		if ent:GetClass() == "sent_combinemech" or ent:GetClass() == "sent_combinemechuser" then
			return false 			
		end
	end
	return true 
end)

hook.Add("GravGunPunt", "CombineMech GravGunPunt", function(ply, ent)
	if ent != NULL && ent:IsValid() then
		if ent:GetClass() == "prop_ragdoll" then
			if ent:GetModel() == "models/cm/cmbnmch.mdl" then
				return false 
			end
		end
		
		if ent:GetClass() == "sent_combinemech" or ent:GetClass() == "sent_combinemechuser" then
			return false 			
		end
	end
	return true 
end)
