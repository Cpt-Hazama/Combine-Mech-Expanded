
ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName		= "Combine Mech"
ENT.Author			= "Sakarias88"
ENT.Category 		= "Sakarias88"
ENT.Contact    		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= "" 

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

function ENT:Initialize()
    local ind = "CombineMech" .. self:EntIndex()
    hook.Add("CalcView", ind, function(ply, position, angles, fov)
        if !IsValid(self) then
            hook.Remove("CalcView", ind)
            return
        end
        if !ply:Alive() or ply:Alive() && (ply:GetActiveWeapon() == NULL or ply:GetActiveWeapon() == "Camera") or GetViewEntity() != ply then
            return
        end
            
        local useCam = ply:GetNetworkedInt("ControlsCombineMech")
        if (useCam && useCam == 1 or useCam == 2) && ply:InVehicle() then
            local FT = FrameTime() *6
            local ent = ply:GetNetworkedEntity("CombineMechEnt")
            local saw = ply:GetNetworkedEntity("CombineMechSawEnt")
            ent.LerpView = ent.LerpView or position
            ent.LerpAng = ent.LerpAng or angles
            if IsValid(ent) then
                if useCam == 1 then
                    local pos = ent:GetPos() +(angles:Forward() *-300) +saw:GetUp() *60
                    local Trace = {}
                    Trace.start = ent:GetPos() +(angles:Forward() *-100)
                    Trace.endpos = pos
                    Trace.filter = {ply,ent,saw}
                    local tr = util.TraceLine(Trace)
                    if tr.Hit then	
                        pos = tr.HitPos
                    end
                    position = pos
                elseif useCam == 2 then
                    local pos = saw:GetPos()
                    local ang = saw:GetAngles()
                    ang.p = angles.p
                    ang.y = angles.y
                    angles = ang
                    pos = pos +saw:GetForward() *50 +saw:GetUp() *-20
                    position = pos
                end

                ent.LerpView = useCam == 2 && position or LerpVector(FT, ent.LerpView, position)
                ent.LerpAng = LerpAngle(FT, ent.LerpAng, angles)

                return GAMEMODE:CalcView(ply, ent.LerpView, ent.LerpAng, fov)
            end
        end

        if (useCam && useCam == 1 or useCam == 2) && !(ply:InVehicle()) then
            ply:SetNetworkedInt("ControlsCombineMech",0)
        end
    end)
end