AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.MechModel = "models/lp/gtb22_w.mdl"

function ENT:InitializeConVars()
	local hp = 400
	local shield = 100

	self.MechHealth = hp
	self.MechMaxHealth = hp
	self.Energy = shield
	self.MaxEnergy = shield
	self.maxFlyHeight = 1000
end