-- Name: SmartBags
-- Version: 1.3.0
-- Author: Reikan
-- Description:
-- * Show slots in inventory with color alert
-- * Show slots in bank with color alert
-- * ProgressBar for simple display
-- * Show gold in inventory / bank
-- * Show in chat log loots and golds received or lost
-- * Settings panel for all options

-- Saved variables
SmartBags = {
	name = "SmartBags";
	version = "v1.3.0";
	settingsVersion = 5;
	settingsDefaults = {
		ShowInfo = 0;
		LocalLang = "EN";
		LootLog = true;
		ShowTotalLoot = true;
		ShowPartyLoot = true;
		Unlock = true;
		WarningValue = 80;
		wndMain = {
			x = 79.699921;
			y = 85.441338;
		};
		normalStateColor = {
			r = 0;
			g = 1;
			b = 0.274510;
			a = 1;	
		};
		warningStateColor = {
			r = 1;
			g = 0.768627;
			b = 0.239216;
			a = 1;
		};
		fullStateColor = {
			r = 1;
			g = 0;
			b = 0.003922;
			a = 1;
		};
		LootGoldLogReceiveColor = {
			r = 0;
			g = 0.772549;
			b = 0.423529;
		};
		LootGoldLogPartyColor = {
			r = 0;
			g = 0.772549;
			b = 0.423529;
		};
		LootGoldLogLostColor = {
			r = 1;
			g = 0;
			b = 0.003922;
		}
	}
}

-- Addon variables
local AddonIsLoaded = false

-- Virtual Controls
local SB_ProgressBarMain
local SB_ProgressBarRight
local SB_ModeIcon

-------------------------------------------------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------------------------------------------------
function SmartBags.Initialize( eventCode, addOnName )
	-- Initialisation only for SmartBags
	if ( addOnName ~= SmartBags.name ) then
		return
	end
	
	-- Create settings
	SmartBags.settings = ZO_SavedVars:New("SmartBagsSettings" , SmartBags.settingsVersion, nil, SmartBags.settingsDefaults, nil);
	SmartBagsUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SmartBags.settings.wndMain.x, SmartBags.settings.wndMain.y);
		
	-- Refresh language variables at initialisation
	SB_Lang = SmartBags.settings.LocalLang
	SmartBags.SetLangVariables()
	
	LAM = LibStub:GetLibrary("LibAddonMenu-1.0")
	SmartBagsPanel = LAM:CreateControlPanel("SB_OptionsPanel", "SmartBags")
	LAM:AddHeader(SmartBagsPanel, "SB_OptionsStatesHeader", SB_Lang_Settings_MainOptionsTitle)
	LAM:AddCheckbox(SmartBagsPanel, "SB_LockFrameDefinition", SB_Lang_Settings_LockUnlockFrame, SB_Lang_Settings_LockUnlockFrame_ToolTip, function() return SmartBags.settings.Unlock end, SmartBags.SetUILock)
	LAM:AddColorPicker(SmartBagsPanel, "SB_NormalColor", SB_Lang_Settings_NormalStateColor, SB_Lang_Settings_NormalStateColor_ToolTip, SmartBags.GetNormalStateColor, SmartBags.SetNormalStateColor)
	LAM:AddColorPicker(SmartBagsPanel, "SB_WarningColor", SB_Lang_Settings_WarningStateColor, SB_Lang_Settings_WarningStateColor_ToolTip, SmartBags.GetWarningStateColor, SmartBags.SetWarningStateColor)
	LAM:AddColorPicker(SmartBagsPanel, "SB_FullColor", SB_Lang_Settings_FullStateColor, SB_Lang_Settings_FullStateColor_ToolTip, SmartBags.GetFullStateColor, SmartBags.SetFullStateColor)
	LAM:AddSlider(SmartBagsPanel, "SB_WarningValue", SB_Lang_Settings_PercentWarningState, SB_Lang_Settings_PercentWarningState_ToolTip, 0, 100, 1, SmartBags.GetWarningStateValue, SmartBags.SetWarningStateValue)
	LAM:AddHeader(SmartBagsPanel, "SB_OptionsLanguageHeader", SB_Lang_Settings_LangOptionsTitle)
	LAM:AddDropdown(SmartBagsPanel, "SB_LanguageDefinition", SB_Lang_Settings_LangOptionsSelection, SB_Lang_Settings_LangOptionsSelection_ToolTip, {"EN", "FR", "DE"}, function() return SmartBags.settings.LocalLang end, SmartBags.SetLang, true, SB_Lang_Settings_LangOptionsSelection_Warning_ToolTip)
	LAM:AddHeader(SmartBagsPanel, "SB_OptionsLootGodLogHeader", SB_Lang_Settings_LootGoldLogOptionsTitle)
	LAM:AddCheckbox(SmartBagsPanel, "SB_LootGoldLogDefinition", SB_Lang_Settings_LootGoldLogOptionsSelection, SB_Lang_Settings_LootGoldLogOptionsSelection_ToolTip, function() return SmartBags.settings.LootLog end, SmartBags.SetLootLog)
	LAM:AddCheckbox(SmartBagsPanel, "SB_LootGoldLog_ShowTotalItems", SB_LangLootGoldLog_ShowTotalItems, SB_LangLootGoldLog_ShowTotalItems_Tooltip, function() return SmartBags.settings.ShowTotalLoot end, SmartBags.SetLootLogShowTotalItems)
	LAM:AddCheckbox(SmartBagsPanel, "SB_LootGoldLog_ShowPartyItems", SB_LangLootGoldLog_ShowPartyItems, SB_LangLootGoldLog_ShowPartyItems_Tooltip, function() return SmartBags.settings.ShowPartyLoot end, SmartBags.SetLootLogShowPartyItems)
	LAM:AddColorPicker(SmartBagsPanel, "SB_LootGoldLog_ReceiveColor", SB_LangLootGoldLog_SettingsReceiveColor, "", SmartBags.GetLootGoldLogReceiveColor, SmartBags.SetLootGoldLogReceiveColor)
	LAM:AddColorPicker(SmartBagsPanel, "SB_LootGoldLog_LostColor", SB_LangLootGoldLog_SettingsLostColor, "", SmartBags.GetLootGoldLogLostColor, SmartBags.SetLootGoldLogLostColor)
	LAM:AddColorPicker(SmartBagsPanel, "SB_LootGoldLog_PartyColor", SB_LangLootGoldLog_SettingsPartyColor, "", SmartBags.GetLootGoldLogPartyColor, SmartBags.SetLootGoldLogPartyColor)
	LAM:AddHeader(SmartBagsPanel, "SB_About" , "SmartBags")
	local SmartBags_Description = "      Author: ReikanYsora \n      Version: " ..SmartBags.version
	LAM:AddDescription(SmartBagsPanel, "SB_Details", SmartBags_Description, "")
	
	-- Create virtuals controls
	SmartBagsUI:SetMovable(SmartBags.settings.Unlock)
	SB_ProgressBarMain = CreateControlFromVirtual("SmartBagsUI_Bag_PB", SmartBagsUI, "SmartBagsUI_Bag_ProgressBar")
	SB_ProgressBarRight = CreateControlFromVirtual("SmartBagsUI_Bag_PBR", SmartBagsUI, "SmartBagsUI_Bag_ProgressBarRight")
	SB_ModeIcon = CreateControlFromVirtual("BankBagIcon", SmartBagsUI, "SmartBagsUI_BankBagIcon")
		
	--Addon initialization ok
	AddonIsLoaded = true
	
	-- Loading addon
	SmartBags.InfosUpdate()	
end

-------------------------------------------------------------------------------------------------------------------------
-- DISPLAY INFO UPDATE
-------------------------------------------------------------------------------------------------------------------------
-- Main display update
function SmartBags.InfosUpdate()
	--Display
	if (AddonIsLoaded) then
		-- Bag mode
		if (SmartBags.settings.ShowInfo == 0) then
			-- Update controles
			SmartBags.ProgressBarUpdate(SmartBags.GetBagSlotsInfos(1))
			SmartBagsUIShowBagsInfos:SetText(string.format("%s", string.format("%s", string.format(SmartBags.SlotsColorCode(SmartBags.GetBagSlotsInfos(1))))))
			SmartBagsUIShowMoneyInfos:SetText(SmartBags.MoneyColorCode(SmartBags.FormatMoney(GetCurrentMoney())))			
			SB_ModeIcon:SetTexture("SmartBags/Textures/bag.dds")
		-- Bank mode
		else
			-- Update controles
			SmartBags.ProgressBarUpdate(SmartBags.GetBagSlotsInfos(2))
			SmartBagsUIShowBagsInfos:SetText(string.format("%s", string.format("%s", string.format(SmartBags.SlotsColorCode(SmartBags.GetBagSlotsInfos(2))))))
			SmartBagsUIShowMoneyInfos:SetText(SmartBags.MoneyColorCode(SmartBags.FormatMoney(GetBankedMoney())))			
			SB_ModeIcon:SetTexture("SmartBags/Textures/bank.dds")
		end
	end
end

-- Progressbar update
function SmartBags.ProgressBarUpdate(_value, _max)
	if (_value ~= nil) and (_value ~= nil) then
		--Calculate progressbar witdh
		width = (295 / tonumber(_max)) * tonumber(_value)
		
		--Calculate progressbar color
		-- Full
		if (_max == _value) then
			SB_ProgressBarMain:SetColor(SmartBags.settings.fullStateColor.r, SmartBags.settings.fullStateColor.g, SmartBags.settings.fullStateColor.b, SmartBags.settings.fullStateColor.a)
			SB_ProgressBarRight:SetColor(SmartBags.settings.fullStateColor.r, SmartBags.settings.fullStateColor.g, SmartBags.settings.fullStateColor.b, SmartBags.settings.fullStateColor.a)
		-- Warning
		elseif ((_value /_max * 100) >= SmartBags.settings.WarningValue) then
			SB_ProgressBarMain:SetColor(SmartBags.settings.warningStateColor.r, SmartBags.settings.warningStateColor.g, SmartBags.settings.warningStateColor.b, SmartBags.settings.warningStateColor.a)
			SB_ProgressBarRight:SetColor(SmartBags.settings.warningStateColor.r, SmartBags.settings.warningStateColor.g, SmartBags.settings.warningStateColor.b, SmartBags.settings.warningStateColor.a)
		-- Normal
		else
			SB_ProgressBarMain:SetColor(SmartBags.settings.normalStateColor.r, SmartBags.settings.normalStateColor.g, SmartBags.settings.normalStateColor.b, SmartBags.settings.normalStateColor.a)
			SB_ProgressBarRight:SetColor(SmartBags.settings.normalStateColor.r, SmartBags.settings.normalStateColor.g, SmartBags.settings.normalStateColor.b, SmartBags.settings.normalStateColor.a)
		end
		
		--Apply changes
		SB_ProgressBarMain:SetDimensions(width, 11)
		SB_ProgressBarRight:SetAnchor(RIGHT, SB_ProgressBarMain, RIGHT, 11)
	end	
end
    
-------------------------------------------------------------------------------------------------------------------------
-- BAG AND ITEM TOOLS FUNCTIONS
-------------------------------------------------------------------------------------------------------------------------
-- Get item link
function SmartBags.GetItemLink(_itemName)
	itemLink = ""
	_, bagSlots = GetBagInfo(1)
	
	-- Search and create item link
	for i = 0, bagSlots do
		if (_itemName == GetItemName(1, i)) then
			itemLink = GetItemLink(1, i, LINK_STYLE_BRACKETS)
		end
	end
	
	return SmartBags.FormatName(itemLink)
end

-- Return total items found in a bag
function SmartBags.GetTotalItemsInBagAndBank(_bagID, _itemName)
	nbItemsFound = 0
	_, bagSlots = GetBagInfo(_bagID)
	
	-- Searching item
	for i = 0, bagSlots do
		if (_itemName == GetItemName(_bagID, i)) then
			nbItemsFound = nbItemsFound + GetSlotStackSize(_bagID, i)
		end
	end
		
	return nbItemsFound
end

-- Return NotEmptySlots and total slots of a bag
function SmartBags.GetBagSlotsInfos(_BagID)
	bagNotEmptySlots = 0
	_, bagSlots = GetBagInfo(_BagID)
	
	-- Check for items in bag1 (bags)
	for i = 0, bagSlots do
		if (GetItemLink(_BagID, i, LINK_STYLE_DEFAULT) ~= "") then
			bagNotEmptySlots = bagNotEmptySlots + 1
		end
	end
	
	return bagNotEmptySlots, bagSlots
end

-------------------------------------------------------------------------------------------------------------------------
-- CHANGE DISPLAY FUNCTION
-------------------------------------------------------------------------------------------------------------------------
function SmartBags.GetMouseButtons(button)
	-- Left click => Allow movements
	if (button == 1) then
		-- If frame is unlock
		SmartBagsUI:SetMovable(SmartBags.settings.Unlock)
	-- Right click => change mode
	elseif (button == 2) then
		SmartBagsUI:SetMovable(false)
		if (SmartBags.settings.ShowInfo == 0) then
			SmartBags.settings.ShowInfo = 1
			displayModeText = SB_Lang_Mode_Bank
		else
			SmartBags.settings.ShowInfo = 0
			displayModeText = SB_Lang_Mode_Bag
		end
	
		-- Refresh and display informations
		SmartBags.InfosUpdate()
		d(string.format(SmartBags.Color(SmartBags.name, "69b7ff").." > %s", displayModeText))
	else
		SmartBagsUI:SetMovable(false)
	end	
end

-------------------------------------------------------------------------------------------------------------------------
-- CHAT LOG LOOT, PARTY LOOT AND MONEY DISPLAY
-------------------------------------------------------------------------------------------------------------------------
-- EVENT LOOT
function SmartBags.DisplayLootInfo(numID, lootedBy, itemName, quantity, itemSound, lootType, self)
	if (AddonIsLoaded) and (SmartBags.settings.LootLog) and (lootType ~= LOOT_TYPE_QUEST_ITEM) then
		-- if it's a player loot
		if (self) then
			SmartBags.DisplaySelfLoot(numID, itemName, quantity)
		-- if show party loot is enabled
		elseif (SmartBags.settings.ShowPartyLoot) then
			SmartBags.DisplayPartyLoot(numID, lootedBy, itemName, quantity)
		end	
	end
end

-- LOOT PARTY FUNCTION
function SmartBags.DisplayPartyLoot(numID, lootedBy, itemName, quantity)
	itemLinkBraked = SmartBags.Color("[", SmartBags.GetColorItem(itemName)).."%s"..SmartBags.Color("]", SmartBags.GetColorItem(itemName))
	itemLinkBraked = string.format(itemLinkBraked, SmartBags.FormatName(itemName))

	d(SmartBags.Color(string.format("[%s]%s", SmartBags.FormatName(lootedBy), SB_Lang_PartyReceived), SmartBags.GetLootGoldLogPartyHexaColor())..itemLinkBraked.. SmartBags.Color(string.format(" x%s.", quantity), SmartBags.GetLootGoldLogPartyHexaColor()))
end

-- LOOT SOLO FUNCTION
function SmartBags.DisplaySelfLoot(numID, itemName, quantity)
	local strName = ZO_LinkHandler_ParseLink(itemName)
	-- if show total enabled
	if (SmartBags.settings.ShowTotalLoot) then
		--Get total items (inventory and bank) if show total enabled	
		NbItemsInBag = SmartBags.Color(SmartBags.GetTotalItemsInBagAndBank(1, strName), "FFFFFF")
		NbItemsInBank = SmartBags.Color(SmartBags.GetTotalItemsInBagAndBank(2, strName), "FFFFFF")
		d(string.format(SmartBags.Color(SB_Lang_Received, SmartBags.GetLootGoldLogReceiveHexaColor()).."%s"..SmartBags.Color(string.format(" x%s. Total : %s %s %s%s", quantity, NbItemsInBag, SmartBags.Color("/", SmartBags.GetLootGoldLogReceiveHexaColor()),NbItemsInBank, SmartBags.Color(".", SmartBags.GetLootGoldLogReceiveHexaColor())), SmartBags.GetLootGoldLogReceiveHexaColor()), SmartBags.GetItemLink(strName)))
	else
		d(string.format(SmartBags.Color(SB_Lang_Received, SmartBags.GetLootGoldLogReceiveHexaColor()).."%s"..SmartBags.Color(string.format(" x%s.", quantity), SmartBags.GetLootGoldLogReceiveHexaColor()), SmartBags.GetItemLink(strName)))
	end
end

-- EVENT CRAFT
function SmartBags.DisplayCraftInfo()
	--Display in chat log
	if (SmartBags.settings.LootLog) then
		_, bagslots = GetBagInfo(1)
		itemCraftNum = GetNumLastCraftingResultItems()
		
		-- If the last craft event has created an item
		if (itemCraftNum >= 1) then
			for i=1, itemCraftNum, 1 do
				itemCraftInfo = {GetLastCraftingResultItemInfo(i)}
				for i=1 , bagslots, 1  do
					itemName = GetItemName(1, i)
					if (itemName == itemCraftInfo[1]) then
						-- Format itemLink
						itemLink = SmartBags.FormatName(GetItemLink(1, i, LINK_STYLE_BRACKETS))
						-- Get quantity informations
						quantity = itemCraftInfo[3]
						
						-- if show total enabled
						if (SmartBags.settings.ShowTotalLoot) then
							--Get total items (inventory and bank) if show total enabled
							NbItemsInBag = SmartBags.Color(SmartBags.GetTotalItemsInBagAndBank(1, itemName), "FFFFFF")
							NbItemsInBank = SmartBags.Color(SmartBags.GetTotalItemsInBagAndBank(2, itemName), "FFFFFF")
							d(string.format(SmartBags.Color(SB_Lang_Received, SmartBags.GetLootGoldLogReceiveHexaColor()).."%s"..SmartBags.Color(string.format(" x%s. Total : %s %s %s%s", quantity, NbItemsInBag, SmartBags.Color("/", SmartBags.GetLootGoldLogReceiveHexaColor()),NbItemsInBank, SmartBags.Color(".", SmartBags.GetLootGoldLogReceiveHexaColor())), SmartBags.GetLootGoldLogReceiveHexaColor()), itemLink))
						else
							d(string.format(SmartBags.Color(SB_Lang_Received, SmartBags.GetLootGoldLogReceiveHexaColor()).."%s"..SmartBags.Color(string.format(" x%s.", quantity), SmartBags.GetLootGoldLogReceiveHexaColor()), itemLink))
						end
						break	
					end
				end
			end	
		end
	end	
end

-- EVENT MONEY
function SmartBags.DisplayGoldInfo(eventCode, newMoney, oldMoney, reason)
	--Display in chat log
	if (AddonIsLoaded) and (SmartBags.settings.LootLog) and (newMoney ~= oldMoney) then
		-- Gold gain
		if (newMoney > oldMoney) then
			if (newMoney - oldMoney > 1) then
				moneyText = SB_Lang_Received.."%s "..SB_Lang_Golds.."."
			else
				moneyText = SB_Lang_Received.."%s "..SB_Lang_Gold.."."
			end
		
			-- Gain gold display
			moneyText = SmartBags.Color(string.format(moneyText, newMoney - oldMoney), SmartBags.GetLootGoldLogReceiveHexaColor())	
		-- Gold lost
		else
			if (oldMoney - newMoney  > 1) then
				moneyText = SB_Lang_Lost.."%s "..SB_Lang_Golds.."."
			else
				moneyText = SB_Lang_Lost.."%s "..SB_Lang_Gold.."."
			end
		
			-- Lost gold display
			moneyText = SmartBags.Color(string.format(moneyText, oldMoney - newMoney), SmartBags.GetLootGoldLogLostHexaColor())	
		end
		
		--Display in chat log
		d(moneyText)
		
		-- Actualization
		SmartBags.InfosUpdate()
	end	
end

-------------------------------------------------------------------------------------------------------------------------
-- TEXT AND COLOR TOOLS FUNCTIONS
-------------------------------------------------------------------------------------------------------------------------
-- Format money display
function SmartBags.FormatMoney(_money)
	_formatMoney = ""
	if (_money ~= 0) then
		local left,num,right = string.match(_money,'^([^%d]*%d)(%d*)(.-)$')
		_formatMoney = left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
	else
		_formatMoney = "0"
	end
	
	return _formatMoney
end

-- return color item name with color brackets
function SmartBags.GetColorItem(_itemName)
	local _, itemColor = ZO_LinkHandler_ParseLink(_itemName)
	if (not itemColor) then
        itemColor = "FFFFFF"
    end
	return itemColor
end

-- Format item name
function SmartBags.FormatName(_itemlink)
  return _itemlink:gsub("%^%a+","")
end

-- Return hexa from r, g or b color
function SmartBags.DecHex(num)
    local hexstr = "0123456789abcdef"
    local s = ""
	
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
	
    if (s == "") then
		s = "00"
	elseif (string.len(s) < 2) then
		s = "0"..s
	end
	
    return s
end

-- Format an hexa total color with r,g,b parameters
function SmartBags.HexaFromRGB(r, g, b)
	return SmartBags.DecHex(r*255)..SmartBags.DecHex(g*255)..SmartBags.DecHex(b*255)
end

-- Format color text
function SmartBags.Color(_text, _color)
	return string.format("|c%s".._text.."|r", _color)
end

-- Change text color for bags
function SmartBags.SlotsColorCode(_slots, _maxslots)
	local _returntemp = ""
	
	if (_slots == _maxslots) then
		_returntemp = string.format("%s/%s", SmartBags.Color(_slots, "ff0000"), SmartBags.Color(_maxslots, "ff0000"))
	elseif (_slots - _maxslots > 0) and (_slots - _maxslots <= 20) then
		_returntemp = string.format("%s/%s", SmartBags.Color(_slots, "ffa500"), SmartBags.Color(_maxslots, "ffa500"))
	else
		_returntemp = string.format("%s/%s", SmartBags.Color(_slots, "ffffff"), SmartBags.Color(_maxslots, "ffffff"))
	end
	
	return _returntemp
end

-- Change text color for money (red if Money value equal 0)
function SmartBags.MoneyColorCode(_money)
	local _returntemp = ""
	
	if (_money == "0") then
		_returntemp = SmartBags.Color(_money, "ff0000")
	else
		_returntemp = SmartBags.Color(_money, "ffffff")
	end
	
	return string.format(_returntemp)
end

-------------------------------------------------------------------------------------------------------------------------
-- ONMOVESTOP XML EVENT
-------------------------------------------------------------------------------------------------------------------------
function SmartBags.OnMoveStop(self)
	-- Save new frame position
	SmartBags.settings.wndMain.x = self:GetLeft();
	SmartBags.settings.wndMain.y = self:GetTop();
	SmartBags.settings.wndMain.width = self:GetWidth();
	SmartBags.settings.wndMain.height = self:GetHeight();	
end

-------------------------------------------------------------------------------------------------------------------------
-- EVENTS HANDLERS
-------------------------------------------------------------------------------------------------------------------------
-- ADD_ON_LOADED event
EVENT_MANAGER:RegisterForEvent("SmartBags" , EVENT_ADD_ON_LOADED , SmartBags.Initialize)
-- MONEY UPDATE
EVENT_MANAGER:RegisterForEvent("SmartBags", EVENT_MONEY_UPDATE, SmartBags.DisplayGoldInfo)
-- LOOT UPDATE
EVENT_MANAGER:RegisterForEvent("SmartBags", EVENT_LOOT_RECEIVED, SmartBags.DisplayLootInfo)
-- CRAFT LOOT UPDATE
EVENT_MANAGER:RegisterForEvent("SmartBags" , EVENT_CRAFT_COMPLETED, SmartBags.DisplayCraftInfo)
-- CHANGE ZONE EVENT ==> Force updating
EVENT_MANAGER:RegisterForEvent("SmartBags" , EVENT_ZONE_CHANNEL_CHANGED, SmartBags.InfosUpdate)
-- INVENTORY CHANGE => Update informations only on this event
EVENT_MANAGER:RegisterForEvent("SmartBags" , EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SmartBags.InfosUpdate)