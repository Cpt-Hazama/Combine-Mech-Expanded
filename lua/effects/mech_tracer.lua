local Tracer = Material("trails/smoke")
local Tracer2  = Material("fx/tracer")
local Width = 2.65
local Width2 = 7

function EFFECT:Init(data)
	self.Position = data:GetStart()
	self.EndPos = data:GetOrigin()

	self.StartPos = self.Position
	self:SetRenderBoundsWS(self.StartPos,self.EndPos)

	self.Dir = (self.EndPos -self.StartPos):GetNormalized()
	self.Dist = self.StartPos:Distance(self.EndPos)
	
	self.LifeTime = 0.5
	self.LifeTime2 = 0.1 *self.LifeTime
	self.DieTime = CurTime() +self.LifeTime
	self.DieTime2 = CurTime() +self.LifeTime2

	self.ShouldDrawSmoke = math.random(1,3) == 1
end

function EFFECT:Think()
	if CurTime() > self.DieTime then
		return false
	end
	return true
end

function EFFECT:Render()
	if CurTime() > self.DieTime then return end
	local r = 255
	local g = 220
	local b = 120
	
	local v = (self.DieTime -CurTime()) /self.LifeTime
	local v2 = (self.DieTime2 -CurTime()) /self.LifeTime2

	if self.ShouldDrawSmoke then
		render.SetMaterial(Tracer)
		render.DrawBeam(self.StartPos,self.EndPos,(v *Width),0,self.Dist /10,Color(20,20,20,v *90))
	end
	render.SetMaterial(Tracer2)
	render.DrawBeam(self.StartPos,self.EndPos,(v2 *Width2) *0.66,0,self.Dist /10,Color(r,g,b,(v2 *95) *0.5))
end