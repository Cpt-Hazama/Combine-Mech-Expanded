--I have tried putting in some comments.
--Sometimes i wonder if it's even worth it.
--Even if someone did read them it would probably be a bit confusing anyway. =[

--Have been thinking about writing a story.
--That would probably make more people read the comments.
--A small part of a tale apprearing every now and then.

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')


--There is still something that confuses me about these variables.
--Some of them just automatically becomes globals.
--Like vectors!
--I had to change a vector to separate floats because in multiplayer we ended up controlling each others mechs.
--We could still only move one mech, like i could control my friends mech but my friend controlled a mingebags mech.
--But if it's a global how come we all couldn't control each others mechs?
--Maybe i just did something wrong.
--At least it works with floats now.

--Misc
ENT.mech = NULL
ENT.MechUserEnt = NULL
ENT.Seat = NULL
ENT.JetTimer = CurTime()
ENT.DotProd = 1
ENT.ChangeView = true
ENT.ChangeViewDel = CurTime()
ENT.NPCTarget = NULL
ENT.NPCTarget2 = NULL
ENT.UpdateMechAsTargetDel = CurTime()
ENT.Spawner = NULL
ENT.IsUsingJet = false

ENT.UserSeat = NULL

--Health
ENT.MechHealth = 400
ENT.MechMaxHealth = 400
ENT.DamageLevel = 0
ENT.SmokeEffect = NULL

----Weapons
ENT.wepType = 1
ENT.maxWeps = 7
ENT.oldWepType = 1
ENT.changeWepDel = CurTime()
--Missiles
ENT.ShootRockedDel = CurTime()
ENT.TempMissile = NULL
--Grenades
ENT.ShootGrenadeDel = CurTime()
ENT.GrenadeHeat = 0
--MissileStorm
ENT.ShootMissileStormDel = CurTime()
ENT.UseMissileStormDel = CurTime()
ENT.NextMissileStorm = CurTime()
ENT.MissileStormDestPos = Vector(0,0,0)
--MachineGun
ENT.MachineGunDel = CurTime()
ENT.MachineGunHeat = 100
ENT.GunHeatDel = CurTime() 
--Screamer
ENT.ScreamerDel = CurTime()
ENT.ScreamerFireDel = CurTime()
ENT.ShouldScreamer = false
--GravProbe
ENT.GravProbeDel = CurTime()
ENT.GravProbeSpawned = false
--FlashLight
ENT.FlashLightEnt = NULL
ENT.LeftFlashSprite = NULL
ENT.RightFlashSprite = NULL
ENT.FlashLightDel = CurTime()
--Laser
ENT.LaserShootDel = CurTime()
ENT.LaserUseDel = CurTime()
ENT.HasUsedLaser = false

--Player vars
ENT.User = NULL
ENT.enterDel = CurTime()

--Hover Var
ENT.hoverHeight = 130
ENT.hoverMultiplier = 1
ENT.flyHeight = 0

--Move Var
ENT.MoveOffsetX = 0
ENT.MoveOffsetY = 0
ENT.MoveLeftDel = CurTime()
ENT.MoveRightDel = CurTime()
ENT.DontMoveLeftDel = CurTime()
ENT.DontMoveRightDel = CurTime()
ENT.LeftMoveDist = 0
ENT.RightMoveDist = 0

ENT.LeftMoveDir = NULL
ENT.RightMoveDir = NULL
ENT.FootStatus = 0
ENT.LastFootStatus = 0

--Constraints
ENT.keepUpRightProp = NULL
ENT.keepUpRightCon = NULL
ENT.StabAng = NULL

--Sounds
ENT.JetSound = NULL
ENT.JetPlay = false
ENT.ChargeVortSound = NULL 

--Shield
ENT.Energy = 100
ENT.MaxEnergy = 100
ENT.UpdateShield = CurTime()
ENT.ShieldEffDel = CurTime()
ENT.ShieldDown = false
ENT.ShieldSprite = NULL

--New
ENT.MechModel = "models/CM/Cmbnmch.mdl"

------------------------------------VARIABLES END
function ENT:SpawnFunction(ply, tr)
 	if (!tr.Hit) then return end 
 	 
 	local SpawnPos = tr.HitPos
 	 
	local ent = ents.Create("sent_combineMech")	
	ent:SetPos(SpawnPos) 
 	ent:Spawn()
 	ent:Activate() 
	self.User = NULL
	ent:FixPropProtection(ply)
	
	ent:SetUser(ply)
	
	return ent 
	
end

function ENT:InitializeConVars()
	self.maxFlyHeight = 1000
	if GetConVar("sv_combinemech_disablemodifiers"):GetBool() == true then
		return
	end

	local hp = GetConVar("sv_combinemech_maxhealth"):GetInt() or 400
	local shield = GetConVar("sv_combinemech_maxshield"):GetInt() or 100

	self.MechHealth = hp
	self.MechMaxHealth = hp
	self.Energy = shield
	self.MaxEnergy = shield
	self.maxFlyHeight = GetConVar("sv_combinemech_maxhoverheight"):GetInt() or 1000
end

function ENT:Initialize()
	self:SetModel("models/dav0r/hoverball.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(0,0,0,0))
	
	self:SetSolid(SOLID_VPHYSICS)	
    local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	
	self.User = NULL

	self:InitializeConVars()
	
	--Spawning the mech ragdoll
	self.MechRagdoll = ents.Create("prop_ragdoll") 
	self.MechRagdoll:SetModel(self.MechModel) 
	self.MechRagdoll:SetPos(self:GetPos())  
	self.MechRagdoll:Spawn()  
	
	--Disabling gravity on the mechs legs
	self.MechRagdoll:GetPhysicsObjectNum(3):EnableGravity(false)
	self.MechRagdoll:GetPhysicsObjectNum(4):EnableGravity(false)
	self.MechRagdoll:GetPhysicsObjectNum(9):EnableGravity(false)
	self.MechRagdoll:GetPhysicsObjectNum(10):EnableGravity(false)
	
	local bonepos, boneang = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(1)) 
	self:SetPos(bonepos)
	
	--Welding the ent to the ragdoll
	constraint.Weld(self, self.MechRagdoll, 0, 0, 0, true)
	
	--Welding the feet to make it more stable and less floppy
	constraint.Weld(self.MechRagdoll, self.MechRagdoll, 15, 6, 0, true)
	constraint.Weld(self.MechRagdoll, self.MechRagdoll, 7, 6, 0, true)
	constraint.Weld(self.MechRagdoll, self.MechRagdoll, 13, 12, 0, true)
	constraint.Weld(self.MechRagdoll, self.MechRagdoll, 14, 12, 0, true)
	
	constraint.Weld(self.MechRagdoll, self.MechRagdoll, 9, 10, 0, true)
	constraint.Weld(self.MechRagdoll, self.MechRagdoll, 3, 4, 0, true)
	
	--Placing a sawblade in the head and setting keepupright
	self.keepUpRightProp = ents.Create("prop_physics")
	self.keepUpRightProp:SetModel("models/props_junk/sawblade001a.mdl")
	self.keepUpRightProp:SetPos(self:GetPos() +Vector(0,0,20))
	self.keepUpRightProp:SetAngles(self:GetAngles())
	self.keepUpRightProp:SetColor(Color(0,0,0,0))
	self.keepUpRightProp:Spawn()
	self.keepUpRightProp:GetPhysicsObject():EnableGravity(false)
	self.keepUpRightCon = constraint.Keepupright(self.keepUpRightProp, self:GetAngles(), 0, 100000000)
	
	self.StabAng = self:GetAngles()
	constraint.Weld(self.keepUpRightProp, self.MechRagdoll, 0, 1, 0, true)
	
	--The control station
	self.MechUserEnt = ents.Create("sent_combineMechUser")
	self.MechUserEnt:SetPos(self:GetPos()  +Vector(27,0.5,-18))
	self.MechUserEnt:SetAngles(Angle(0,0,90))
	self.MechUserEnt:Spawn()
	self.MechUserEnt:SetNetworkedEntity("CombineMechEnt", self)
	constraint.Weld(self.MechRagdoll, self.MechUserEnt, 0, 0, 0, true)
	
	--Shield sprite
	self.ShieldSprite = ents.Create("env_sprite");
	self.ShieldSprite:SetPos(self:GetPos() +Vector(-64,0,50));
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
	
	
	self.JetSound = CreateSound(self,"weapons/rpg/rocket1.wav")
	self.ChargeVortSound = CreateSound(self,"npc/vort/attack_charge.wav")
	
	self.keepUpRightProp.IsMechProp = true
	self.MechRagdoll.IsMechProp = true
	self.IsMechProp = true
	
	
	self.UserSeat = ents.Create("prop_vehicle_prisoner_pod")  
	self.UserSeat:SetKeyValue("vehiclescript","scripts/vehicles/MechSeat.txt")  
	self.UserSeat:SetModel("models/nova/airboat_seat.mdl") 
 
	self.UserSeat:SetAngles(self:GetAngles() +Angle(0,-90,0))
	self.UserSeat:SetKeyValue("limitview", "0")  
	self.UserSeat:SetColor(Color(255,255,255,0))
	self.UserSeat:Spawn()  
	self.UserSeat:SetNotSolid(true)	
	self.UserSeat:GetPhysicsObject():EnableGravity(false)
	
end

-------------------------------------------DAMAGE
function ENT:OnTakeDamage(dmg)
	
	local Damage = 	0

	if dmg:IsExplosionDamage() then
		Damage = dmg:GetDamage() /2
	elseif dmg:GetInflictor():GetClass() == "sent_mechgrenade" then
		Damage = dmg:GetDamage() /10
	else
		Damage = (dmg:GetDamage()) /4
	end

	self.MechHealth = self.MechHealth -Damage

end
-------------------------------------------PhysicsUpdate
function ENT:PhysicsUpdate(physics)
	if !IsValid(self.MechRagdoll) then
		return false
	end
	if IsValid(self.User) then
		if self.User:KeyDown(IN_ATTACK2) && self.ChangeViewDel < CurTime() then		
			self.ChangeViewDel = CurTime() +0.5
			if self.ChangeView == true then
				self.User:SetNetworkedInt("ControlsCombineMech" , 2)
				self.ChangeView = false
			else
				self.User:SetNetworkedInt("ControlsCombineMech" , 1)	
				self.ChangeView = true						
			end
		end		
		if !(self.User:InVehicle()) or !(self.User:Alive()) or (self.enterDel < CurTime() && self.User:KeyDown(IN_USE)) then
			self:RemoveUser()
		end
	end

	if self.MechHealth > 0 then
		if (!IsValid(self.UserSeat)) then
			return
		end
		self.UserSeat:SetPos(self:GetPos())
		self.UserSeat:SetAngles(Angle(0,0,0))
	
		self.Energy = self.Energy +0.04
		if self.Energy > self.MaxEnergy then
			self.Energy = self.MaxEnergy
		end	
	
		if (self.FootStatus > 0 or self.flyHeight > 0) && (self.DotProd >= 0.7 or self.JetPlay == true) then
			self:Hover()
		end
		
		self:UpdateFootStatus()

		if self.UpdateShield < CurTime() then
			self:Shield()
		end

		if (self.FootStatus > 0 or self.flyHeight > 0) && self.keepUpRightCon != NULL  then
			self:AutoMoveFeet()
			self:Stabilize()

			self:DirectHead()
			
			local physObj = self.MechRagdoll:GetPhysicsObjectNum(6)
			physObj:ApplyForceCenter(Vector(0,0,-50))
			physObj = self.MechRagdoll:GetPhysicsObjectNum(12)
			physObj:ApplyForceCenter(Vector(0,0,-50))	

			local vel = self:GetVelocity()
			vel = vel *0.5
			vel.z = vel.z *0.5	
			self:GetPhysicsObject():SetVelocity(vel)		
		end
		
		if IsValid(self.User) then
					
			local moves = false
			local crouching = false
			local flying = false
			
			if self.flyHeight > 0 then
				flying = true
			end
			
			if self.FlashLightEnt != NULL && self.keepUpRightProp != NULL then
				local propAng = self.keepUpRightProp:GetAngles()
				local plyViewAng = self.User:GetAimVector():Angle()
				propAng.p = plyViewAng.p				
				self.FlashLightEnt:SetLocalAngles(Angle(plyViewAng.p,0,0))
			end
			
			if self.User:KeyDown(IN_WALK) then
				self:SetHoverHeight(90 +self.flyHeight)
				crouching = true
			else
				self:SetHoverHeight(130 +self.flyHeight)
			end		
					
			if crouching == false then
				if self.User:KeyDown(IN_FORWARD) then
					self.MoveOffsetX = 40
					moves = true
					
					if flying then
						self.MechRagdoll:GetPhysicsObjectNum(0):ApplyForceCenter(self:GetForward() *1000)
					else
						self.MechRagdoll:GetPhysicsObjectNum(0):ApplyForceCenter(self:GetForward() *100)					
					end
					
				elseif self.User:KeyDown(IN_BACK) then
					self.MoveOffsetX = -30
					moves = true
					
					if flying then
						self.MechRagdoll:GetPhysicsObjectNum(0):ApplyForceCenter(self:GetForward() *-1000)
					else
						self.MechRagdoll:GetPhysicsObjectNum(0):ApplyForceCenter(self:GetForward() *-100)					
					end				
					
				else
					self.MoveOffsetX = 0
				end

				if self.User:KeyDown(IN_MOVELEFT) then
					self.MoveOffsetY = -30
					moves = true
					
					if flying then
						self.MechRagdoll:GetPhysicsObjectNum(0):ApplyForceCenter(self:GetRight() *-1000)
					else
						self.MechRagdoll:GetPhysicsObjectNum(0):ApplyForceCenter(self:GetRight() *-100)				
					end				
					
				elseif self.User:KeyDown(IN_MOVERIGHT) then
					self.MoveOffsetY = 30
					moves = true
					
					if flying then
						self.MechRagdoll:GetPhysicsObjectNum(0):ApplyForceCenter(self:GetRight() *1000)
					else
						self.MechRagdoll:GetPhysicsObjectNum(0):ApplyForceCenter(self:GetRight() *100)						
					end	
					
				else
					self.MoveOffsetY = 0
				end
				
			end

			if self.User:KeyDown(IN_SPEED) && self.changeWepDel < CurTime() then
				self.changeWepDel = CurTime() +0.5
				
				self.wepType = self.wepType +1
				
				if self.wepType > self.maxWeps then
					self.wepType = 1
				end
				
				self.User.mechKey = self.wepType
			end

			--If we used a number key
			if self.User.mechKey != nil && self.User.mechKey != self.wepType && self.User.mechKey <= self.maxWeps && self.User.mechKey > 0 then
				self.wepType = self.User.mechKey
			end
			
			--Flahslight
			if self.User.mechKey != nil && self.User.mechKey == 10 && self.FlashLightDel < CurTime() then
				self.FlashLightDel = CurTime() +0.25
				self.User.mechKey = self.wepType
			
				if self.FlashLightEnt == NULL then
					--Turn it on
					self:EmitSound("buttons/button1.wav")

					local pos = Vector(50,0,-20)
					self.FlashLightEnt = ents.Create("env_projectedtexture")
					self.FlashLightEnt:SetParent(self.keepUpRightProp)
					self.FlashLightEnt:SetLocalPos(pos)
					self.FlashLightEnt:SetLocalAngles(Angle(10,0,0))
					self.FlashLightEnt:SetKeyValue("enableshadows", 1)
					self.FlashLightEnt:SetKeyValue("LightWorld", 1)		
					self.FlashLightEnt:SetKeyValue("farz", 2048)
					self.FlashLightEnt:SetKeyValue("nearz", 65)
					self.FlashLightEnt:SetKeyValue("lightfov", 75)
					self.FlashLightEnt:SetKeyValue("lightcolor", "255 255 255")
					self.FlashLightEnt:Spawn()
					self.FlashLightEnt:Input("SpotlightTexture", NULL, NULL, "effects/flashlight001")		

					self.LeftFlashSprite = ents.Create("env_sprite");
					self.LeftFlashSprite:SetPos(self.keepUpRightProp:GetPos() +(self.keepUpRightProp:GetForward() *20) +(self.keepUpRightProp:GetRight() *-25) +(self.keepUpRightProp:GetUp() *-5))	
					self.LeftFlashSprite:SetKeyValue("renderfx", "14")
					self.LeftFlashSprite:SetKeyValue("model", "sprites/glow1.vmt")
					self.LeftFlashSprite:SetKeyValue("scale","1.0")
					self.LeftFlashSprite:SetKeyValue("spawnflags","1")
					self.LeftFlashSprite:SetKeyValue("angles","0 0 0")
					self.LeftFlashSprite:SetKeyValue("rendermode","9")
					self.LeftFlashSprite:SetKeyValue("renderamt","255")
					self.LeftFlashSprite:SetKeyValue("rendercolor", "240 240 170")				
					self.LeftFlashSprite:Spawn()
					self.LeftFlashSprite:SetParent(self.keepUpRightProp)	
					
					self.RightFlashSprite = ents.Create("env_sprite");
					self.RightFlashSprite:SetPos(self.keepUpRightProp:GetPos() +(self.keepUpRightProp:GetForward() *20) +(self.keepUpRightProp:GetRight() *25) +(self.keepUpRightProp:GetUp() *-5))	
					self.RightFlashSprite:SetKeyValue("renderfx", "14")
					self.RightFlashSprite:SetKeyValue("model", "sprites/glow1.vmt")
					self.RightFlashSprite:SetKeyValue("scale","1.0")
					self.RightFlashSprite:SetKeyValue("spawnflags","1")
					self.RightFlashSprite:SetKeyValue("angles","0 0 0")
					self.RightFlashSprite:SetKeyValue("rendermode","9")
					self.RightFlashSprite:SetKeyValue("renderamt","255")
					self.RightFlashSprite:SetKeyValue("rendercolor", "240 240 170")				
					self.RightFlashSprite:Spawn()
					self.RightFlashSprite:SetParent(self.keepUpRightProp)		
				
				else					
					--Turn it off
					self:EmitSound("buttons/button4.wav")			
					self.FlashLightEnt:Remove()
					self.FlashLightEnt = NULL
					self.LeftFlashSprite:Remove()
					self.RightFlashSprite:Remove()
				end			
			end
					
			--Grav probe exploit fix
			if self.GravProbeSpawned == true && self.wepType == 6 && self.User:KeyDown(IN_ATTACK) then
				local tracedata = {}
				tracedata.start = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +Vector(0,0,-20)
				tracedata.endpos = tracedata.start +(self.User:GetAimVector() *400)
				tracedata.filter =  { self, self.MechRagdoll, self.keepUpRightProp,self.TempMissile}
				local trace = util.TraceLine(tracedata)
				
				self.TempMissile.DestPos = trace.HitPos
				self.TempMissile:GetPhysicsObject():SetVelocity(self.TempMissile:GetVelocity() *0.9)
			elseif (!(self.User:KeyDown(IN_ATTACK)) or self.wepType != 6) && self.GravProbeSpawned == true then
				self.GravProbeSpawned = false
				self.TempMissile.DestPos = NULL
				self.TempMissile.ArmTime = CurTime() +2
				self.GravProbeDel = CurTime() +4
				self.TempMissile:GetPhysicsObjectNum(0):ApplyForceCenter(self.User:GetAimVector() *1000)
				self:EmitSound("weapons/physcannon/superphys_small_zap"..math.random(1,4)..".wav",75,math.random(80,120))	
			end		
			
			local flyingWeps = flying
			if GetConVar("sv_combinemech_allowwepswhileflying"):GetBool() then -- There's a better way to do this but its fine lmao
				flyingWeps = false
			end
			if self.User:KeyDown(IN_ATTACK) && !flyingWeps && self.keepUpRightCon != NULL && self.GravProbeSpawned == false && self.UseMissileStormDel < CurTime() then
				if self.GravProbeSpawned == true then
					self.GravProbeSpawned = false
					self.TempMissile.DestPos = NULL
					self.TempMissile.ArmTime = CurTime() +2
					self.GravProbeDel = CurTime() +2
					self.TempMissile:GetPhysicsObjectNum(0):ApplyForceCenter(self.User:GetAimVector() *1000)
				end
				
				
				--I reallly miss "switch case" in these situations 
				
				--Missile
				if self.wepType == 1 && self.ShootRockedDel < CurTime() then
					self.ShootRockedDel = CurTime() +1
					self:ShootRocket()
					
				--Grenade
				elseif self.wepType == 2 && self.ShootGrenadeDel < CurTime() && self.GrenadeHeat < 10 then 
					self.ShootGrenadeDel = CurTime() +0.25
					self.GrenadeHeat = self.GrenadeHeat +4
					self:ShootGrenade()
					
					if self.GrenadeHeat > 10 then
						self.ShootGrenadeDel = CurTime() +4
						self:EmitSound("combine mech/OverHeat.wav",85,math.random(80,120))	
					end	

				--Missile storm
				elseif self.wepType == 3 && self.ShootMissileStormDel < CurTime() then 
					self.UseMissileStormDel = CurTime() +1
					self.ShootMissileStormDel = CurTime() +20
					
					local tracedata = {}
					tracedata.start = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +Vector(0,0,-20)
					tracedata.endpos = tracedata.start +(self.User:GetAimVector() *999999)
					tracedata.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
					local trace = util.TraceLine(tracedata)
					
					self.MissileStormDestPos = trace.HitPos
					
				--Machine gun /turret	
				elseif self.wepType == 4 && self.MachineGunDel < CurTime() && self.GunHeatDel < CurTime() then 
					self.MachineGunDel = CurTime() +0.05
					
					if self.MachineGunHeat > 0 then
						self:ShootBullet()
					end
					
					self.MachineGunHeat = self.MachineGunHeat -5
					
					
					if self.MachineGunHeat <= 0 then
						self.GunHeatDel = CurTime() +2
						self:EmitSound("combine mech/OverHeat.wav",85,math.random(80,120))							
					end
				
				--Screamer
				elseif self.wepType == 5 && self.ScreamerDel < CurTime() then 
					self.ScreamerDel = CurTime() +15
					self.ScreamerFireDel = CurTime() +2
					self.ShouldScreamer = true
					self:EmitSound("combine mech/ScreamerChargeUp.wav",100,math.random(80,120))	
				
				--Grav probe
				elseif self.wepType == 6 && self.GravProbeDel < CurTime() && self.GravProbeSpawned == false then 
					self.GravProbeSpawned = true
					self:ShootGravProbe()
					self:EmitSound("weapons/physcannon/energy_sing_flyby"..math.random(1,2)..".wav",75,math.random(80,120))	
				
				--Laser
				elseif self.wepType == 7 && self.LaserUseDel < CurTime() && self.HasUsedLaser == false then 		
					self.HasUsedLaser = true
					self.LaserUseDel = CurTime() +4
					self.LaserShootDel = CurTime() +1
					self.ChargeVortSound:Stop()
					self.ChargeVortSound:Play()					
				end
							
			end
			
			--Waiting for the mech charges up before we launch the screamer
			if self.ScreamerFireDel < CurTime() && self.ShouldScreamer == true then
				self:ShootScreamer()
				self.ShouldScreamer = false
			end
			
			if self.LaserShootDel > CurTime() then
				local pitch = 100 +((1 -(self.LaserShootDel -CurTime())) *100) 
				self.ChargeVortSound:ChangePitch(pitch,0)
			end
			
			--Waiting for mech laser charge up
			if self.LaserShootDel < CurTime() && self.HasUsedLaser == true then
				self.HasUsedLaser = false
				
				self.ChargeVortSound:Stop()
				self:EmitSound("npc/vort/attack_shoot.wav",100,math.random(80,120))	
				
				local sourcePos = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +self.keepUpRightProp:GetUp() *-20
				
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
				
				self:FireBullets(bullet)	
							
				local effectdata = EffectData()
				effectdata:SetStart(sourcePos)
				effectdata:SetOrigin(trace.HitPos)
				util.Effect("SakLaserTracer", effectdata)			
			end
		
			
			--If the mech is moving we will make the mech pelvis face the view direction
			if moves == true or self.flyHeight > 0 then
				self:DirectMech()
			end		
			
			--Launching missiles for a period of time
			if self.UseMissileStormDel > CurTime() && self.NextMissileStorm < CurTime() then
				self:ShootMissileStorm()
				self.NextMissileStorm = CurTime() +0.05
			end


		else
			self:SetHoverHeight(130 +self.flyHeight)	

			--Launching the Grav Probe when we release the primary fire button
			if self.GravProbeSpawned == true then
				self.GravProbeSpawned = false
				self.TempMissile.DestPos = NULL
				self.TempMissile.ArmTime = CurTime() +2
				self.GravProbeDel = CurTime() +2
				self.TempMissile:GetPhysicsObjectNum(0):ApplyForceCenter(self.User:GetAimVector() *1000)
			end					
		end
		
		--Jet effect
		if self.flyHeight > 0 then
			self.JetTimer = CurTime() +1
		
			if self.JetPlay == false then
				self.JetPlay = true
				self.JetSound:Play()
			end	
		
			--Changine the pitch depending on the height
			--Things like this is really effective actually because it's ! just a cool effect
			--it gives feedback to the player telling how high he's flying.
			--No stupid hud elements needed. Something to think about.... i made a hud element for it anyway.
			local pitch = 50 +((self.flyHeight /self.maxFlyHeight) *150)
			self.JetSound:ChangePitch(pitch, 0)
			
			local pos = self.MechRagdoll:GetPos() +self:GetForward() *-11.5 +self:GetUp() *-10  
			local ang = self:GetAngles() 

			--Jet fart
			local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetAngles(ang)
			effectdata:SetScale(1)
			util.Effect("MuzzleEffect", effectdata)	

			pos = self.MechRagdoll:GetPos() +self:GetForward() *-30 +self:GetUp() *-2  			
			local effectdata2 = EffectData()
			effectdata2:SetOrigin(pos)
			effectdata2:SetAngles(ang)
			effectdata2:SetScale(1)
			util.Effect("MuzzleEffect", effectdata2)
			
		else
			--Stopping the jet sound if we aren't flying
			self.JetPlay = false
			self.JetSound:Stop()
		end	
		
		
		--FootSounds
		if (self.LastFootStatus == 2 or self.LastFootStatus == 1) && (self.FootStatus == 3 or self.FootStatus == 0) && self.DotProd >= 0.7 then
			self:EmitSound("npc/dog/dog_footstep_run"..math.random(1,8)..".wav",75,math.random(80,120))
			util.ScreenShake(self:GetPos(),10,100,0.55,600)
		end
		
		self.LastFootStatus = self.FootStatus
	end
end
-------------------------------------------THINK
function ENT:Think()
	
	--The ent isn't a part of the ragdoll so i have to check if someone removed it
	--If it is removed then ent will remove itself
	if !self.MechRagdoll or self.MechRagdoll == NULL or self.MechRagdoll == nil then
		self:Remove()
	end

	--Water is bad!
	--Why would i make some kind of silly submarine mode?
	if self:WaterLevel() >= 1 then
		self.MechHealth = self.MechHealth -1
	end
	
	if self.MechHealth > 0 then		
		
		self:GetPhysicsObject():Wake()
		
		--Fixing jet smoke
		if self.IsUsingJet == false && self.flyHeight > 0 then
			self.IsUsingJet = true
			self:SetNetworkedBool("IsFlying", true)
		elseif self.IsUsingJet == true && self.flyHeight == 0 then
			self.IsUsingJet = false
			self:SetNetworkedBool("IsFlying", false)		
		end
		
		
		--Updating player networked vals for the hud
		if IsValid(self.User) then
		
			--I wonder if i should check if the variable have changed before i set the networked vals.
			--I believe that the server doesn't send clients the same value if it haven't changed.
		
			local percent = 0

			percent = self.MechHealth /self.MechMaxHealth
			self.User:SetNetworkedFloat("combineMechHealth", percent)

			percent = self.Energy /self.MaxEnergy
			self.User:SetNetworkedFloat("combineMechShield", percent)
			
			self.User:SetNetworkedInt("combineMechWeapon", self.wepType)
			self.User:SetNetworkedInt("combineMechFlyHeight", self.flyHeight)
			

			--Weapon heat
			if self.wepType == 1 then
				percent = (1 -(self.ShootRockedDel -CurTime())) 
			elseif self.wepType == 2 then
				percent = 1 -(self.GrenadeHeat /10)
			elseif self.wepType == 3 then
				percent = (20 -(self.ShootMissileStormDel -CurTime())) /20
			elseif self.wepType == 4 then
				percent = self.MachineGunHeat /100
			elseif self.wepType == 5 then
				percent = (15 -(self.ScreamerDel -CurTime())) /15
			elseif self.wepType == 6 then
				percent = (4 -(self.GravProbeDel -CurTime())) /4
				
				if self.GravProbeSpawned == true then
					percent = 0
				end
			elseif self.wepType == 7 then	
				percent = (4 -(self.LaserUseDel -CurTime())) /4
			end
			
			percent = math.Clamp(percent, 0, 1)
			self.User:SetNetworkedInt("combineMechHeat", percent)
		else
			
			self.HasUsedLaser = false 
			self.ShouldScreamer = false
			--Removing the flash light if the player exited the mech
			if self.FlashLightEnt != NULL then
				self.FlashLightEnt:Remove()
				self.FlashLightEnt = NULL
				self.LeftFlashSprite:Remove()
				self.RightFlashSprite:Remove()				
			end
			
		
			--Autorepair
			if self.MechHealth < self.MechMaxHealth && self.MechHealth > 0 then
				self.MechHealth = self.MechHealth +0.2
	
				local percent = self.MechHealth /self.MechMaxHealth

				
				--Have to cycle through the different damage levels in reverse D:>
				--Could have done this in a func.
				if self.DamageLevel == 4 && percent > 0.1 then
					self.DamageLevel = 3	
					
					local pos = self.keepUpRightProp:GetForward() *-60 +self.keepUpRightProp:GetUp() *20
					self.SmokeEffect:Remove()
					
					self.SmokeEffect = ents.Create("env_smokestack")
					self.SmokeEffect:SetPos(self.keepUpRightProp:GetPos() +pos)
					self.SmokeEffect:SetKeyValue("InitialState", "1")
					self.SmokeEffect:SetKeyValue("WindAngle", "0 0 0")
					self.SmokeEffect:SetKeyValue("WindSpeed", "0")
					self.SmokeEffect:SetKeyValue("rendercolor", "10 10 10")
					self.SmokeEffect:SetKeyValue("renderamt", "170")
					self.SmokeEffect:SetKeyValue("SmokeMaterial", "particle/smokesprites_0001.vmt")
					self.SmokeEffect:SetKeyValue("BaseSpread", "10")
					self.SmokeEffect:SetKeyValue("SpreadSpeed", "5")
					self.SmokeEffect:SetKeyValue("Speed", "100")
					self.SmokeEffect:SetKeyValue("StartSize", "50")
					self.SmokeEffect:SetKeyValue("EndSize", "10")
					self.SmokeEffect:SetKeyValue("roll", "10")
					self.SmokeEffect:SetKeyValue("Rate", "10")
					self.SmokeEffect:SetKeyValue("JetLength", "50")
					self.SmokeEffect:SetKeyValue("twist", "5")

					//Spawn smoke
					self.SmokeEffect:Spawn()
					self.SmokeEffect:SetParent(self)
					self.SmokeEffect:Activate()						
				elseif self.DamageLevel == 3 && percent > 0.25 then
					self.DamageLevel = 2

					local pos = self.keepUpRightProp:GetForward() *-60 +self.keepUpRightProp:GetUp() *20
					self.SmokeEffect:Remove()
					
					self.SmokeEffect = ents.Create("env_smokestack")
					self.SmokeEffect:SetPos(self.keepUpRightProp:GetPos() +pos)
					self.SmokeEffect:SetKeyValue("InitialState", "1")
					self.SmokeEffect:SetKeyValue("WindAngle", "0 0 0")
					self.SmokeEffect:SetKeyValue("WindSpeed", "0")
					self.SmokeEffect:SetKeyValue("rendercolor", "100 100 100")
					self.SmokeEffect:SetKeyValue("renderamt", "170")
					self.SmokeEffect:SetKeyValue("SmokeMaterial", "particle/smokesprites_0001.vmt")
					self.SmokeEffect:SetKeyValue("BaseSpread", "10")
					self.SmokeEffect:SetKeyValue("SpreadSpeed", "5")
					self.SmokeEffect:SetKeyValue("Speed", "100")
					self.SmokeEffect:SetKeyValue("StartSize", "50")
					self.SmokeEffect:SetKeyValue("EndSize", "10")
					self.SmokeEffect:SetKeyValue("roll", "10")
					self.SmokeEffect:SetKeyValue("Rate", "10")
					self.SmokeEffect:SetKeyValue("JetLength", "50")
					self.SmokeEffect:SetKeyValue("twist", "5")

					//Spawn smoke
					self.SmokeEffect:Spawn()
					self.SmokeEffect:SetParent(self)
					self.SmokeEffect:Activate()	
					
				elseif self.DamageLevel == 2 && percent > 0.5 then
					self.DamageLevel = 1

					local pos = self.keepUpRightProp:GetForward() *-60 +self.keepUpRightProp:GetUp() *20
					self.SmokeEffect:Remove()
					
					self.SmokeEffect = ents.Create("env_smokestack")
					self.SmokeEffect:SetPos(self.keepUpRightProp:GetPos() +pos)
					self.SmokeEffect:SetKeyValue("InitialState", "1")
					self.SmokeEffect:SetKeyValue("WindAngle", "0 0 0")
					self.SmokeEffect:SetKeyValue("WindSpeed", "0")
					self.SmokeEffect:SetKeyValue("rendercolor", "200 200 200")
					self.SmokeEffect:SetKeyValue("renderamt", "170")
					self.SmokeEffect:SetKeyValue("SmokeMaterial", "particle/smokesprites_0001.vmt")
					self.SmokeEffect:SetKeyValue("BaseSpread", "10")
					self.SmokeEffect:SetKeyValue("SpreadSpeed", "5")
					self.SmokeEffect:SetKeyValue("Speed", "100")
					self.SmokeEffect:SetKeyValue("StartSize", "50")
					self.SmokeEffect:SetKeyValue("EndSize", "10")
					self.SmokeEffect:SetKeyValue("roll", "10")
					self.SmokeEffect:SetKeyValue("Rate", "10")
					self.SmokeEffect:SetKeyValue("JetLength", "50")
					self.SmokeEffect:SetKeyValue("twist", "5")

					//Spawn smoke
					self.SmokeEffect:Spawn()
					self.SmokeEffect:SetParent(self)
					self.SmokeEffect:Activate()	
					
				elseif self.DamageLevel == 1 && percent > 0.75 then
					self.DamageLevel = 0
					self.SmokeEffect:Remove()
					self.SmokeEffect = NULL
				end
			end				
		end
		
		--Giving ammo to weapons or "cooling" them down
		self.MachineGunHeat = self.MachineGunHeat +10
		if self.MachineGunHeat > 100 then
			self.MachineGunHeat = 100
		end
		
		self.GrenadeHeat = self.GrenadeHeat -1
		if self.GrenadeHeat < 0 then
			self.GrenadeHeat = 0
		end
		
		--Making npc's hate the mech
		--Don't have to update this too often
		

		if self.NPCTarget != NULL && self.UpdateMechAsTargetDel < CurTime() then
			self.UpdateMechAsTargetDel = CurTime() +2
			for k,v in pairs(ents.FindByClass("npc_*")) do
				if (string.find(v:GetClass(), "npc_antlionguard")) or (string.find(v:GetClass(), "npc_combine*")) or (string.find(v:GetClass(), "*zombie*")) or (string.find(v:GetClass(), "npc_helicopter")) or (string.find(v:GetClass(), "npc_manhack")) or (string.find(v:GetClass(), "npc_metropolice")) or (string.find(v:GetClass(), "npc_rollermine")) or (string.find(v:GetClass(), "npc_strider")) or (string.find(v:GetClass(), "npc_turret*")) or (string.find(v:GetClass(), "npc_hunter")) or (string.find(v:GetClass(), "antlion")) then
						v:Fire("setrelationship", "npc_bullseye D_HT 5")
				end
			end			
		end

		--Setting shield sprite col
		if self.ShieldSprite != NULL then
			local rCol = 2.5 *(self.MaxEnergy -self.Energy)
			local gCol = 2.5 *self.Energy
			local bCol = 0
			
			if self.Energy < 0 then
				rCol = math.random(0,50)
				gCol = math.random(0,50)
				bCol = math.random(0,255)
			end
			
			self.ShieldSprite:SetKeyValue("rendercolor", rCol.." "..gCol.." "..bCol)
		end
		
		--Increasing the fly height if the player is pressing jump
		--It's placed here since it doesn't need to be updated so often
		if self.User != NULL && IsValid(self.User) && self.User:KeyDown(IN_JUMP) then
			self.flyHeight = self.flyHeight +20
			
			if self.flyHeight > self.maxFlyHeight then
				self.flyHeight = self.maxFlyHeight
			end
			
		else			
			if self.flyHeight < 0 then
				self.flyHeight = 0
			end	
		end

		self.DotProd = self:GetUp():DotProduct(Vector(0,0,1))
		self:Steady()
		
		--If the shield goes up after being down we will play a fancy sound and set the energy to 25%
		if self.ShieldDown == true && self.Energy > 0 then
			self.ShieldDown = false
			self.Energy = 25
			self:EmitSound("combine mech/ShieldUp.wav",85,math.random(80,120))	
		end
	else
		--This happens when the mech have died
		self.Energy = 0
		self.JetSound:Stop()
		
		if self.IsUsingJet == true then
			self.IsUsingJet = false
			self:SetNetworkedBool("IsFlying", false)		
		end		
		
		if self.keepUpRightCon != NULL then
			self.keepUpRightCon:Remove()
			self.keepUpRightCon = NULL
		end
		
		--Making NPC's stop shooting at it
		if self.NPCTarget != NULL then
			self.NPCTarget:Remove()
			self.NPCTarget = NULL
			self.NPCTarget2:Remove()
			self.NPCTarget2 = NULL
		end
		
		--Removing the shield sprite
		if self.ShieldSprite != NULL then
			self.ShieldSprite:Remove()
			self.ShieldSprite = NULL
		end

		SafeRemoveEntity(self.VJ_Bullseye1)
		SafeRemoveEntity(self.VJ_Bullseye2)
		
		--Setting hud hp to 0
		if self.User != NULL then
			self.User:SetNetworkedFloat("combineMechHealth", 0)
		end
	
	end
	
	--Health effects
	local percent = self.MechHealth /self.MechMaxHealth
	
	--Calculating by percent so people can change the maxHP and this would still work
	if self.DamageLevel == 0 && percent < 0.75 then
		self.DamageLevel = 1
		local pos = self.keepUpRightProp:GetForward() *-60 +self.keepUpRightProp:GetUp() *20
		self.SmokeEffect = ents.Create("env_smokestack")
		self.SmokeEffect:SetPos(self.keepUpRightProp:GetPos() +pos)
		self.SmokeEffect:SetKeyValue("InitialState", "1")
		self.SmokeEffect:SetKeyValue("WindAngle", "0 0 0")
		self.SmokeEffect:SetKeyValue("WindSpeed", "0")
		self.SmokeEffect:SetKeyValue("rendercolor", "200 200 200")
		self.SmokeEffect:SetKeyValue("renderamt", "170")
		self.SmokeEffect:SetKeyValue("SmokeMaterial", "particle/smokesprites_0001.vmt")
		self.SmokeEffect:SetKeyValue("BaseSpread", "10")
		self.SmokeEffect:SetKeyValue("SpreadSpeed", "5")
		self.SmokeEffect:SetKeyValue("Speed", "100")
		self.SmokeEffect:SetKeyValue("StartSize", "50")
		self.SmokeEffect:SetKeyValue("EndSize", "10")
		self.SmokeEffect:SetKeyValue("roll", "10")
		self.SmokeEffect:SetKeyValue("Rate", "10")
		self.SmokeEffect:SetKeyValue("JetLength", "50")
		self.SmokeEffect:SetKeyValue("twist", "5")

		//Spawn smoke
		self.SmokeEffect:Spawn()
		self.SmokeEffect:SetParent(self)
		self.SmokeEffect:Activate()	
	
	elseif self.DamageLevel == 1 && percent < 0.5 then 
		self.DamageLevel = 2
		
		local pos = self.keepUpRightProp:GetForward() *-60 +self.keepUpRightProp:GetUp() *20
		self.SmokeEffect:Remove()
		
		self.SmokeEffect = ents.Create("env_smokestack")
		self.SmokeEffect:SetPos(self.keepUpRightProp:GetPos() +pos)
		self.SmokeEffect:SetKeyValue("InitialState", "1")
		self.SmokeEffect:SetKeyValue("WindAngle", "0 0 0")
		self.SmokeEffect:SetKeyValue("WindSpeed", "0")
		self.SmokeEffect:SetKeyValue("rendercolor", "100 100 100")
		self.SmokeEffect:SetKeyValue("renderamt", "170")
		self.SmokeEffect:SetKeyValue("SmokeMaterial", "particle/smokesprites_0001.vmt")
		self.SmokeEffect:SetKeyValue("BaseSpread", "10")
		self.SmokeEffect:SetKeyValue("SpreadSpeed", "5")
		self.SmokeEffect:SetKeyValue("Speed", "100")
		self.SmokeEffect:SetKeyValue("StartSize", "50")
		self.SmokeEffect:SetKeyValue("EndSize", "10")
		self.SmokeEffect:SetKeyValue("roll", "10")
		self.SmokeEffect:SetKeyValue("Rate", "10")
		self.SmokeEffect:SetKeyValue("JetLength", "50")
		self.SmokeEffect:SetKeyValue("twist", "5")

		//Spawn smoke
		self.SmokeEffect:Spawn()
		self.SmokeEffect:SetParent(self)
		self.SmokeEffect:Activate()	

	elseif self.DamageLevel == 2 && percent < 0.25 then 
		self.DamageLevel = 3
		
		local pos = self.keepUpRightProp:GetForward() *-60 +self.keepUpRightProp:GetUp() *20
		self.SmokeEffect:Remove()
		
		self.SmokeEffect = ents.Create("env_smokestack")
		self.SmokeEffect:SetPos(self.keepUpRightProp:GetPos() +pos)
		self.SmokeEffect:SetKeyValue("InitialState", "1")
		self.SmokeEffect:SetKeyValue("WindAngle", "0 0 0")
		self.SmokeEffect:SetKeyValue("WindSpeed", "0")
		self.SmokeEffect:SetKeyValue("rendercolor", "10 10 10")
		self.SmokeEffect:SetKeyValue("renderamt", "170")
		self.SmokeEffect:SetKeyValue("SmokeMaterial", "particle/smokesprites_0001.vmt")
		self.SmokeEffect:SetKeyValue("BaseSpread", "10")
		self.SmokeEffect:SetKeyValue("SpreadSpeed", "5")
		self.SmokeEffect:SetKeyValue("Speed", "100")
		self.SmokeEffect:SetKeyValue("StartSize", "50")
		self.SmokeEffect:SetKeyValue("EndSize", "10")
		self.SmokeEffect:SetKeyValue("roll", "10")
		self.SmokeEffect:SetKeyValue("Rate", "10")
		self.SmokeEffect:SetKeyValue("JetLength", "50")
		self.SmokeEffect:SetKeyValue("twist", "5")

		//Spawn smoke
		self.SmokeEffect:Spawn()
		self.SmokeEffect:SetParent(self)
		self.SmokeEffect:Activate()	
		
	elseif self.DamageLevel == 3 && percent < 0.1 then 	
		self.DamageLevel = 4
		
		self.SmokeEffect:Remove()
		local pos = self.keepUpRightProp:GetForward() *-60 +self.keepUpRightProp:GetUp() *20		
		self.SmokeEffect = ents.Create("env_fire_trail")
		self.SmokeEffect:SetPos(self.keepUpRightProp:GetPos() +pos)
		self.SmokeEffect:Spawn()
		self.SmokeEffect:SetParent(self.keepUpRightProp)		
	
	end
	
	if percent < 0.75 && percent > 0 then
		local maxPer = (percent *100) /2
	
		local useEff = math.random(0,maxPer)
	
		if useEff == 1 then
			local bonepos1, boneang1 = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(math.random(0,15))) 
			local effectdata = EffectData()
			effectdata:SetStart(bonepos1)
			effectdata:SetOrigin(bonepos1)
			effectdata:SetScale(1)
			util.Effect("StunstickImpact", effectdata)	

			self:EmitSound("ambient/energy/zap"..math.random(1,9)..".wav",75,math.random(80,120))				
		end
	
	end
	

	
	
end
-------------------------------------------ON REMOVE
function ENT:OnRemove()

	--Remove the mech ragdoll if it isn't already removed
	if self.MechRagdoll && self.MechRagdoll != NULL && self.MechRagdoll != nil then
		self.MechRagdoll:Remove()
	end
	
	self.UserSeat:Remove()
	
	--Removing the saw blade
	self.keepUpRightProp:Remove()

	--Removing the control station
	if self.MechUserEnt && self.MechUserEnt != NULL && self.MechUserEnt != nil then	
		self.MechUserEnt:Remove()
	end
	
	--Removing the npc targets
	if self.NPCTarget != NULL then
		self.NPCTarget:Remove()
		self.NPCTarget = NULL
		self.NPCTarget2:Remove()
		self.NPCTarget2 = NULL
	end	
	
	--Stopping the jet sound if the mech were flying when it was removed
	self.JetSound:Stop()
end

-----------------------------------------------------------------------MISC FUNCS

--Planned on adding more funcs so people could make theyr own AI for it but
--I'm just getting too tired of this project. =[
--I just want to release it.
--Maybe i will add some neat funcs in an update.
--Somthing like this would be handy    MoveTo(Pos), SetTarget(ent), SetWeapon(int), Engage(), GoToTarget(ent)

--PUBLIC FUNCS

--Sets the hover height
--0 = on ground
-- 0< = flying
function ENT:SetHoverHeight(newHeight)
	self.hoverHeight = newHeight
end

--How much thrust you want it to use
function ENT:SetHoverMultiplier(newMP)
	self.hoverMultiplier = newMP
end

--Sets a player user
function ENT:SetUser(ply)

	self.enterDel = CurTime() +1

	if self.User != NULL then
		self:removeUser()
	end		
	
	self.User = ply
	self.User:EnterVehicle(self.UserSeat)
	self.User:SetColor(Color(255, 255, 255, 0))
	local percent = 0

	percent = self.MechHealth /self.MechMaxHealth
	self.User:SetNetworkedFloat("combineMechHealth", percent)
	
	percent = self.Energy /self.MaxEnergy
	self.User:SetNetworkedFloat("combineMechShield", percent)
	self.User:SetNetworkedInt("combineMechWeapon", self.wepType)
	self.User:SetNetworkedInt("combineMechFlyHeight", self.flyHeight)
	self.User:SetNetworkedInt("combineMechHeat", 1)	
	
	self.User:SetNetworkedInt("ControlsCombineMech" , 1)
	self.User:SetNetworkedEntity("CombineMechEnt", self)	
	self.User:SetNetworkedEntity("CombineMechSawEnt", self.keepUpRightProp)
	self.User.mechKey = self.wepType
	
	/*local viewAng = self:GetForward():Angle()
	viewAng.y = viewAng.y +90
	viewAng.r = 0								
	self.User:SnapEyeAngles(viewAng)*/
	
	--Two targets for NPC's to shoot
	
	if self.NPCTarget == NULL then
		self.NPCTarget = ents.Create("npc_bullseye")   
		self.NPCTarget:SetPos(self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +self.keepUpRightProp:GetUp() *-20)
		self.NPCTarget:SetParent(self.keepUpRightProp)  
		self.NPCTarget:SetKeyValue("health","9999")  
		self.NPCTarget:SetKeyValue("spawnflags","256") 
		self.NPCTarget:SetNotSolid(true)  
		self.NPCTarget:Spawn()  
		self.NPCTarget:Activate() 		

		self.NPCTarget2 = ents.Create("npc_bullseye")   
		self.NPCTarget2:SetPos(self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *-20)
		self.NPCTarget2:SetParent(self.keepUpRightProp)  
		self.NPCTarget2:SetKeyValue("health","9999")  
		self.NPCTarget2:SetKeyValue("spawnflags","256") 
		self.NPCTarget2:SetNotSolid(true)  
		self.NPCTarget2:Spawn()  
		self.NPCTarget2:Activate()

		if file.Exists("lua/autorun/vj_base_autorun.lua","GAME") == true then
			SafeRemoveEntity(self.VJ_Bullseye1)
			SafeRemoveEntity(self.VJ_Bullseye2)
			for i = 1,2 do
				local bullseye = ents.Create("obj_vj_bullseye")
				bullseye:SetModel("models/hunter/plates/plate.mdl")
				bullseye:SetPos(i == 1 && self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +self.keepUpRightProp:GetUp() *-20 or self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *-20)
				bullseye:SetParent(self.keepUpRightProp)
				bullseye:Spawn()
				bullseye:SetNotSolid(true)
				bullseye:SetNoDraw(true)
				bullseye:DrawShadow(false)
				bullseye:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				bullseye.VJ_NPC_Class = self.User.VJ_NPC_Class
				self:DeleteOnRemove(bullseye)
				if i == 1 then
					self.VJ_Bullseye1 = bullseye
				elseif i == 2 then
					self.VJ_Bullseye2 = bullseye
				end
			end
		end
	end

end

--This just checks if someone already is controlling the mech before entering it
function ENT:EnterMech(ply)
	
	if self.User == NULL then
		self:SetUser(ply)	
		return true
	end

	return false
end


function ENT:RemoveUser()
	if self.User != NULL then
		self.User:ExitVehicle()
				
		self.User:SetColor(Color(255, 255, 255, 255))
		self.User:SetPos(self:GetPos() +self:GetForward() *70 +self:GetUp() *-80)
		self.User:SetNetworkedInt("ControlsCombineMech" , 0)
		self.User = NULL
	end
end

--PRIVATE FUNCS
function ENT:Hover()

	if !self.MechRagdoll or self.MechRagdoll == NULL or self.MechRagdoll == nil then return false end
	
	--Getting the distance between the mech and the ground
	local hoverHeight = self.hoverHeight
	local trace = {}
	trace.start = self.MechRagdoll:GetPos()
	trace.endpos = self.MechRagdoll:GetPos() +Vector(0,0,(hoverHeight *-1))
	trace.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
	local tr = util.TraceLine(trace)	
	
	if tr.Hit then
		local distance = self.MechRagdoll:GetPos():Distance(tr.HitPos)
		local force = math.Clamp((hoverHeight -distance) *self.hoverMultiplier,0,50)
		
		local diff = ((self.flyHeight +130) -distance)
		
		if diff > 100 then
			self.flyHeight = distance -130
			
			if self.flyHeight < 1 then self.flyHeight = 1 end
		end
		
		--Max thrust is 50
		--Maybe i should use Mod() instead of this.
		if force > 50 then
			force = 50
		end
		
		--Decreasing the hover height if the player isn't pressing the jump button or if there is no player controlling it

		if (self.User && self.User != nil && self.User != NULL && IsValid(self.User) && !(self.User:KeyDown(IN_JUMP))) or self.User == NULL then
			self.flyHeight = self.flyHeight -2
			
			if self.flyHeight < 0 then
				self.flyHeight = 0
			end
		end
		
		--Applying the force
		self.MechRagdoll:GetPhysicsObjectNum(0):ApplyForceCenter(Vector(0,0,50) *force)
	end
end

--Checks if there is something under the feet
function ENT:UpdateFootStatus()

	if !self.MechRagdoll or self.MechRagdoll == NULL or self.MechRagdoll == nil then return false end
	
	-- 0 None of the legs are touching the ground
	-- 1 Only left foot
	-- 2 Only right foot
	-- 3 Both are touching the ground
	
	self.FootStatus = 0
	local bonepos1, boneang1 = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(6)) 
	local bonepos2, boneang2 = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(12)) 
	
	local trace = {}
	trace.start = bonepos1
	trace.endpos = bonepos1 +Vector(0,0,-30)
	trace.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
	local tr = util.TraceLine(trace)		
	
	if tr.Hit then
		self.FootStatus = 1
	end

	local trace = {}
	trace.start = bonepos2
	trace.endpos = bonepos2 +Vector(0,0,-30)
	trace.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
	local tr = util.TraceLine(trace)		
	
	if tr.Hit && self.FootStatus == 1 then
		self.FootStatus = 3
	elseif tr.Hit then
		self.FootStatus = 2
	end
	
end

--Automatically moves the feet so they don't stretch out too much
--This function really needs to be improved, i just don't know how to make the movement better without animations
function ENT:AutoMoveFeet()
	
	if !self.MechRagdoll or self.MechRagdoll == NULL or self.MechRagdoll == nil then return false end
	
	local offset = Vector(0,0,0)
	offset.x = self.MoveOffsetX
	offset.y = self.MoveOffsetY
	
	if self.User == NULL then
		offset = Vector(0,0,0)
	end


	local vecHeight = Vector(0,0,-140)
	
	if self.hoverHeight != 130 then
		vecHeight = Vector(0,0,-110)
	end

	--Left side
	local CheckPos = self:GetPos() +(self:GetRight() *-60) +(self:GetForward() *offset.x) +(self:GetRight() *offset.y) +vecHeight
	
	local bonepos1, boneang1 = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(6)) 
	self.LeftMoveDist = bonepos1:Distance(CheckPos)
	self.LeftMoveDir = (CheckPos -bonepos1):GetNormalized()
	self.LeftMoveDir.z = 0
	
	
	
	--Right side
	CheckPos = self:GetPos() +(self:GetRight() *60) +(self:GetForward() *offset.x) +(self:GetRight() *offset.y) +vecHeight	

	local bonepos2, boneang2 = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(12)) 
	self.RightMoveDist = bonepos2:Distance(CheckPos)
	self.RightMoveDir = (CheckPos -bonepos2):GetNormalized()
	self.RightMoveDir.z = 0
	

	
	if self.FootStatus > 0 then

		--Left foot
		if self.FootStatus == 3 or self.FootStatus == 1 then
		
			if self.DontMoveLeftDel < CurTime() then			
				local bonepos, boneang = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(6)) 
			
				if self.LeftMoveDist > 20 then
					self.MoveLeftDel = CurTime() +0.4
				end
			end
		end
		
		--Right foot
		if self.FootStatus == 3 or self.FootStatus == 2 then
			
			if self.DontMoveRightDel < CurTime() then			
				local bonepos, boneang = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(12)) 
				
				if self.RightMoveDist > 20 then
					self.MoveRightDel = CurTime() +0.4
				end
			end		
		end		
		
	end
	
	--Should we move the left or the right foot?
	if self.MoveLeftDel > CurTime() && self.MoveRightDel > CurTime() then

		if self.RightMoveDist < self.LeftMoveDist then
			self.MoveRightDel = CurTime()
			self.DontMoveRightDel = CurTime()
		else
			self.MoveLeftDel = CurTime()
			self.DontMoveLeftDel = CurTime()
		end
	end

	--Moving right foot
	if self.MoveLeftDel > CurTime() && (self.FootStatus == 2 or self.FootStatus == 3) then

		if self.DontMoveLeftDel <= CurTime() then
			local vel = self.LeftMoveDist
			
			if vel > 150 then
				vel = 150
			end
			
			--Playing a fancy servo sound			
			local pitch = 200 -vel
			local vol = vel *0.5 +50
			self:EmitSound("combine mech/servoMove.mp3",vol,pitch)					
		end

		self.DontMoveLeftDel = CurTime() +1
		local physObj = self.MechRagdoll:GetPhysicsObjectNum(6)
		local vel = self:GetVelocity()
		physObj:ApplyForceCenter(Vector(0,0,(50 +self.LeftMoveDist *1.3)) +(self.LeftMoveDir *self.LeftMoveDist *1.2) +vel)
	end

	--Moving left foot
	if self.MoveRightDel > CurTime() && (self.FootStatus == 1 or self.FootStatus == 3) then
		if self.DontMoveRightDel <= CurTime() then
			local vel = self.RightMoveDist
			
			if vel > 150 then
				vel = 150
			end
			
			--Playing a fancy servo sound
			local pitch = 200 -vel
			local vol = vel *0.5 +50
			self:EmitSound("combine mech/servoMove.mp3",vol,pitch)		
		end
	
		self.DontMoveRightDel = CurTime() +1
		local physObj = self.MechRagdoll:GetPhysicsObjectNum(12)
		local vel = self:GetVelocity()
		physObj:ApplyForceCenter(Vector(0,0, (50 +self.RightMoveDist *1.3)) +(self.RightMoveDir *self.RightMoveDist *1.2) +vel)		
	end		

end

--This function manages the keepUpRight constraint
--it also disables and enables gravity on the mechs legs
function ENT:Steady()

	if !self.MechRagdoll or self.MechRagdoll == NULL or self.MechRagdoll == nil then return false end

	local bonepos1, boneang1 = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(6)) 
	local bonepos2, boneang2 = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(12)) 
	
	local entPos = self:GetPos()
	local badLeg = false
	if bonepos1.z > entPos.z or bonepos2.z > entPos.z then
		badLeg = true
	end

	if self.keepUpRightCon == NULL && (self.FootStatus > 0 or self.flyHeight > 0 or self.JetPlay == true) && badLeg == false && (self.DotProd >= 0.7 or self.JetPlay == true) && (self:WaterLevel() == 0 or self.flyHeight > 0) then
		self.keepUpRightCon = constraint.Keepupright(self.keepUpRightProp, self.StabAng, 0, 100000000)
		self.MechRagdoll:GetPhysicsObjectNum(3):EnableGravity(false)
		self.MechRagdoll:GetPhysicsObjectNum(4):EnableGravity(false)
		self.MechRagdoll:GetPhysicsObjectNum(9):EnableGravity(false)
		self.MechRagdoll:GetPhysicsObjectNum(10):EnableGravity(false)		
	elseif self.keepUpRightCon != NULL && (self.FootStatus == 0 or badLeg == true or self:WaterLevel() >= 1) && self.flyHeight == 0 && self.JetTimer < CurTime() then
		self.keepUpRightCon:Remove()
		self.keepUpRightCon = NULL
		self.MechRagdoll:GetPhysicsObjectNum(3):EnableGravity(true)
		self.MechRagdoll:GetPhysicsObjectNum(4):EnableGravity(true)
		self.MechRagdoll:GetPhysicsObjectNum(9):EnableGravity(true)
		self.MechRagdoll:GetPhysicsObjectNum(10):EnableGravity(true)
	end	
end

--Makes the mech pelvis move between the legs
--That sounded a bit wrong. :/
function ENT:Stabilize()

	if !self.MechRagdoll or self.MechRagdoll == NULL or self.MechRagdoll == nil then return false end

	local bonepos1, boneang1 = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(6)) 
	local bonepos2, boneang2 = self.MechRagdoll:GetBonePosition(self.MechRagdoll:TranslatePhysBoneToBone(12)) 
	
	local pos = (bonepos1 +bonepos2) /2
	local dir = (pos -self:GetPos()):GetNormalized()
	dir.z = 0
	self:GetPhysicsObject():ApplyForceCenter(dir *5000)
end

--Directing the mech pelvis in the players aim vector
function ENT:DirectMech()

	if self.User != NULL && self.User:InVehicle() then	

		if !self.MechRagdoll or self.MechRagdoll == NULL or self.MechRagdoll == nil then return false end	
	
		--This will smooth out the movement
		local angVel = self.MechRagdoll:GetPhysicsObjectNum(1):GetAngleVelocity()
		angVel = angVel *-0.5
		self.MechRagdoll:GetPhysicsObjectNum(1):AddAngleVelocity(angVel)	
	
		local destPos = self:GetPos() +self.User:GetAimVector() *500
		local lDist = (self:GetPos() +self:GetRight() *-50):Distance(destPos)	
		local rDist = (self:GetPos() +self:GetRight() *50):Distance(destPos)	 
		local force = lDist -rDist
		
		if force < 0 then
			force  = force *-1
		end		

		if lDist > rDist then
			self.MechRagdoll:GetPhysicsObjectNum(0):AddAngleVelocity(Vector(0,1,0) *force)
		else
			self.MechRagdoll:GetPhysicsObjectNum(0):AddAngleVelocity(Vector(0,-1,0) *force)	
		end	
		

	end
end

--Directing the mech head in the players aim vector
function ENT:DirectHead()

	if self.User && self.User != nil && self.User:IsValid() && self.User != NULL && self.User:InVehicle() then	
	
		if !self.MechRagdoll or self.MechRagdoll == NULL or self.MechRagdoll == nil then return false end
	
		--This will smooth out the movement
		local angVel = self.MechRagdoll:GetPhysicsObjectNum(1):GetAngleVelocity()
		angVel = angVel *-0.5
		self.MechRagdoll:GetPhysicsObjectNum(1):AddAngleVelocity(angVel)	

		local destPos = self:GetPos() +self.User:GetAimVector() *500		
		local lDist = (self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetRight() *-50):Distance(destPos)	
		local rDist = (self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetRight() *50):Distance(destPos)
		local force = lDist -rDist		
		force = force *2
		
		if force < 0 then
			force  = force *-1
		end		

		if lDist > rDist then
			self.MechRagdoll:GetPhysicsObjectNum(1):AddAngleVelocity(Vector(0,1,0) *force)	
		else
			self.MechRagdoll:GetPhysicsObjectNum(1):AddAngleVelocity(Vector(0,-1,0) *force)
		end
	end
end


--All shield thingys happens here
function ENT:Shield()

	--Energy must be above 0
	if self.Energy > 0 then
	
	if !self.MechRagdoll or self.MechRagdoll == NULL or self.MechRagdoll == nil then return false end	
	
		--Getting all ents
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 150)) do

			--These things are hidden in the player
			--We don't want the shield to react to them
			if !(v:IsPlayer()) && v:IsValid() && !(v:IsWeapon()) && !(string.find(v:GetClass(), "predicted_viewmodel")) && !(string.find(v:GetClass(), "physgun_beam")) then


			--The shield should ignore it's own parts
			if v != self.keepUpRightProp && v !=self.MechRagdoll && v != self.MechUserEnt && v != self.Seat && v != self.TempMissile then
					local vel = v:GetVelocity():Length()
					local dir1 = v:GetVelocity():GetNormalized()
					local dir = (v:GetPos() -self:GetPos()):GetNormalized()
					local dot = dir:DotProduct(dir1)
					
					if dot < 0 && vel > 500 then
					
						--Some ents that aren't phys objects needs to be handles separatly
						if v:GetClass()=="rpg_missile" then
							self.Energy = self.Energy -20
							v:SetLocalVelocity(dir *vel *1000 +Vector(0,0,10000))
							v:SetAngles(dir:Angle())
							v:SetHealth(0)	
							
							local bul = {
								Num = 1,
								Src = v:GetPos(),
								Dir = Vector(0,0,0),
								Spread = Vector(0,0,0),
								Tracer = 0,
								Force = 1,
								Damage = 100
							}
							self:FireBullets(bul)
						elseif v:GetClass() == "crossbow_bolt" or v:GetClass() == "hunter_flechette" or v:GetClass() == "grenade_spit" then
							
							if v:GetClass() == "crossbow_bolt" then
								self.Energy = self.Energy -10
							else
								self.Energy = self.Energy -3
							end
							
							if v:GetClass() == "grenade_spit" then
								v:SetLocalVelocity(dir *vel)
							else
								v:SetLocalVelocity(dir *vel *1000)
							end
						elseif v:GetClass() == "grenade_ar2" then
							self.Energy = self.Energy -5
							v:SetLocalVelocity(dir *vel)
						elseif  string.find(v:GetClass(), "missile") then
							v:SetAngles(dir:Angle())
							v.MissileTime = 0
							v:GetPhysicsObject():SetVelocity(dir *vel *0.5)
							self.Energy = self.Energy -10
						else
							
							local phys = v:GetPhysicsObject()
							if phys != NULL && phys != nil && phys:IsValid() then
								phys:SetVelocity(dir *vel)
								self.Energy = self.Energy -(phys:GetMass() /5)
							end
						end
						
						--The shield effect
						local minimum,maximum = v:WorldSpaceAABB()
						local size = minimum:Distance(maximum)	
						
						local effectdata = EffectData()
						effectdata:SetOrigin(v:GetPos())
						effectdata:SetEntity(self)
						effectdata:SetScale(size)
						util.Effect("mech_shieldEffect",effectdata)		
						
						self:EmitSound("combine mech/shieldHit.mp3",85,math.random(80,120))	
						
						--The shield is down D:
						if self.Energy <= 0 then
							self.Energy = -50
							self:EmitSound("combine mech/ShieldDown.wav",85,math.random(80,120))	
							self.ShieldDown = true
							
							
							local effectdata = EffectData()
							effectdata:SetStart(self:GetPos())
							effectdata:SetOrigin(self:GetPos())
							effectdata:SetScale(1)
							util.Effect("cball_explode", effectdata)									
						end
											
					end
				end
			end
		end
	end
end
		
function ENT:ShootRocket()	
	
	self:EmitSound("weapons/stinger_fire1.wav",75,math.random(80,120))	

	local tracedata = {}
	tracedata.start = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +Vector(0,0,-20)
	tracedata.endpos = tracedata.start +(self.User:GetAimVector() *4000)
	tracedata.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
	local trace = util.TraceLine(tracedata)

	local Missile = ents.Create("sent_MechMissile")
	Missile:SetPos(self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetRight() *-40 +self.keepUpRightProp:GetUp() *10 ) 				
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

function ENT:ShootGrenade()
		
	self:EmitSound("weapons/ar2/ar2_altfire.wav",75,math.random(80,120))		

	local gren = ents.Create("sent_MechGrenade")
	gren:SetPos(self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetRight() *40 +self.keepUpRightProp:GetUp() *10 ) 				
	gren:SetAngles(self.keepUpRightProp:GetAngles())
	gren:Spawn()
	gren:Activate() 
	gren:GetPhysicsObject():Wake()
	gren:GetPhysicsObject():ApplyForceCenter(self.User:GetAimVector() *1000)
	
	self.TempMissile = gren
	constraint.NoCollide(gren, self.MechRagdoll, 0, 0)
	constraint.NoCollide(gren, self.keepUpRightProp, 0, 0)
	constraint.NoCollide(gren, self, 0, 0)	
end

function ENT:ShootMissileStorm()

	local Missile = ents.Create("sent_MechMissile")
	Missile:SetPos(self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetUp() *30 +self.keepUpRightProp:GetForward() *-20) 				
	Missile:SetAngles(self.keepUpRightProp:GetUp():Angle() +Angle(math.random(-20,20),math.random(-20,20),math.random(-20,20)	))
	Missile.FollowPos = self.MissileStormDestPos +Vector(math.random(-200,200),math.random(-200,200),0)
	Missile.ActivateDel = CurTime() +0.2
	Missile.angchange = 10	
	Missile:Spawn()
	Missile:Activate() 
	Missile:GetPhysicsObject():Wake()
	
	self.TempMissile = Missile
	constraint.NoCollide(Missile, self.MechRagdoll, 0, 0)
	constraint.NoCollide(Missile, self.keepUpRightProp, 0, 0)
	constraint.NoCollide(Missile, self, 0, 0)		
	
end


function ENT:ShootBullet()
	self:EmitSound("^weapons/ar1/ar1_dist"..math.random(1,2)..".wav",75,math.random(80,120))	

	local pos = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +Vector(0,0,-20)
	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	effectdata:SetAngles(self.User:GetAimVector():Angle())
	effectdata:SetScale(1)
	util.Effect("MuzzleEffect", effectdata)

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos
	bullet.Dir 			= self.User:GetAimVector()
	bullet.Spread 		= Vector(0.03,0.03,0)
	bullet.Tracer		= 1
	bullet.TracerName	= "Tracer"
	bullet.Force		= 0
	bullet.Damage		= 5
	bullet.Attacker 	= self.User		
	self:FireBullets(bullet)
end

function ENT:ShootScreamer()

	if self.User != NULL then
		local tracedata = {}
		tracedata.start = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +Vector(0,0,-20)
		tracedata.endpos = tracedata.start +(self.User:GetAimVector() *999999)
		tracedata.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
		local trace = util.TraceLine(tracedata)

		local target = NULL
		if trace.HitNonWorld then
		   target = trace.Entity
		end
		
		
		local bomb = ents.Create("sent_MechScreamerBomb")
		bomb:SetPos(self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetUp() *30 +self.keepUpRightProp:GetForward() *-20) 					
		bomb:SetAngles(self.keepUpRightProp:GetAngles())
		bomb.FollowPos = trace.HitPos
		bomb.target = target
		bomb.ActivateDel = CurTime() +0.2
		bomb:Spawn()
		bomb:Activate() 
		bomb:GetPhysicsObject():Wake()
		bomb:GetPhysicsObject():ApplyForceCenter(Vector(0,0,1000))	
	end
end

function ENT:ShootGravProbe()

	if self.User != NULL then
		local tracedata = {}
		tracedata.start = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +Vector(0,0,-20)
		tracedata.endpos = tracedata.start +(self.User:GetAimVector() *400)
		tracedata.filter =  { self, self.MechRagdoll, self.keepUpRightProp}
		local trace = util.TraceLine(tracedata)

		local grav = ents.Create("sent_MechGravProbe")
		grav:SetPos(trace.HitPos) 					
		grav:SetAngles(self.keepUpRightProp:GetAngles())
		grav.FollowPos = self.keepUpRightProp:GetPos() +self.keepUpRightProp:GetForward() *50 +Vector(0,0,-20) +self.User:GetAimVector() *400 
		grav.ignoreProps[1] = self:EntIndex()
		grav.ignoreProps[2] = self.MechRagdoll:EntIndex()
		grav.ignoreProps[3] = self.keepUpRightProp:EntIndex()	
		grav.ArmTime = NULL
		grav:Spawn()
		grav:Activate() 
		grav:GetPhysicsObject():Wake()	
		
		self.TempMissile = grav
	end
end

function ENT:FixPropProtection(ply)

	self.Spawner = ply
	--ASS prop protection
	self:SetNetworkedEntity("ASS_Owner", ply)
	self:SetVar("ASS_Owner", ply)
	self:SetVar("ASS_OwnerOverride", true)

	self.MechRagdoll:SetNetworkedEntity("ASS_Owner", ply)
	self.MechRagdoll:SetVar("ASS_Owner", ply)
	self.MechRagdoll:SetVar("ASS_OwnerOverride", true)

	self.keepUpRightProp:SetNetworkedEntity("ASS_Owner", ply)
	self.keepUpRightProp:SetVar("ASS_Owner", ply)
	self.keepUpRightProp:SetVar("ASS_OwnerOverride", true)	
	
	--Falcos prop protection
	self.Owner = ply
	self.OwnerID = ply:SteamID()
	self.OwnerID = ply:SteamID()

	self.MechRagdoll.Owner = ply
	self.MechRagdoll.OwnerID = ply:SteamID()

	self.keepUpRightProp.Owner = ply
	self.keepUpRightProp.OwnerID = ply:SteamID()

	
	--UPS prop protection
	gamemode.Call("UPSAssignOwnership", ply, self)
	gamemode.Call("UPSAssignOwnership", ply, self.MechRagdoll)
	gamemode.Call("UPSAssignOwnership", ply, self.keepUpRightProp)	
end