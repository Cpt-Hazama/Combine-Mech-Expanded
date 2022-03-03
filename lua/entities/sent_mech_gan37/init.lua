AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.MechModel = "models/lp/gan37_w.mdl"
ENT.MoveSpeed = 250
ENT.RocketDelay = 3
ENT.MachineGunDelay = 0.025
ENT.MachineGunHeatDecay = 2.5
ENT.MachineGunDelayHeated = 3

function ENT:InitializeConVars()
	local hp = 800
	local shield = 250

	self.MechHealth = hp
	self.MechMaxHealth = hp
	self.Energy = shield
	self.MaxEnergy = shield
	self.maxFlyHeight = 1000
end

function ENT:InitializeSprite()
	self.ShieldSprite = ents.Create("env_sprite")
	self.ShieldSprite:SetPos(self:GetPos() +Vector(-46,0,58))
	self.ShieldSprite:SetKeyValue("renderfx", "14")
	self.ShieldSprite:SetKeyValue("model", "sprites/glow1.vmt")
	self.ShieldSprite:SetKeyValue("scale","0.5")
	self.ShieldSprite:SetKeyValue("spawnflags","1")
	self.ShieldSprite:SetKeyValue("angles","0 0 0")
	self.ShieldSprite:SetKeyValue("rendermode","9")
	self.ShieldSprite:SetKeyValue("renderamt","255")
	self.ShieldSprite:SetKeyValue("rendercolor", "0 255 0")				
	self.ShieldSprite:Spawn()	
	self.ShieldSprite:SetParent(self.keepUpRightProp)
end

function ENT:ShootGrenade()
	self.Cloaking = self.Cloaking or false
    local ents = {self,self.MechRagdoll,self.MechUserEnt,self.UserSeat,self.keepUpRightProp}
    if self.Cloaking then
        self.Cloaking = false
        for _,v in pairs(ents) do
            v:SetMaterial(" ")
            v:DrawShadow(true)
        end
    else
        self.Cloaking = true
        for _,v in pairs(ents) do
            v:SetMaterial("models/props_c17/frostedglass_01a")
            v:DrawShadow(false)
        end
    end
end
		
function ENT:ShootRocket()
    for i = 1,4 do
        timer.Simple(i *0.125,function()
            if IsValid(self) && IsValid(self.User) then
                self:EmitSound("weapons/stinger_fire1.wav",75,math.random(80,120))	

                local tracedata = {}
                tracedata.start = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +Vector(0,0,-20)
                tracedata.endpos = tracedata.start +(self.User:GetAimVector() *4000)
                tracedata.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
                local trace = util.TraceLine(tracedata)

                local Missile = ents.Create("sent_MechMissile")
                Missile:SetPos(self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetRight() *(-80 +(i *8)) +self.keepUpRightProp:GetUp() *35 ) 				
                Missile:SetAngles(self.keepUpRightProp:GetAngles())
                Missile.FollowPos = trace.HitPos
                Missile.ActivateDel = 0
                Missile.angchange = 5
                Missile:Spawn()
                Missile:Activate() 
                Missile:GetPhysicsObject():Wake()
                
                self.TempMissile = Missile
                constraint.NoCollide(Missile, self.MechRagdoll, 0, 0)
                constraint.NoCollide(Missile, self.keepUpRightProp, 0, 0)
                constraint.NoCollide(Missile, self, 0, 0)
            end
        end)
    end
end

function ENT:ShootBullet()
	self:EmitSound("^weapons/airboat/airboat_gun_energy"..math.random(1,2)..".wav",75,math.random(80,120))	

	local pos = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetRight() *40 +self.keepUpRightProp:GetForward() *40 +self.keepUpRightProp:GetUp() *20
    local tracedata = {}
    tracedata.start = pos
    tracedata.endpos = tracedata.start +(self.User:GetAimVector() *999999999999)
    tracedata.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
    local trace = util.TraceLine(tracedata)

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos
	bullet.Dir 			= self.User:GetAimVector()
	bullet.Spread 		= Vector(0.03,0.03,0)
	bullet.Tracer		= 1
	bullet.TracerName	= "NULL"
	bullet.Force		= 0
	bullet.Damage		= 5
	bullet.Attacker 	= self.User
	bullet.IgnoreEntity = self.MechRagdoll
    bullet.Callback = function(attacker, tr, dmginfo)
        local effectdata = EffectData()
        effectdata:SetStart(pos)
        effectdata:SetOrigin(tr.HitPos)
        util.Effect("SakLaserTracer", effectdata)
    end
	self:FireBullets(bullet)
end

function ENT:FireLaser()
	self.HasUsedLaser = false
		
	self.ChargeVortSound:Stop()
	self:EmitSound("npc/vort/attack_shoot.wav",100,math.random(80,120))	
	
	local sourcePos = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetRight() *40 +self.keepUpRightProp:GetForward() *40 +self.keepUpRightProp:GetUp() *20
	
	local tracedata = {}
	tracedata.start = sourcePos
	tracedata.endpos = tracedata.start +(self.User:GetAimVector() *999999999999)
	tracedata.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
	local trace = util.TraceLine(tracedata)				
	
	
	// Shoot a bullet
	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= sourcePos
	bullet.Dir 			= self.User:GetAimVector()
	bullet.Spread 		= Vector(0,0,0)
	bullet.Tracer		= 1
	bullet.TracerName	= "NULL"
	bullet.Force		= 50
	bullet.Damage		= 200
	bullet.Attacker 	= self.User
	bullet.IgnoreEntity = self.MechRagdoll
    bullet.Callback = function(attacker, tr, dmginfo)
        local effectdata = EffectData()
        effectdata:SetStart(pos)
        effectdata:SetOrigin(tr.HitPos)
        util.Effect("SakLaserTracer", effectdata)
    end
	self:FireBullets(bullet)
end