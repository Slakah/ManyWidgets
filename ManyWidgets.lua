--Made because some of the tekKonfig Widgets suck.
--This is a place to stick stuff which will be used in many other widgets
local lib, oldminor = LibStub:NewLibrary("ManyWidgets", 1)

--Enabled/Disabled states
lib.enabledlist = setmetatable({}, {__index = function(t,k) t[k] = true return true end})
function lib:IsEnable()
	return lib.enabledlist[self]
end
function lib:EnableWidget()
	lib.enabledlist[self] = true
end
function lib:DisableWidget()
	lib.enabledlist[self] = false
end

--Tooltip Stuff
function lib.HideTooltip() GameTooltip:Hide() end;
function lib:ShowTooltip()
	if self.tiptext then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.tiptext, nil, nil, nil, 1, true)
	end
end

lib.mt = {__call = function(t, ...)
	return t.New(...)
end}
