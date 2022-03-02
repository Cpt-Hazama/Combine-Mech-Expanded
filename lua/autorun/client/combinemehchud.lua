--include("CombineMehcHUD.lua")

local bgTex = surface.GetTextureID("combinemechhud/hud")
local brokenTex = surface.GetTextureID("combinemechhud/broken")

local heatBg =  surface.GetTextureID("combinemechhud/HeatBg")
local heat1Tex = surface.GetTextureID("combinemechhud/heat1")
local heat2Tex = surface.GetTextureID("combinemechhud/heat2")
local targetTex = surface.GetTextureID("combinemechhud/target")

local cross1 = surface.GetTextureID("combinemechhud/aim1")
local cross2 = surface.GetTextureID("combinemechhud/aim2")

local staticTex = surface.GetTextureID("combinemechhud/static")

local wepConsoleTex = surface.GetTextureID("combinemechhud/wepConsole")

local wepType = {"Missiles","Grenades","Missile storm","Turret","Screamer","Grav Probe","Laser"}
local wepIcoTex = {surface.GetTextureID("combinemechhud/missileIco"),surface.GetTextureID("combinemechhud/grenadeIco"),
surface.GetTextureID("combinemechhud/missileStormIco"),surface.GetTextureID("combinemechhud/turretIco"), surface.GetTextureID("combinemechhud/screamerIco"),surface.GetTextureID("combinemechhud/gravIco"),
surface.GetTextureID("combinemechhud/laserIco")}

local rot1 = 0
local rot2 = 0
local rot3 = 0

local size = ScrH() *0.03333333
local lastHp = 100
local noiseTime = CurTime()
local startNoiseTime = 0
local oldWep = 1

local defColor = Color(120, 200, 255)

//surface.CreateFont("Agency FB", size, 200, 0, 0, "comHudText")
surface.CreateFont("comHudText", {
	size = size,
	weight = 200,
	font = "Agency FB",
	antialias = false
})

--Local funcs
local MakeNoise = function(nr)

	for i = 1,nr  do
		
		xPos = math.Rand(1,ScrW())
		yPos = math.Rand(1,ScrH())
		xSize = math.Rand(1, (ScrW() /20))
		ySize = math.Rand(1, (ScrH() /20))
		
		local colr = math.Rand(1,255)
		
		local newCol = Color(colr,colr,colr,math.Rand(1,255))
	
		draw.RoundedBox(0, xPos, yPos, xSize, ySize, newCol)	
	end	
	
end

local MakeNoiseLines = function(nr)
	for i = 1,nr  do
		local hojd = math.Rand(1,ScrW())
		local colr = math.Rand(1,255)
		surface.SetDrawColor(colr, colr, colr, math.Rand(1,255))					
		surface.DrawLine(0,hojd, ScrW(),hojd)
	end
end


----------DRAW
function DrawHud() 
	
	if !LocalPlayer():Alive() then return end
	if(LocalPlayer():GetActiveWeapon() == NULL or LocalPlayer():GetActiveWeapon() == "Camera" or !(LocalPlayer():InVehicle())) then return end		
	if GetViewEntity() != LocalPlayer() then return end
	
	local ply = LocalPlayer()
	local wepColor = ply:GetWeaponColor()
	local wR = wepColor.x *255
	local wG = wepColor.y *255
	local wB = wepColor.z *255
	
	local useCam = ply:GetNetworkedInt("ControlsCombineMech")
	local ent = ply:GetNetworkedEntity("CombineMechEnt")	
	local wep = 0
	local hp = 0
	
	if useCam > 0 then
		wep = ply:GetNetworkedInt("combineMechWeapon") 
		hp = ply:GetNetworkedFloat("combineMechHealth")	
	end
	
	if useCam == 2 && ent != NULL then
	
		local Width = ScrW()
		local Height = ScrH()
		
		
		--Detecting aspekt ratio
		local ScreenType = 1
		
		--ScreenType = 1  16:10
		--ScreenType = 2  4:3
		--ScreenType = 3  16:9		
		if (Width /Height) > (16/10) then
			ScreenType = 3
		elseif (Width /Height) <= (4/3) then
			ScreenType = 2
		end
		
	
		local sh = ply:GetNetworkedFloat("combineMechShield")	
		local heat = ply:GetNetworkedInt("combineMechHeat")	
		local fly = ply:GetNetworkedEntity("combineMechFlyHeight")
		
		local col = heat 
		heat = math.Round(heat *100)
		local newHp = hp *100
		
		local xPos = 0
		local yPos = 0
		local xSize = 0
		local ySize = 0		
	
		--Disturbence, static and noise
		if newHp < 49 then
		
			local nr = math.Round(math.Rand(1, (50 -newHp)))		
			MakeNoiseLines(nr)
			
			if newHp < 24 then
				nr = math.Round(math.Rand(1, (25 -newHp)))
				MakeNoise(nr)
			end
		end
		

		
		if noiseTime > CurTime() then
			local perc = 1 -((startNoiseTime -(noiseTime -CurTime())) /startNoiseTime)

			MakeNoise(perc *100)
			MakeNoiseLines(perc *100)

			local alph = (perc *100) +math.Rand(1,50)
			local maxSizeX = (math.Rand(1,(Width /2)))
			local maxSizeY = (math.Rand(1,(Height /2)))
			local maxSizeX2 = (math.Rand(1,(Width /2)))
			local maxSizeY2 = (math.Rand(1,(Height /2)))			
		
			xPos = maxSizeX *-1
			yPos = maxSizeY *-1
			xSize = Width +maxSizeX +maxSizeX2
			ySize = Height +maxSizeY +maxSizeY2		
			
			surface.SetTexture(staticTex)
			surface.SetDrawColor(255, 255, 255, alph)	
			surface.DrawTexturedRect(xPos, yPos, xSize, ySize)			
		end
		
		--Height thingys
		local PosHeight = ent:GetPos()
		local nrOfRows = 10
		
		for i = 1, nrOfRows do
		
			xPos = Width *0.0238095238	
			yPos = ((ScrH() /nrOfRows) *i) +PosHeight.z 
			xSize = Width *0.0238095238	
			ySize = Height *0.019047619			
			
			if yPos > Height then
				k, f = math.modf(yPos/Height)
				yPos = yPos -(k *Height)
			end
			
			draw.RoundedBox(2, xPos, yPos, xSize, ySize, Color(255,255,255,255))	
		end
		
		for i = 1, nrOfRows do
		
			xPos = Width *0.9523809524		
			yPos = ((ScrH() /nrOfRows) *i) +PosHeight.z 
			xSize = Width *0.0238095238
			ySize = Height *0.019047619	
			
			if yPos > Height then
				k, f = math.modf(yPos/Height)
				yPos = yPos -(k *Height)
			end

			draw.RoundedBox(2, xPos, yPos, xSize, ySize, Color(255,255,255,255))	
		end	


		--Horizontal Line
		surface.SetDrawColor(wR, wG, wB)	
		local offset = ent:GetRight():DotProduct(Vector(0,0,1))
		local left = (ScrH() /2) -offset *ScrH()
		local right = (ScrH() /2) +offset *ScrH()
		surface.DrawLine(0,left, ScrW(),right)
		
		surface.SetTexture(bgTex)
		surface.SetDrawColor(wR, wG, wB, 255)	
		surface.DrawTexturedRect(0, 0, Width, Height)

		--This will paint circles around players and NPC's
		--It was a little bit annoying and didn't look so good so i commented it.
		--Drawing targets
		surface.SetTexture(targetTex)
		surface.SetDrawColor(50, 255, 50, 255)
		
		--Players
		local maxDist = 2000
		for k, v in pairs(player.GetAll()) do
			local targetPos = v:GetPos() +v:OBBCenter()
			local size = ent:GetPos():Distance(targetPos)
			
			if size <= maxDist then
			
				local pos = targetPos:ToScreen()
				size = (maxDist -size) /2
				size = math.Clamp(size, 0, 70)
				
				pos.x = pos.x -(size /2)
				pos.y = pos.y -(size /2)
	
				surface.DrawTexturedRect(pos.x, pos.y, size, size)		
			end		
		end
		
		--NPC's
		surface.SetDrawColor(255, 0, 0, 255)
		for k, v in pairs(ents.FindByClass("npc_*")) do
			local targetPos = v:GetPos() +v:OBBCenter()
			local size = ent:GetPos():Distance(targetPos)
			
			if size <= maxDist then
				local pos = targetPos:ToScreen()
				size = (maxDist -size) /2
				size = math.Clamp(size, 0, 70)
				pos.x = pos.x -(size /2)
				pos.y = pos.y -(size /2)
	
				surface.DrawTexturedRect(pos.x, pos.y, size, size)		
			end	
		end
	
		local rCol = 255 -(wR *col)
		-- local rCol = wR *col
		local gCol = col *wG
		local bCol = col *wB
		
		xPos = Width *0.880952381		
		yPos = Height *0.1904761905
		xSize = Width *0.1428571429
		ySize = Height *0.2285714286

		if ScreenType == 2 then
			xSize = Width *0.15625
			ySize = Height *0.1953125		
		elseif ScreenType == 3 then
			xSize = Width *0.14375
			ySize = Height *0.255555555555			
		end		
		
		surface.SetTexture(heatBg)
		surface.SetDrawColor(wR, wG, wB, 255)
		surface.DrawTexturedRectRotated(xPos, yPos, xSize, ySize, 0)
		
		xSize = Width *0.130952381
		ySize = Height *0.2095238095			
		
		if ScreenType == 2 then
			xSize = Width *0.1484375
			ySize = Height *0.185546875	
		elseif ScreenType == 3 then		
			xSize = Width *0.13125
			ySize = Height *0.23333333333333		
		end		
		
		surface.SetTexture(heat1Tex)
		rot1 = rot1 +((100 -heat) *0.4) +1
		surface.SetDrawColor(rCol, gCol, bCol, 255)	
		surface.DrawTexturedRectRotated(xPos, yPos, xSize, ySize, rot1)
		
		surface.SetTexture(heat2Tex)
		rot2 = rot2 -((100 -heat) *0.5) -2
		surface.SetDrawColor((rCol *0.7), (gCol *0.7), (bCol *0.7), (100 +(150 *col)))	
		surface.DrawTexturedRectRotated(xPos, yPos, xSize, ySize, rot2)
		
		--HP
		xPos = Width *0.6976190476	
		yPos = Height *0.94
		xSize = ((Width *0.280952381) *hp)
		ySize = Height *0.0228571429				
		draw.RoundedBox(0, xPos, yPos, xSize, ySize, Color(255,255,255,255))		

		xPos = Width *0.0178571429		
		yPos = Height *0.94
		xSize = ((Width *0.280952381) *sh)
		ySize = Height *0.0228571429	
		--Shield
		draw.RoundedBox(0, xPos, yPos, xSize, ySize, Color(255,255,255,255))			
		--draw.RoundedBox(Number Bordersize, Number X, Number Y, Number Width, Number Height, Color Color)

		--crosshair
		local maxHeight = GetConVar("sv_combinemech_disablemodifiers"):GetBool() == true && 1000 or GetConVar("sv_combinemech_maxhoverheight"):GetInt() or 1000
		local rCol = wR -(200 *(1-(fly /maxHeight)))
		-- local rCol = (1-(fly /maxHeight)) *wR
		local gCol = (1-(fly /maxHeight)) *wG
		local bCol = (1-(fly /maxHeight)) *wB		
		
		surface.SetDrawColor(rCol, gCol, bCol, 255)	
		
		local rot4 = (1-(fly /maxHeight)) *100
		
		surface.SetTexture(cross1)
		xSize = Width *0.119047619
		ySize = Height *0.1904761905	
		
		if ScreenType == 2 then
			xSize = Width *0.15234375
			ySize = Height *0.1904296875
		elseif ScreenType == 3 then	
			xSize = Width *0.125
			ySize = Height *0.22222222222222	
		end
		
		surface.DrawTexturedRectRotated((ScrW() /2), (ScrH() /2), xSize, ySize, rot4)
		
		surface.SetDrawColor(wR, wG, wB, 255)
		surface.SetTexture(cross2)
		xSize = Width *0.119047619
		ySize = Height *0.1904761905	

		if ScreenType == 2 then
			xSize = Width *0.15234375
			ySize = Height *0.1904296875	
		elseif ScreenType == 3 then	
			xSize = Width *0.125
			ySize = Height *0.22222222222222		
		end
		
		surface.DrawTexturedRectRotated((ScrW() /2), (ScrH() /2), xSize, ySize, rot3)		
		rot3 = rot3 +0.1
		
	end
	
	if useCam > 0 then
		
		local newHp = hp *100		
		
		if lastHp != newHp then			
			startNoiseTime = ((lastHp -newHp) /10)
			
			if noiseTime > CurTime() then
				noiseTime = noiseTime +startNoiseTime
			else
				noiseTime = CurTime() +((lastHp -newHp) /10)
			end

			lastHp = newHp
		end		
		
		if wep != oldWep then	
			oldWep = wep
			ply:EmitSound("common/wpn_moveselect.wav")
		end	
		
		if wep && wep != NULL then
			xPos = 0
			yPos = 0
			xSize = ScrW() *0.2369047619	
			ySize = ScrH() *0.2638095238	

			surface.SetTexture(wepConsoleTex)
			surface.SetDrawColor(wR, wG, wB, 255)	
			surface.DrawTexturedRect(xPos, yPos, xSize, ySize)

			--Weapon
			xPos = ScrW() *0.130952381	
			yPos = ScrH() *0.066666667		
			draw.SimpleText(wepType[wep], "comHudText", xPos, yPos, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	

			
			xPos = ScrW() *0.0595238095		
			yPos = ScrH() *0.1238095238
			xSize = ScrW() *0.0773809524
			ySize = ScrH() *0.1219047619			
			surface.SetTexture(wepIcoTex[wep])
			surface.SetDrawColor(wR, wG, wB, 255)			
			surface.DrawTexturedRect(xPos, yPos, xSize, ySize)		
		end
		
		if useCam == 2 then
			local hp = ply:GetNetworkedFloat("combineMechHealth")
			
			if hp <= 0 then
				surface.SetTexture(brokenTex)
				surface.SetDrawColor(255, 255, 255, 255)	
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())	
			end			
		end
	end
end

hook.Add("HUDPaint", "DrawCombineMechHud", DrawHud)

--Hide the default HUD if we are using the mech
function Hide(Element) 

	local ply = LocalPlayer()

	local useCam = ply:GetNetworkedInt("ControlsCombineMech")

	if useCam > 0 then
		if (Element == "CHudHealth") or (Element == "CHudBattery") then   
		   return false
		end
		   
		if (Element == "CHudAmmo") and ShowAmmo or (Element == "CHudSecondaryAmmo") and ShowAmmo then
		   return false
		end
	end
end
hook.Add("HUDShouldDraw", "Hide", Hide) 