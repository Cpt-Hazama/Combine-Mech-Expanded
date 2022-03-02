
local RefTex = Material("refract_ring")

function EFFECT:Init(data)

	self.ent = data:GetEntity()
	self.Size = 0
	self.Refract = 0
	self.addTime = 5
	self.startTime = CurTime()
	
end 

function EFFECT:Think()

	if ! self.ent or !(self.ent:IsValid()) then 
		return false 
	end
	
	self.Refract = (CurTime() -self.startTime) /self.addTime
	self.Refract = self.Refract *-1
	
	return true
end 

function EFFECT:Render()

	RefTex:SetFloat("$refractamount", math.sin(self.Refract *math.pi) *0.5)
	render.SetMaterial(RefTex)
	render.UpdateRefractTexture()
	render.DrawSprite(self.ent:GetPos(), 800, 800)	
end
