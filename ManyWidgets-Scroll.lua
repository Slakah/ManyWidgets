--Used to create a box type thing used mainly to group up widgets
local libscroll, oldminor = LibStub:NewLibrary("ManyWidgets-Scroll", 1)
if not libscroll then return end

local floor = math.floor

--General Scripts
function libscroll:SetStep(d)
	if not self.scrollbar then return end --scrollbar not there, scroll range not exceeded yet
	local scrollbar = self.scrollbar
	local scroll = self.scroll
	scrollbar:SetValue(scrollbar:GetValue() - scroll:GetVerticalScrollRange() / floor((scroll:GetVerticalScrollRange()/scroll:GetHeight())+0.5) * d)
end

--Scroll Scripts
function libscroll:Scroll_OnScrollRangeChanged(xrange, yrange)
	local container = self:GetParent()
	local scrollbar = container.scrollbar or libscroll.CreateScrollbar(container)
	yrange = yrange or self:GetVerticalScrollRange()

	scrollbar:SetMinMaxValues(0, yrange)
	scrollbar:SetValue(scrollbar:GetValue() > yrange and yrange or scrollbar:GetValue())
	if floor(yrange) == 0 and scrollbar:IsShown() then
		scrollbar:Hide()
		scrollbar:GetThumbTexture():Hide()
		self:ClearAllPoints()
		self:SetAllPoints()
	elseif not scrollbar:IsShown() then
		scrollbar:Show()
		scrollbar:GetThumbTexture():Show()
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT")
		self:SetPoint("BOTTOMRIGHT", scrollbar.down, "BOTTOMLEFT")
	end
end

function libscroll:Scroll_OnScroll(offset)
	local scrollbar = self:GetParent().scrollbar
	scrollbar:SetValue(offset)
	local min, max = scrollbar:GetMinMaxValues()
	if offset == 0 then
		scrollbar.up:Disable()
	else
		scrollbar.up:Enable()
	end
	if floor(offset) == floor(max) then
		scrollbar.down:Disable()
	else
		scrollbar.down:Enable()
	end
end

function libscroll:Scroll_OnSizeChanged(width, height)
	local child = self:GetScrollChild()
	child:SetHeight(height); child:SetWidth(width)
end

--Create Scroll
function libscroll:CreateScrollFrame()
	local scroll = CreateFrame("ScrollFrame", nil, self)
	scroll:SetScript("OnScrollRangeChanged", libscroll.Scroll_OnScrollRangeChanged)
	scroll:SetScript("OnVerticalScroll", libscroll.Scroll_OnScroll)
	scroll:SetScript("OnSizeChanged", libscroll.Scroll_OnSizeChanged)

	--position
	scroll:SetAllPoints()
	
	--reference
	self.scroll = scroll

	--create scrollchild
	local scrollchild = CreateFrame("Frame", nil, scroll)
	scroll:SetScrollChild(scrollchild)
	
	--reference
	self.scrollchild = scrollchild
	
	return scroll, scrollchild
end

--Scrollbar Scripts
function libscroll:Scrollbar_OnValueChanged(val)
	self:GetParent().scroll:SetVerticalScroll(val)
end

--Generic Up/Down ButtonScripts
function libscroll:UpDownButton_OnClick()
	local scrollbar = self:GetParent()
	libscroll.SetStep(scrollbar:GetParent(), scrollbar.up == self and 1 or -1)
	PlaySound("UChatScrollButton")
end

--Create Scrollbar
--note: tempted to move this to a seperate widget, lets see how it goes eh?
function libscroll:CreateScrollbar()
	local scrollbar = CreateFrame("Slider", nil, self)
	scrollbar:SetMinMaxValues(0, 0)
	scrollbar:SetScript("OnValueChanged", libscroll.Scrollbar_OnValueChanged)
	scrollbar:Hide()
	
	local up = CreateFrame("Button", nil, scrollbar, "UIPanelScrollUpButtonTemplate") --these inherited frames are nameless meaning we can use em'
	up:SetScript("OnClick", libscroll.UpDownButton_OnClick)
	up:Disable()
	scrollbar.up = up
	
	local down = CreateFrame("Button", nil, scrollbar, "UIPanelScrollDownButtonTemplate")
	down:SetScript("OnClick", libscroll.UpDownButton_OnClick)
	scrollbar.down = down
	
	scrollbar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	local thumb = scrollbar:GetThumbTexture()
	thumb:SetTexCoord(0.2, 0.8, 0.125, 0.875)
	thumb:Hide()
	
	--dimensions
	scrollbar:SetWidth(16)
	thumb:SetHeight(24); thumb:SetWidth(18) --up/down have their dimensions sorted straight away

	--position
	scrollbar:SetPoint("TOP", up, "BOTTOM", 0, 4)
	scrollbar:SetPoint("BOTTOM", down, "TOP", 0, -4)
	up:SetPoint("TOPRIGHT", self)
	down:SetPoint("BOTTOMRIGHT", self)
	
	--reference
	self.scrollbar = scrollbar

	return scrollbar, up, down
end

function libscroll.New(parent)
	local scrollcontainer = CreateFrame("Frame", nil, parent)
	scrollcontainer:EnableMouseWheel(true)
	scrollcontainer:SetScript("OnMouseWheel", libscroll.SetStep)
	
	local scroll, scrollchild = libscroll.CreateScrollFrame(scrollcontainer)
		
	return scrollcontainer, scrollchild
end