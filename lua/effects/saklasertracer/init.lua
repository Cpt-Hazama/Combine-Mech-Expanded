

EFFECT.Mat = Material("effects/spark")

function EFFECT:Init(data)

	
	self.EndPos = data:GetOrigin()
	self.StartPos = data:GetStart()
	
	self.Dir = self.EndPos -self.StartPos
	
	
	self:SetRenderBoundsWS(self.StartPos, self.EndPos)
	
	self.TracerTime = 0.1
	self.Length = math.Rand(0.1, 0.15)
	
	// Die when it reaches its target
	self.DieTime = CurTime() +self.TracerTime
	
end

function EFFECT:Think()

	if (CurTime() > self.DieTime) then

		// Awesome End Sparks
		local effectdata = EffectData()
			effectdata:SetOrigin(self.EndPos +self.Dir:GetNormalized() *-2)
			effectdata:SetNormal(self.Dir:GetNormalized() *-3)
			effectdata:SetMagnitude(2)
			effectdata:SetScale(3)
			effectdata:SetRadius(6)
		util.Effect("Sparks", effectdata)
	
		return false 
	end
	
	return true

end

function EFFECT:Render()

	local fDelta = (self.DieTime -CurTime()) /self.TracerTime
	fDelta = math.Clamp(fDelta, 0, 1) ^ 0.5
			
	render.SetMaterial(self.Mat)
	
	local sinWave = math.sin(fDelta *math.pi)
	

	render.DrawBeam(self.EndPos -self.Dir *(fDelta -sinWave *self.Length), 		
					 self.EndPos -self.Dir *(fDelta +sinWave *self.Length),
					 2 +sinWave *16,					
					 1,					
					 0,				
					 Color(0, 150, 255, 255))
				 
end
