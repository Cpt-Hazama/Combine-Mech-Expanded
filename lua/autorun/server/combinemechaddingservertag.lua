
--Credit goes to the makers of Wire mod

local tags = string.Explode(",",(GetConVarString("sv_tags") or ""))
for i,tag in ipairs(tags) do
	if tag:find("CMech") or tag:find("CMech 1.2") then table.remove(tags,i) end	
end
table.insert(tags, "CMech 1.2")
table.sort(tags)
RunConsoleCommand("sv_tags", table.concat(tags, ","))
