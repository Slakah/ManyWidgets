--Made because some of the tekKonfig Widgets suck.
local libeditbox, oldminor = LibStub:NewLibrary("ManyWidgets-Editbox", 1)
if not libeditbox then return end

--Requires: ManyWidgets
local libmw = assert(LibStub("ManyWidgets", true), "ManyWidgets-Editbox requires ManyWidgets to function")

local fmod = math.fmod

function libeditbox:Enable()
	if self.enabled then return end
	
	self:SetAlpha(1)
	self:EnableMouse(true)
	self.label:Enable()

	local editbox = self.editbox
	editbox:EnableMouse(true)
	editbox:SetTextColor(1, 1, 1)
	
	self.enabled = true
end

function libeditbox:Disable()
	if not self.enabled then return end
	
	self.label:Disable()
	self:SetAlpha(0.75)
	self:EnableMouse(false)
	
	local editbox = self.editbox
	editbox:EnableMouse(false)
	editbox:SetTextColor(0.5, 0.5, 0.5)
	editbox:ClearFocus()

	self.enabled = false
end

function libeditbox:Editbox_OnTabPressed()
	if self.editboxorder and self:GetID() then
		local id, origid, size, editbox = self:GetID(), self:GetID(), #self.editboxorder
		local shiftmod = IsShiftKeyDown() and size-2 or 0
		repeat
			id = fmod(id + shiftmod, size) + 1 --math trickery
			editbox = self.editboxorder[id]
		until editbox:IsShown() and self.editboxorder[id]:GetParent().enabled
		
		editbox:SetFocus()
		editbox:HighlightText()
	end
end

function libeditbox:Editbox_ClearHighlight()
	self:HighlightText(0,0)
end

function libeditbox:CreateEditbox()
	local editbox = CreateFrame("Editbox", nil, self)
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetJustifyH("LEFT")
	editbox:EnableMouse(true)
	editbox:SetHeight(20)
	
	editbox:SetScript("OnEscapePressed", editbox.ClearFocus)
	editbox:SetScript("OnEnterPressed", editbox.ClearFocus)
	editbox:SetScript("OnTabPressed", libeditbox.Editbox_OnTabPressed)
	editbox:SetScript("OnEditFocusLost", libeditbox.Editbox_ClearHighlight)

	--taken from tekkubs tekKonfigAboutPanel
	local left = editbox:CreateTexture(nil, "BACKGROUND")
	left:SetPoint("TOPLEFT", -5, 0); left:SetPoint("BOTTOMLEFT", -5, 0)
	left:SetWidth(8)
	left:SetTexture("Interface\\Common\\Common-Input-Border")
	left:SetTexCoord(0, 0.0625, 0, 0.625)
	editbox.left = left
	
	local right = editbox:CreateTexture(nil, "BACKGROUND")
	right:SetPoint("TOPRIGHT", 0, 0); right:SetPoint("BOTTOMRIGHT", 0, 0)
	right:SetWidth(8)
	right:SetTexture("Interface\\Common\\Common-Input-Border")
	right:SetTexCoord(0.9375, 1, 0, 0.625)
	editbox.right = right
	
	local center = editbox:CreateTexture(nil, "BACKGROUND")
	center:SetPoint("TOPRIGHT", right, "TOPLEFT", 0, 0)
	center:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT", 0, 0)
	center:SetTexture("Interface\\Common\\Common-Input-Border")
	center:SetTexCoord(0.0625, 0.9375, 0, 0.625)
	editbox.center = center

	return editbox
end


function libeditbox:Label_SelectEditbox()
	local editbox = self:GetParent().editbox
	editbox:SetFocus(true)
	editbox:HighlightText()
end


function libeditbox.New(parent, label, editboxorder, id)
	local container = CreateFrame("Frame", nil, parent)
	container:EnableMouse(true)
	--container:SetScript("OnMouseDown", libeditbox.SelectEditbox)
	container:SetHeight(35); container:SetWidth(144)
	
	container:SetScript("OnEnter", libmw.ShowTooltip)
	container:SetScript("OnLeave", libmw.HideTooltip)
	
	local editbox = libeditbox.CreateEditbox(container)
	editbox:SetID(id)
	editboxorder[id] = editbox
	editbox.editboxorder = editboxorder
	container.editbox = editbox
	
	

	local text = CreateFrame("Button", nil, container)
	text:SetDisabledFontObject(GameFontDisableLeft)
	--text:SetHighlightFontObject(GameFontHighlightLeft)
	text:SetNormalFontObject(GameFontNormalLeft)
	text:SetText(label)
	text:SetScript("OnClick", libeditbox.Label_SelectEditbox)
	container.label = text
	
	--Position
	editbox:SetPoint("BOTTOMLEFT", 5, 0); editbox:SetPoint("BOTTOMRIGHT")
	text:SetPoint("TOPLEFT"); text:SetPoint("BOTTOMRIGHT", editbox, "TOPRIGHT")
	
	--Add some of our own methods
	container.Enable = libeditbox.Enable
	container.Disable = libeditbox.Disable
	
	--Set enabled state
	container.enabled = true
	
	return container, editbox, text
end

setmetatable(libeditbox, libmw.mt)
