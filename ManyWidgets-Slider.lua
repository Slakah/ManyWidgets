--Made because some of the tekKonfig Widgets suck.
local libslider, oldminor = LibStub:NewLibrary("ManyWidgets-Slider", 1)
if not libslider then return end

--Requires: ManyWidgets
local libmw = assert(LibStub("ManyWidgets", true), "ManyWidgets-Slider requires ManyWidgets to function")

local floor, min, max = math.floor, math.min, math.max

--Slider BG
libslider.bg = {
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	edgeSize = 8, tile = true, tileSize = 8,
	insets = {left = 3, right = 3, top = 6, bottom = 6}
}

--Slider Scripts
function libslider:Slider_OnValueChanged(val)
	local container = self:GetParent()
	local valformat = container.currentvalueformat
	if type(valformat) == "function" or (getmetatable(valformat) and getmetatable(valformat).__call) then fmt = valformat(val)
	elseif type(valformat) == "table" then fmt = valformat[val]
	else fmt = valformat end
	container.currentvalue:SetFormattedText(fmt, val)
end	

--Create Slider
function libslider:CreateSlider()
	local slider = CreateFrame("Slider", nil, self)
	slider:SetHeight(17)
	slider:SetHitRectInsets(0, 0, -10, -10)
	slider:SetOrientation("HORIZONTAL")
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	slider:SetBackdrop(libslider.bg)
	
	slider:SetScript("OnValueChanged", libslider.Slider_OnValueChanged)

	return slider
end

--Container Scripts
function libslider:Container_OnMouseWheel(d)
	local slider = self.slider
	local minval, maxval = slider:GetMinMaxValues()
	slider:SetValue(max(min(slider:GetValue() + ((IsShiftKeyDown() and 5 or 1) * d * slider:GetValueStep()), maxval), minval))
end


function libslider.New(parent, label, lowval, highval, step, curval, valformat)	
	local container = CreateFrame("Frame", nil, parent)
	container:EnableMouseWheel(true)
	container:SetHeight(28.7); container:SetWidth(144)

	container:SetScript("OnMouseWheel", libslider.Container_OnMouseWheel)
	
	container:SetScript("OnEnter", libmw.ShowTooltip)
	container:SetScript("OnLeave", libmw.HideTooltip)
	
	local slider = libslider.CreateSlider(container)
	slider:SetValueStep(step)
	slider:SetMinMaxValues(lowval, highval)
	container.slider = slider

	local text = container:CreateFontString(nil, "ARTWORK", "GameFontNormalLeft")
	text:SetText(label)
	container.label = text
	
	local currentvalue = container:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	currentvalue:SetJustifyH("RIGHT")
	container.currentvalue = currentvalue
	
	--Handle units
	container.currentvalueformat = valformat or "%d"
	
	--Position
	slider:SetPoint("BOTTOMLEFT"); slider:SetPoint("BOTTOMRIGHT")
	text:SetPoint("TOPLEFT"); text:SetPoint("BOTTOMLEFT", slider, "TOPLEFT")
	currentvalue:SetPoint("TOPRIGHT"); currentvalue:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT"); currentvalue:SetPoint("LEFT", text, "RIGHT")
	
	--Set the value here so "OnValueChanged" handles it
	slider:SetValue(curval)
	
	return container, slider, text, currentvalue
end

setmetatable(libslider, libmw.mt)