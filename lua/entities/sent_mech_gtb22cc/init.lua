AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.MechModel = "models/lp/gtb22_ccr.mdl"
ENT.RocketDelay = 5
ENT.MachineGunDelay = 0.025
ENT.MachineGunHeatDecay = 2
ENT.MachineGunDelayHeated = 5

function ENT:InitializeConVars()
	local hp = 450
	local shield = 100

	self.MechHealth = hp
	self.MechMaxHealth = hp
	self.Energy = shield
	self.MaxEnergy = shield
	self.maxFlyHeight = 1000
end

function ENT:ShootBullet()
	self:EmitSound("^weapons/ar1/ar1_dist"..math.random(1,2)..".wav",75,math.random(80,120))	

	local pos = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetRight() *40 +self.keepUpRightProp:GetForward() *45 +self.keepUpRightProp:GetUp() *20

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos
	bullet.Dir 			= self.User:GetAimVector()
	bullet.Spread 		= Vector(0.03,0.03,0)
	bullet.Tracer		= 1
	bullet.TracerName	= "lfs_tracer_white"
	bullet.Force		= 0
	bullet.Damage		= 5
	bullet.Attacker 	= self.User		
	bullet.IgnoreEntity = self.MechRagdoll		
	self:FireBullets(bullet)
end
		
function ENT:ShootRocket()
    local pos = {
        {r=-50,u=30},
        {r=-50,u=40},
        {r=-40,u=30},
        {r=-40,u=40},
    }
    for i = 1,4 do
        timer.Simple(i *0.3,function()
            if IsValid(self) && IsValid(self.User) then
                self:EmitSound("weapons/stinger_fire1.wav",75,math.random(80,120))	

                local tracedata = {}
                tracedata.start = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +Vector(0,0,-20)
                tracedata.endpos = tracedata.start +(self.User:GetAimVector() *4000)
                tracedata.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
                local trace = util.TraceLine(tracedata)

                local Missile = ents.Create("sent_MechMissile")
                Missile:SetPos(self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +self.keepUpRightProp:GetRight() *pos[i].r +self.keepUpRightProp:GetUp() *pos[i].u)			
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

function ENT:ShootGrenade()
	return
end