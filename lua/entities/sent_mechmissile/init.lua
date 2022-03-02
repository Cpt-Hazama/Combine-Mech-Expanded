
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.EntAngs = NULL
ENT.MissileSound = NULL
ENT.ExplosionDel = CurTime() +1
ENT.ExplodeOnce = 0
ENT.ActivateDel = CurTime()

ENT.MissileTime = CurTime() +5	

ENT.DestPos = NULL
ENT.angchange	= 5
ENT.killed = false
ENT.Trail = NULL

function ENT:SpawnFunction(ply, tr)
--------Spawning the entity and getting some sounds i use.   
 	if (!tr.Hit) then return end 
 	 
 	local SpawnPos = tr.HitPos +tr.HitNormal *10 
 	 
 	local ent = ents.Create("sent_MechMissile")
	ent:SetPos(SpawnPos) 
 	ent:Spawn()
 	ent:Activate() 
 	ent.Owner = ply
	
	self.DestPos = self.FollowPos	
	self.ActivateDel = self.ActivateDel
	return ent 
 	 
end

function ENT:Initialize()

	self:SetModel("models/weapons/W_missile_closed.mdl")
	self:SetColor(Color(255, 255, 255, 255))
	self:SetOwner(self.Owner)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
	end
	
	 self.EntAngs = self:GetAngles()
		
	self.Trail = util.SpriteTrail(self, 0, Color(200,200,200,255), false, 4, 0, 3, 1/(15+1)*0.5, "trails/smoke.vmt")
	
	self.MissileSound = CreateSound(self,"weapons/rpg/rocket1.wav")
	self.MissileSound:Play()
	self:SetCollisionGroup(1)	
	
	self.MissileTime = CurTime() +5
	
	self.DestPos = self.FollowPos
	self.ActivateDel = self.ActivateDel	
	
end

-------------------------------------------PHYS COLLIDE
function ENT:PhysicsCollide(data, phys) 
	ent = data.HitEntity

	if self.ActivateDel < CurTime() && self.killed == false then
		self:Explode()
	elseif self.killed == false then
		self.killed = true 
		self:Fire("kill", "", 10)
		self.Trail:Remove()
		self.MissileSound:Stop()
		self:EmitSound("weapons/rpg/shotdown.wav",75,math.random(80,120))			
	end
end

-------------------------------------------PHYS UPDATE
function ENT:PhysicsUpdate(physics)

	if self.killed == false then
		phys = self:GetPhysicsObject()
		local veloc = phys:GetVelocity()	
		phys:SetVelocity(veloc)
		phys:ApplyForceCenter(self:GetForward() *40000)
		
		if self.MissileTime > CurTime() && self.ActivateDel < CurTime() && self.DestPos != nil && self.DestPos && self.DestPos != NULL then
		
			local AimVec = (self.DestPos -self:GetPos()):Angle()
			local Dist = math.min(self:GetPos():Distance(self.DestPos), 5000)
			local Dist = Dist /5000
			local Mod = (1 -Dist) *self.angchange

			self.EntAngs.p = math.ApproachAngle(self.EntAngs.p, AimVec.p, 0.5 +Mod)
			self.EntAngs.r = math.ApproachAngle(self.EntAngs.r, AimVec.r, 0.5 +Mod)
			self.EntAngs.y = math.ApproachAngle(self.EntAngs.y, AimVec.y, 0.5 +Mod)
			self:SetAngles(self.EntAngs)

			local dist = self.DestPos:Distance(self:GetPos())
			if dist < 20 then
				self:Explode()
			end
		
		end
	end
end
-------------------------------------------THINK
function ENT:Think()

	if self.ExplosionDel < CurTime() then
		self:SetCollisionGroup(3)
	end

	phys = self:GetPhysicsObject()
	phys:Wake()
	
end


-------------------------------------------REMOVE
function ENT:OnRemove()

end

function ENT:OnRemove()
	self.MissileSound:Stop()
end

function ENT:Explode()

	if self.ExplodeOnce == 0 then
		
		self.ExplodeOnce = 1
		local expl = ents.Create("env_explosion")
		expl:SetKeyValue("spawnflags",128)
		expl:SetPos(self:GetPos())
		expl:Spawn()
		expl:Fire("explode","",0)

		util.BlastDamage(self, self, self:GetPos(), 200, 200)
		
		self:Remove()
	end
end
