--Copyright (c) 2010 Sakarias Johansson
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.enterDel = CurTime()

------------------------------------VARIABLES END
function ENT:SpawnFunction(ply, tr)
 	if (!tr.Hit) then return end 
 	 
 	local SpawnPos = tr.HitPos
 	 
	local ent = ents.Create("sent_combineMechUser")	
	ent:SetPos(SpawnPos) 
 	ent:Spawn()
 	ent:Activate() 
	return ent 
	
end

function ENT:Initialize()

	self:SetModel("models/props_combine/CombineButton.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetSolid(SOLID_VPHYSICS)	
    local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
		
end

-------------------------------------------USE
function ENT:Use(activator, caller)	

	if self.enterDel < CurTime() then
		local ent = self:GetNetworkedEntity("CombineMechEnt")	
		
		if ent && ent != NULL then
			ent:EnterMech(activator)
			self.enterDel = CurTime() +1
		end
	end
	
end