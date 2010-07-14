--Made because some of the tekKonfig Widgets suck.
local libtab, oldminor = LibStub:NewLibrary("ManyWidgets-Tabs", 1)
if not libtab then return end

local floor, max, min = math.floor, math.max, math.min

function libtab:SetTextHelper(...)
	--self:GetHighlightTexture():SetWidth(30 + self:GetTextWidth())
	self:SetWidth(40 + self:GetTextWidth())
	return ...
end
function libtab:NewSetText(...) return libtab.SetTextHelper(self, self.OrigSetText(self, ...)) end



function libtab:ActivateTab()
	self.left:ClearAllPoints()
	self.left:SetPoint("TOPLEFT")
	self.left:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
	self.middle:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
	self.right:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
	self:Disable()

	--Move sapcers
	local container = self.tabcontainer
	local box = container.box
	local spacerleft = box.spacerleft
	local spacerright = box.spacerright
	
	spacerleft:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 10, -3)
	spacerright:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -10, -3)
	
	--Show the child of this tab
	self.child:Show()
end

function libtab:DeactivateTab()
	self.left:ClearAllPoints()
	self.left:SetPoint("BOTTOMLEFT", 0, 2)
	self.left:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	self.middle:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	self.right:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	self:Enable()
	
	--Hide the child of this tab
	self.child:Hide()
end

function libtab:Select(silent)
	if not silent then	PlaySound("igCharacterInfoTab")	end
	local container = self.tabcontainer
	container.selected:Deactivate()
	container.selected = self
	self:Activate()
end

function libtab:Tab_OnMouseWheel(d)
	local container = self.tabcontainer
	local size, id = container.numtabs, container.selected:GetID()
	local newid = id + (d > 0 and 1 or -1)
	if newid > 0 and newid <= size then 
		container.tabs[newid]:Select(true)
	end
end

function libtab:Tab_HideTooltip() GameTooltip:Hide() end
function libtab:Tab_ShowTooltip()
	if self.tiptext then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.tiptext, nil, nil, nil, 1, true)
	end
end

function libtab:CreateTab(text, tiptext)
	local tab = CreateFrame("Button", nil, self)
	tab:EnableMouseWheel(true)
	tab:SetHeight(24)
	--tab:SetFrameLevel(tab:GetFrameLevel() + 4)

	local left = tab:CreateTexture(nil, "BACKGROUND")
	left:SetWidth(20) left:SetHeight(24)
	left:SetTexCoord(0, 0.15625, 0, 1)
	tab.left = left
	
	local right = tab:CreateTexture(nil, "BACKGROUND")
	right:SetWidth(20) right:SetHeight(24)
	right:SetPoint("TOP", left)
	right:SetPoint("RIGHT", tab)
	right:SetTexCoord(0.84375, 1, 0, 1)
	tab.right = right
	
	local middle = tab:CreateTexture(nil, "BACKGROUND")
	middle:SetHeight(24)
	middle:SetPoint("LEFT", left, "RIGHT")
	middle:SetPoint("RIGHT", right, "Left")
	middle:SetTexCoord(0.15625, 0.84375, 0, 1)
	tab.middle = middle
	
	tab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight", "ADD")
	local hilite = tab:GetHighlightTexture()
	hilite:ClearAllPoints()
	hilite:SetPoint("LEFT", 10, -2)
	hilite:SetPoint("RIGHT", -10, -2)

	tab:SetDisabledFontObject(GameFontHighlightSmall)
	tab:SetHighlightFontObject(GameFontHighlightSmall)
	tab:SetNormalFontObject(GameFontNormalSmall)
	tab.OrigSetText = tab.SetText
	tab.SetText = libtab.NewSetText
	tab:SetText(text)
	
	tab.tiptext = tiptext
	tab:SetScript("OnClick", libtab.Select)
	tab:SetScript("OnEnter", libtab.Tab_ShowTooltip)
	tab:SetScript("OnLeave", libtab.Tab_HideTooltip)
	tab:SetScript("OnMouseWheel", libtab.Tab_OnMouseWheel)
	
	tab.Activate, tab.Deactivate, tab.Select = libtab.ActivateTab, libtab.DeactivateTab, libtab.Select

	return tab
end

function libtab:CreateNextTab(text)
	local box = self.box
	--parent stuff to the child frame, so when a tab is selected the child is shown
	local child = CreateFrame("Frame", nil, box)
	child:SetPoint("TOPLEFT", box.topleft, "BOTTOMRIGHT", -9, 9)
	child:SetPoint("BOTTOMRIGHT", box.bottomright, "TOPLEFT", 9, -9)
	child:Hide()
	
	local tab = libtab.CreateTab(self, text)
	tab.tabcontainer = self
	tab.child = child
	if not self.numtabs then
		self.numtabs = 1
		tab:SetPoint("TOPLEFT", 6, 0)
		tab:Activate()
		self.selected = tab
	else
		self.numtabs = self.numtabs + 1
		tab:SetPoint("TOPLEFT", self.tabs[self.numtabs - 1], "TOPRIGHT", -16, 0)
		tab:Deactivate()
	end
	tab:SetID(self.numtabs)
	self.tabs[self.numtabs] = tab
	
	return tab, child
end

function libtab:CreateBox()
	local box = CreateFrame("Frame", nil, self)
	
	local tl = box:CreateTexture(nil, "BORDER")
	tl:SetHeight(16); tl:SetWidth(16)
	tl:SetPoint("TOPLEFT")
	tl:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	tl:SetTexCoord(0.5, 0.625, 0, 1)
	box.topleft = tl
	
	local bl = box:CreateTexture(nil, "BORDER")
	bl:SetHeight(16); bl:SetWidth(16)
	bl:SetPoint("BOTTOMLEFT")
	bl:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	bl:SetTexCoord(0.75, 0.875, 0, 1)
	box.bottomleft = bl
	
	local br = box:CreateTexture(nil, "BORDER")
	br:SetHeight(16); br:SetWidth(16)
	br:SetPoint("BOTTOMRIGHT")
	br:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	br:SetTexCoord(0.875, 1, 0, 1)
	box.bottomright = br
	
	local tr = box:CreateTexture(nil, "BORDER")
	tr:SetHeight(16); tr:SetWidth(16)
	tr:SetPoint("TOPRIGHT")
	tr:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	tr:SetTexCoord(0.625, 0.75, 0, 1)
	box.topright = tr
	
	local left = box:CreateTexture(nil, "BORDER")
	left:SetPoint("TOPLEFT", tl, "BOTTOMLEFT")
	left:SetPoint("BOTTOMRIGHT", bl, "TOPRIGHT")
	left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	left:SetTexCoord(0, 0.125, 0, 1)
	box.left = left

	local right = box:CreateTexture(nil, "BORDER")
	right:SetPoint("TOPLEFT", tr, "BOTTOMLEFT")
	right:SetPoint("BOTTOMRIGHT", br, "TOPRIGHT")
	right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	right:SetTexCoord(0.125, 0.25, 0, 1)
	box.right = right
	
	local bottom = box:CreateTexture(nil, "BORDER")
	bottom:SetPoint("BOTTOMLEFT", bl, "BOTTOMRIGHT", 0, -2)
	bottom:SetPoint("TOPRIGHT", br, "TOPLEFT", 0, -2)
	bottom:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-Spacer")
	bottom:SetVertexColor(0.66, 0.66, 0.66)
	box.bottom = bottom
	
	local spacerleft = box:CreateTexture(nil, "BORDER") --the top texture to the left of the activated tab
	spacerleft:SetPoint("TOPLEFT", box.topleft, "TOPRIGHT", 0, 7)
	spacerleft:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-Spacer")
	box.spacerleft = spacerleft
	
	local spacerright = box:CreateTexture(nil, "BORDER") --the top texture to the right of the activated tab
	spacerright:SetPoint("TOPRIGHT", box.topright, "TOPLEFT", 0, 7)
	spacerright:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-Spacer")
	box.spacerright = spacerright
	
	--position
	box:SetPoint("BOTTOMRIGHT")
	box:SetPoint("TOPLEFT", 0, -18)
	
	--reference
	self.box = box
	
	return box
end

--[[Tab overflow prevention, removed because it's too big, and is very unweildy as a GUI.
function libtab:Scroll_OnScrollRangeChanged(xrange)
	local container = self:GetParent()
	local scroll = container.scroll
	local right, left = container.right, container.left
	xrange = xrange or self:GetHorizontalScrollRange()
	
	libtab.Scroll_OnScroll(self, self:GetHorizontalScroll())
	if floor(xrange) == 0 and right:IsShown() then
		right:Hide(); left:Hide()
		scroll:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", -6, -24)
	elseif not right:IsShown() then
		right:Show(); left:Show()
		scroll:SetPoint("BOTTOMRIGHT", left, "BOTTOMLEFT")
	end
end

function libtab:Scroll_OnScroll(offset)
	local container = self:GetParent()
	local min, max = 0, self:GetHorizontalScrollRange()
	if offset <= min then
		container.left:Disable()
		self:SetHorizontalScroll(min)
	else
		container.left:Enable()
	end
	if floor(offset) == floor(max) then
		container.right:Disable()
	else
		container.right:Enable()
	end
	local box = container.box
	box.spacerleft:Show()
	box.spacerright:Show()
	
end

function libtab:Scroll_OnSizeChanged(width, height)
	local child = self:GetScrollChild()
	child:SetHeight(height); child:SetWidth(width)
end

function libtab:CreateScrollFrame()
	local scroll = CreateFrame("ScrollFrame", nil, self)
	scroll:SetScript("OnScrollRangeChanged", libtab.Scroll_OnScrollRangeChanged)
	scroll:SetScript("OnHorizontalScroll", libtab.Scroll_OnScroll)
	scroll:SetScript("OnSizeChanged", libtab.Scroll_OnSizeChanged)
	
	--dimensions
	scroll:SetHeight(24)
	scroll:SetPoint("TOPLEFT", 16, 0)
	scroll:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 5, -24)
	--reference
	self.scroll = scroll
	
	--create scroll buttons
	libtab.CreateLeftRightButton(self)

	--create scroll child
	local scrollchild = CreateFrame("Frame", nil, scroll)
	scroll:SetScrollChild(scrollchild)
	
	--position
	scrollchild:SetPoint("TOPLEFT")
	
	--reference
	self.scrollchild = scrollchild
	
	return scroll, scrollchild
end
	
--scrollbuttons
function libtab:LeftRightButton_OnClick()
	local container = self:GetParent()
	local scroll = container.scroll
	scroll:SetHorizontalScroll(scroll:GetHorizontalScroll() - (scroll:GetHorizontalScrollRange() / floor((scroll:GetHorizontalScrollRange()/scroll:GetWidth())+0.5) * (container.left == self and 1 or -1)))
	PlaySound("UChatScrollButton")
end

function libtab:CreateRotatedTexture(texfile)
	local tex = self:CreateTexture()
	tex:SetAllPoints()
	tex:SetTexture(texfile)
	tex:SetRotation(math.pi/2)
	return tex
end

function libtab:CreateLeftRightButton()
	local left = CreateFrame("Button", nil, self)
	left:SetNormalTexture(libtab.CreateRotatedTexture(left, "Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Up"))
	left:SetPushedTexture(libtab.CreateRotatedTexture(left, "Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Down"))
	local leftdisabled = libtab.CreateRotatedTexture(left, "Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Up")
	leftdisabled:SetDesaturated(true)
	left:SetDisabledTexture(leftdisabled)
	local lefthighlight = libtab.CreateRotatedTexture(left, "Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Highlight")
	lefthighlight:SetBlendMode("ADD")
	left:SetHighlightTexture(lefthighlight)
	
	left:SetHitRectInsets(7, 7, 6, 6)
	left:SetScript("OnClick", libtab.LeftRightButton_OnClick)
	left:Disable()
	left:Hide()
	self.left = left
	
	local right = CreateFrame("Button", nil, self)
	right:SetNormalTexture(libtab.CreateRotatedTexture(right, "Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Up"))
	right:SetPushedTexture(libtab.CreateRotatedTexture(right, "Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Down"))
	local rightdisabled = libtab.CreateRotatedTexture(right, "Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Up")
	rightdisabled:SetDesaturated(true)
	right:SetDisabledTexture(rightdisabled)
	local righthighlight = libtab.CreateRotatedTexture(right, "Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Highlight")
	righthighlight:SetBlendMode("ADD")
	right:SetHighlightTexture(righthighlight)
	
	right:SetHitRectInsets(7, 7, 6, 6)
	right:SetScript("OnClick", libtab.LeftRightButton_OnClick)
	right:Disable()
	right:Hide()
	self.right = right
	
	--dimension
	left:SetHeight(32); left:SetWidth(38)
	right:SetHeight(32); right:SetWidth(38)
	
	--position
	left:SetPoint("TOPRIGHT", right, "TOPLEFT", 22, 0)
	right:SetPoint("TOPRIGHT", 0, 4)
	
	--reference
	self.left, self.right = left, right
	
	return left, right
end--]]

	
function libtab.New(parent)
	local tabcontainer = CreateFrame("Frame", nil, parent)
	tabcontainer.CreateNextTab = libtab.CreateNextTab
	tabcontainer.tabs = {}
		
	local box = libtab.CreateBox(tabcontainer)

	return tabcontainer
end

local mt = LibStub("ManyWidgets_Metatable", true)
if not mt then
	mt = LibStub:NewLibrary("ManyWidgets_Metatable")
	mt.__call = function(t, ...) return t.New(...) end
end
setmetatable(libbox, mt)