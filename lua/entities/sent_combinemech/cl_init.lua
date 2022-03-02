include('shared.lua')

function ENT:Think()
	if self:GetNetworkedBool("IsFlying") then
		self:MakeSmoke()
	end
end

function ENT:MakeSmoke()
	self.SmokeTimer = self.SmokeTimer or 0
	if (self.SmokeTimer > CurTime()) then return end
	
	self.SmokeTimer = CurTime() +0.015

	local vOffset = self:GetPos() +self:GetUp() *-20 +Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-5, 5))
	local vNormal = Vector(math.Rand(-5,5),math.Rand(-5,5),-20)
	local vel = self:GetVelocity()
	
	local emitter = self:GetEmitter(vOffset, false)
	
		local particle = emitter:Add("particles/smokey", vOffset)
			particle:SetVelocity(vNormal *math.Rand(10, 30) +Vector(0,0,vel.z))
			particle:SetDieTime(1.0)
			particle:SetStartAlpha(math.Rand(50, 150))
			particle:SetStartSize(math.Rand(5, 16))
			particle:SetEndSize(math.Rand(64, 100))
			particle:SetRoll(math.Rand(-0.2, 0.2))
			particle:SetColor(Color(200, 200, 210))

			particle:SetCollide(true);
			particle:SetAirResistance(5);			
end
function ENT:GetEmitter(Pos, b3D)

	if (self.Emitter) then	
		if (self.EmitterIs3D == b3D && self.EmitterTime > CurTime()) then
			return self.Emitter
		end
	end
	
	self.Emitter = ParticleEmitter(Pos, b3D)
	self.EmitterIs3D = b3D
	self.EmitterTime = CurTime() +2
	return self.Emitter

end
