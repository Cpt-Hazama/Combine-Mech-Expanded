--include("SetWepKey.lua")

local KeyEvents = {}
local initiateTable = false
//0=KeyUp
//1=KeyPressed
//2=KeyDown
//3=KeyReleased

hook.Add("Think","CombineMechKeyThink",
function()

	if initiateTable == false then
		initiateTable = true
		for i=1, 11 do
			KeyEvents[i] = 0
		end
	end

	for i=1, 10 do
		if(input.IsKeyDown(i)) then
			if(KeyEvents[i]==0) then KeyEvents[i] = 1
			elseif(KeyEvents[i]==1) then KeyEvents[i] = 2
			elseif(KeyEvents[i]==2) then KeyEvents[i] = 2
			elseif(KeyEvents[i]==3) then KeyEvents[i] = 1 end
		else
			if(KeyEvents[i]==0) then KeyEvents[i] = 0
			elseif(KeyEvents[i]==1) then KeyEvents[i] = 3
			elseif(KeyEvents[i]==2) then KeyEvents[i] = 3
			elseif(KeyEvents[i]==3) then KeyEvents[i] = 0 end
		end
		
		if KeyEvents[i] == 1 then
			RunConsoleCommand("SetMechPlayerWepKey", (i-1))	
		end			
	end

	--F Key
	if(input.IsKeyDown(16)) then
		if(KeyEvents[11]==0) then KeyEvents[11] = 1
		elseif(KeyEvents[11]==1) then KeyEvents[11] = 2
		elseif(KeyEvents[11]==2) then KeyEvents[11] = 2
		elseif(KeyEvents[11]==3) then KeyEvents[11] = 1 end
	else
		if(KeyEvents[11]==0) then KeyEvents[11] = 0
		elseif(KeyEvents[11]==1) then KeyEvents[11] = 3
		elseif(KeyEvents[11]==2) then KeyEvents[11] = 3
		elseif(KeyEvents[11]==3) then KeyEvents[11] = 0 end
	end	

	if KeyEvents[11] == 1 then
		RunConsoleCommand("SetMechPlayerWepKey", 10)	
	end	
	
end)