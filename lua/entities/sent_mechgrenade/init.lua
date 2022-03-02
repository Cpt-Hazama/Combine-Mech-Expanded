
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.explodeDel = NULL
ENT.explodeTime = 2

function ENT:SpawnFunction(ply, tr)
--------Spawning the entity and getting some sounds i use.   
 	if (!tr.Hit) then return end 
 	 
 	local SpawnPos = tr.HitPos +tr.HitNormal *10 
 	 
 	local ent = ents.Create("sent_MechGrenade")
	ent:SetPos(SpawnPos) 
 	ent:Spawn()
 	ent:Activate() 
 	ent.Owner = ply
	
	self.explodeDel = CurTime() +self.explodeTime
	return ent 
 	 
end

function ENT:Initialize()

	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:SetMaterial("models/props_canal/metalwall005b")
	self:SetOwner(self.Owner)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	
		
	util.SpriteTrail(self, 0, Color(200,200,200,255), false, 4, 0, 3, 1/(15+1)*0.5, "trails/smoke.vmt")
	
	self.explodeDel = CurTime() +self.explodeTime
end

-------------------------------------------PHYS COLLIDE
function ENT:PhysicsCollide(data, phys) 
	ent = data.HitEntity
end

-------------------------------------------PHYS UPDATE

-------------------------------------------THINK
function ENT:Think()
	if self.explodeDel < CurTime() then
		self:Explode()
	end
end

function ENT:Explode()

		self.ExplodeOnce = 1
		local expl = ents.Create("env_explosion")
		expl:SetKeyValue("spawnflags",128)
		expl:SetPos(self:GetPos())
		expl:Spawn()
		expl:Fire("explode","",0)
		--[[
		local FireExp = ents.Create("env_physexplosion")
		FireExp:SetPos(self:GetPos())
		FireExp:SetParent(self)
		FireExp:SetKeyValue("magnitude", 500)
		FireExp:SetKeyValue("radius", 200)
		FireExp:SetKeyValue("spawnflags", "1")
		FireExp:Spawn()
		FireExp:Fire("Explode", "", 0)
		FireExp:Fire("kill", "", 5)
		]]--
		util.BlastDamage(self, self, self:GetPos(), 200, 200)
	
	self:Remove()
end
