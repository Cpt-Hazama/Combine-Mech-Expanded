
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.ActivateDel = CurTime()
ENT.DestPos = NULL
ENT.ignoreProps = {NULL,NULL,NULL}
ENT.ActiveEffect = NULL
ENT.GravSound = NULL

function ENT:SpawnFunction(ply, tr)
--------Spawning the entity and getting some sounds i use.   
 	if (!tr.Hit) then return end 
 	 
 	local SpawnPos = tr.HitPos +tr.HitNormal *10 
 	 
 	local ent = ents.Create("sent_MechGravProbe")
	ent:SetPos(SpawnPos) 
 	ent:Spawn()
 	ent:Activate() 
 	ent.Owner = ply
	
	return ent 
 	 
end

function ENT:Initialize()

	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:SetColor(Color(255, 255, 255, 0))
	self:SetOwner(self.Owner)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
		
    local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	phys:EnableGravity(false)
		
	
	self.DestPos = self.FollowPos
	self.ActivateDel = self.ActivateDel	

	local yellowSprite = ents.Create("env_sprite");
	yellowSprite:SetPos(self:GetPos());
	yellowSprite:SetKeyValue("renderfx", "14")
	
	yellowSprite:SetKeyValue("model", "sprites/glow1.vmt")
	--yellowSprite:SetKeyValue("model", "Effects/strider_pinch_dudv")
	yellowSprite:SetKeyValue("scale","1")
	yellowSprite:SetKeyValue("spawnflags","1")
	yellowSprite:SetKeyValue("angles","0 0 0")
	yellowSprite:SetKeyValue("rendermode","9")
	yellowSprite:SetKeyValue("renderamt","255")
	yellowSprite:SetKeyValue("rendercolor", "255 222 0")				
	yellowSprite:Spawn()	
	yellowSprite:SetParent(self)	

	self.ActiveEffect = ents.Create("env_rotorwash_emitter")
	self.ActiveEffect:SetPos(self:GetPos())
	self.ActiveEffect:SetParent(self)
	self.ActiveEffect:Activate()		
	
	self.GravSound = CreateSound(self,"weapons/physcannon/superphys_hold_loop.wav")
	self.GravSound:Play()	
	
	local effectdata = EffectData()
	effectdata:SetEntity(self)
	util.Effect("mech_GravProbeEff",effectdata)		
	
end

-------------------------------------------PHYS COLLIDE
function ENT:PhysicsCollide(data, phys) 
	ent = data.HitEntity

	if ent && ent:IsValid() then
		constraint.NoCollide(self, ent, 0,0)
		self:EmitSound("weapons/physcannon/energy_bounce"..math.random(1,2)..".wav",75,math.random(80,120))	
	end
	
end

-------------------------------------------PHYS UPDATE
function ENT:PhysicsUpdate(physics)

	local pitch = self:GetVelocity():Length()
	pitch = pitch /10
	local pitch = math.Clamp(pitch, 50, 200)
	
	self.GravSound:ChangePitch(pitch,0)

	if self.DestPos != NULL then
		local pos = self:GetPos()
		local dir = (self.DestPos -pos):GetNormalized()

		self:GetPhysicsObject():ApplyForceCenter(dir *50)
	end
	
	local maxDist = 300
	for k, v in pairs(ents.FindInSphere(self:GetPos(), maxDist)) do

		local phys = v:GetPhysicsObject()
		local dontUse = false
		
		for i = 1,3  do
			if self.ignoreProps[i] != NULL && self.ignoreProps[i] != nil then
				if self.ignoreProps[i] == v:EntIndex() or (v.IsMechProp && v.IsMechProp == true) then
					dontUse = true
				end
			end	
		end
		
		local dir = (self:GetPos() -v:GetPos()):GetNormalized()
		local dist = self:GetPos():Distance(v:GetPos())
		local force = dist /maxDist
		local vel = v:GetVelocity()	
		local speed = vel:Length()	
	
		if dontUse == false then
		
			if v:GetClass()=="rpg_missile" && dist > 200 then
				v:SetLocalVelocity(dir *speed *1000)
				v:SetAngles(dir:Angle())	
				
			elseif (v:GetClass() == "crossbow_bolt" or v:GetClass() == "hunter_flechette") && dist > 200 then
				v:SetLocalVelocity(dir *speed *1000)

			elseif  string.find(v:GetClass(), "missile") && dist > 200 then
				v:SetAngles(dir:Angle())
				v:GetPhysicsObject():SetVelocity(dir *speed *0.5)

			elseif (v:IsPlayer() or v:IsNPC()) && phys && phys:IsValid() then
				v:SetVelocity(dir *force *400)	
				
				if dist > 200 then
					if speed < 500 then speed = 500 end
					vel = vel:GetNormalized()					
					vel = vel *dir			
					phys:SetVelocity(dir *speed)
				end			
			elseif phys && phys:IsValid() then
				
				
				if v:GetClass() == "prop_ragdoll" then
					force = force *10
				end
				
				phys:ApplyForceCenter(dir *force *phys:GetMass() *100)
				
				if dist > 200 then
					
					if speed < 500 then speed = 500 end
					vel = vel:GetNormalized()					
					vel = vel *dir		
					phys:SetVelocity(dir *speed)
				
				end
			end	
		end
	end
	
end
-------------------------------------------THINK
function ENT:Think()

	self:GetPhysicsObject():Wake()
		
	if self.ArmTime != NULL then
		if self.ArmTime < CurTime() then
			self:Remove()
		end		
	end
	
end
-------------------------------------------REMOVE
function ENT:OnRemove()
	self.ActiveEffect:Remove()
	self.GravSound:Stop()
	self:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav",75,math.random(80,120))	
end

function ENT:Activate()
	
end

