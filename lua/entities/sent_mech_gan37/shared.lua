
ENT.Base = "sent_combinemech"
ENT.Type = "anim"

ENT.PrintName		= "GAN-37"
ENT.Author			= "Cpt. Hazama"
ENT.Category 		= "Lost Planet"
ENT.Contact    		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= "" 

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

function ENT:GetFPData(ply, position, angles, saw)
    local pos = saw:GetPos()
    local ang = saw:GetAngles()
    ang.p = angles.p
    ang.y = angles.y
    angles = ang
    pos = pos +saw:GetForward() *80 +saw:GetUp() *-50
    position = pos

    return position, angles
end