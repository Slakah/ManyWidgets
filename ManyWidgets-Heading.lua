--Made because some of the tekKonfig Widgets suck.
local libhead, oldminor = LibStub:NewLibrary("ManyWidgets-Heading", 1)
if not libhead then return end

function libhead.New(parent, headtext, subtext, icon)
	local title = parent:CreateFontString(nil, "BACKGROUND", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(icon and ("|T%s:32|t %s"):format(icon, headtext) or headtext)
	
	
	local subtitle = parent:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", parent, -22, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(subtext)

	return title, subtitle
end

local mt = LibStub("ManyWidgets_Metatable", true)
if not mt then
	mt = LibStub:NewLibrary("ManyWidgets_Metatable")
	mt.__call = function(t, ...) return t.New(...) end
end
setmetatable(libbox, mt)
