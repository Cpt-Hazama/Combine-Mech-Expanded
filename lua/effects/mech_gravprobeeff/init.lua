local RefTex = Material("refract_ring")

function EFFECT:Init(data)

	self.ent = data:GetEntity()
	self.Refract = 0
	self.Mul = 1
	self.UpdateSpeedDel = CurTime()
	self.Speed = 1
end 



function EFFECT:Think()

	if ! self.ent or !(self.ent:IsValid()) then 
		return false 
	end

	if self.Refract > 10 then
		self.Mul = -1
	elseif self.Refract < -10 then
		self.Mul = 1
	end
	
	if self.UpdateSpeedDel < CurTime() then
		self.UpdateSpeedDel = CurTime() +0.2
		self.Speed = self.ent:GetVelocity():Length()
		self.Speed = self.Speed /2000
		
		if self.Speed < 0.1 then
			self.Speed = 0.1
		end
		
	end
	
	self.Refract = self.Refract +(self.Speed *self.Mul)
	

	
	return true
end 

function EFFECT:Render()

	RefTex:SetFloat("$refractamount", math.sin(self.Refract *math.pi) *0.5)
	render.SetMaterial(RefTex)
	render.UpdateRefractTexture()
	render.DrawSprite(self.ent:GetPos(), 400, 400)	
end
