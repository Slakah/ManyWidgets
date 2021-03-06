--Used to create a box type thing used mainly to group up widgets
local libbox, oldminor = LibStub:NewLibrary("ManyWidgets-Box", 1)
if not libbox then return end

libbox.border = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
}

function libbox.New(parent, label)
	local box = CreateFrame("Frame", nil, parent)
	
	local boxborder = CreateFrame("Frame", nil, box)
	boxborder:SetBackdrop(libbox.border)
	boxborder:SetBackdropBorderColor(0.4, 0.4, 0.4)
	boxborder:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
	
	local labelfs = box:CreateFontString(nil, "BACKGROUND", "GameFontNormalLeft")
	labelfs:SetText(label)
	box.label = labelfs
	
	--position
	labelfs:SetPoint("TOPLEFT", box, "TOPLEFT", 5, 0)
	boxborder:SetPoint("TOP", labelfs, "BOTTOM")
	boxborder:SetPoint("BOTTOMRIGHT")
	boxborder:SetPoint("BOTTOMLEFT")

	return box
end

local mt = LibStub("ManyWidgets_Metatable", true)
if not mt then
	mt = LibStub:NewLibrary("ManyWidgets_Metatable")
	mt.__call = function(t, ...) return t.New(...) end
end
setmetatable(libbox, mt)