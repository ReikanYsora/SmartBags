-- Name: SmartBags
-- Version: 1.2.0
-- Author: Reikan
-- Description:
-- * Show slots in inventory with color alert
-- * Show slots in bank with color alert
-- * ProgressBar for simple display
-- * Show gold in inventory / bank
-- * Show in chat log loots and golds received or lost

-- Saved variables
SmartBags = {}
SmartBags.name = "SmartBags"
SmartBags.version = "v1.2.0"
SmartBags.settingsVersion = 2;
SmartBags.settingsDefaults = {
	ShowInfo = 0;
	LocalLang = "EN";
	LootLog = true;
	wndMain = {
		x = 0;
		y = 60;
	}
}

local ShowInfo = 0
local LootLog = true
local ShowAddonNameInfo = SmartBags.name

-- Localisation variables
local Lang = "EN"
local Lang_Mode_Character = ""
local Lang_Mode_Bank = ""
local Lang_AddonIsMoving = ""
local Lang_DisplayOn = ""
local Lang_Language = ""
-- LootLog
local Lang_LootReceived = ""
local Lang_Lost = ""
local Lang_Gold = ""
local Lang_Golds = ""

-- Colors variables
local cGray = "a8a8a8"
local cWhite = "ffffff"
local cGreen = "7cfc00"
local cBlue = "0000ff"
local cPurple = "800080"
local cOrange = "ffa500"
local cRed = "ff0000"
local cAddOn = "69b7ff"

--Controls
local progressBar
local progressBarRight
local bankbagicon

-------------------------------------------------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------------------------------------------------
function SmartBags.Initialize( eventCode, addOnName )
	-- Initialisation only for SmartBags
	if ( addOnName ~= SmartBags.name ) then
		return
	end
	
	-- Create settings
	SmartBags.settings = ZO_SavedVars:New( "SmartBagsSettings" , SmartBags.settingsVersion, nil, SmartBags.settingsDefaults, nil );
	SmartBagsUI:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, SmartBags.settings.wndMain.x, SmartBags.settings.wndMain.y );
		
	-- Get settings (SHOWINFO)
	if (SmartBags.settings.LootLog == false) then
		LootLog = SmartBags.settings.LootLog
	end
	
	-- Get settings (LOOTLOGDISPLAY)
	if (SmartBags.settings.ShowInfo ~= 0) then
		ShowInfo = SmartBags.settings.ShowInfo
	end
	
	if (SmartBags.settings.LocalLang == "EN") then
		Lang = SmartBags.settings.LocalLang
	elseif (SmartBags.settings.LocalLang == "FR") then
		Lang = SmartBags.settings.LocalLang
	elseif (SmartBags.settings.LocalLang == "DE") then
		Lang = SmartBags.settings.LocalLang
	end
		
	-- Create virtuals controls
	progressBar = CreateControlFromVirtual("SmartBagsUI_Bag_PB", SmartBagsUI, "SmartBagsUI_Bag_ProgressBar")
	progressBarRight = CreateControlFromVirtual("SmartBagsUI_Bag_PBR", SmartBagsUI, "SmartBagsUI_Bag_ProgressBarRight")
	bankbagicon = CreateControlFromVirtual("BankBagIcon", SmartBagsUI, "SmartBagsUI_BankBagIcon")
		
	-- Refresh language variables at initialisation
	SmartBags.SetLang()
	
	-- Refresh informations 
	SmartBags.InfosUpdate()
end

-------------------------------------------------------------------------------------------------------------------------
-- LOCALIZATION /SLASHCOMMAND
-------------------------------------------------------------------------------------------------------------------------
function SmartBags.SlashCommand(_code)
	if (string.upper(_code) == "LOGON") then
		LootLog = true
		SmartBags.settings.LootLog = true
		d(string.format(SmartBags.Color(ShowAddonNameInfo, cOrange).." > LootLog ON"))
	elseif (string.upper(_code) == "LOGOFF") then
		LootLog = false
		SmartBags.settings.LootLog = false
		d(string.format(SmartBags.Color(ShowAddonNameInfo, cOrange).." > LootLog OFF"))
	elseif (string.upper(_code) == "EN") then
		Lang = "EN"
		-- refresh language variables at validation
		SmartBags.SetLang()
	elseif (string.upper(_code) == "DE") then
		Lang = "DE"
		-- refresh language variables at validation
		SmartBags.SetLang()
	elseif (string.upper(_code) == "FR") then
		Lang = "FR"
		-- refresh language variables at validation
		SmartBags.SetLang()
	else
		d(SmartBags.Color(ShowAddonNameInfo, cOrange).." [/Smartbags ".._code.."] command doesn't exist")
	end
end

SLASH_COMMANDS["/smartbags"] = SmartBags.SlashCommand
SLASH_COMMANDS["/sb"] = SmartBags.SlashCommand

-- Language definition
function SmartBags.SetLang()
	if (Lang == "FR") then
		Lang_DisplayOn = "MODE "
		Lang_Mode_Character = "[Inventaire]"
		Lang_Mode_Bank = "[Banque]"
		Lang_Language = "Langue"		
		Lang_Received = "Vous recevez "
		Lang_Gold = "pièce d'or"
		Lang_Golds = "pièces d'or"		
		Lang_Lost = "Vous perdez "
		SmartBags.settings.LocalLang = "FR"
	elseif (Lang == "DE") then
		Lang_DisplayOn = "MODE "
		Lang_Mode_Character = "[Inventar]"
		Lang_Mode_Bank = "[Bank]"
		Lang_Language = "Sprache"
		Lang_Received = "Sie erhalten "
		Lang_Gold = "goldmünze"
		Lang_Golds = "goldmünzen"	
		Lang_Lost = "Sie verlieren "
		SmartBags.settings.LocalLang = "DE"
	elseif (Lang == "EN") then
		Lang_DisplayOn = "MODE "
		Lang_Mode_Character = "[Inventory]"
		Lang_Mode_Bank = "[Bank]"
		Lang_Language = "Language"
		Lang_Received = "You receive "
		Lang_Gold = "gold"
		Lang_Golds = "golds"	
		Lang_Lost = "You lose "
		SmartBags.settings.LocalLang = "EN"
	end	
	
	d(string.format("%s %s > [%s]", SmartBags.Color(ShowAddonNameInfo, cOrange), Lang_Language, Lang))
	
	-- Refresh informations 
	SmartBags.InfosUpdate()
end

-------------------------------------------------------------------------------------------------------------------------
-- DISPLAY INFO UPDATE
-------------------------------------------------------------------------------------------------------------------------
-- Main display update
function SmartBags.InfosUpdate()
	--Display
	if (ShowInfo == 0) then
		-- Update controles
		SmartBags.ProgressBarUpdate(SmartBags.GetBagSlotsInfos(1))
		bankbagicon:SetTexture("SmartBags/media/bag.dds")
		SmartBagsUIShowBagsInfos:SetText(string.format("%s", string.format("%s", string.format(SmartBags.SlotsColorCode(SmartBags.GetBagSlotsInfos(1))))))
		SmartBagsUIShowMoneyInfos:SetText(SmartBags.MoneyColorCode(GetCurrentMoney()))
	else
		-- Update controles
		SmartBags.ProgressBarUpdate(SmartBags.GetBagSlotsInfos(2))
		bankbagicon:SetTexture("SmartBags/media/bank.dds")
		SmartBagsUIShowBagsInfos:SetText(string.format("%s", string.format("%s", string.format(SmartBags.SlotsColorCode(SmartBags.GetBagSlotsInfos(2))))))
		SmartBagsUIShowMoneyInfos:SetText(SmartBags.MoneyColorCode(GetBankedMoney()))
	end
end

-- Progressbar update
function SmartBags.ProgressBarUpdate(_value, _max)
	if (_value ~= nil) and (_value ~= nil) then
		--Calculate progressbar witdh
		width = (295 / tonumber(_max)) * tonumber(_value)
		
		--Calculate progressbar color
		if (_max == _value) then
			progressBar:SetColor(1,0,0,1)
			progressBarRight:SetColor(1,0,0,1)
		elseif (_max - _value <= 10)then
			progressBar:SetColor(0.9, 0.65, 0.18, 1)
			progressBarRight:SetColor(0.9, 0.65, 0.18, 1)
		else
			progressBar:SetColor(0.4, 0.73, 0.22, 1)
			progressBarRight:SetColor(0.4, 0.73, 0.22, 1)
		end
		
		--Apply changes
		progressBar:SetDimensions(width, 45)
		progressBarRight:SetAnchor(RIGHT, progressBar, RIGHT, 10)		
		progressBar:SetHidden(false)
		progressBarRight:SetHidden(false)
	else
		progressBar:SetHidden(true)
		progressBarRight:SetHidden(true)
	end	
end
    
-------------------------------------------------------------------------------------------------------------------------
-- BAG AND ITEM TOOLS FUNCTIONS
-------------------------------------------------------------------------------------------------------------------------
function SmartBags.GetItemLink(_itemName)
	itemLink = ""
	_, bagSlots = GetBagInfo(1)
	
	-- Search and create item link
	for i = 0, bagSlots do
		if (_itemName == GetItemName(1, i)) then
			itemLink = GetItemLink(1, i, LINK_STYLE_BRACKETS)
		end
	end
	
	return itemLink
end

-- Return total items found in a bag
function SmartBags.FindObjectInBag(_bagID, _itemName)
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
	if (button == 1) then
		SmartBagsUI:SetMovable(true)
	elseif (button == 2) then
		SmartBagsUI:SetMovable(false)
		display = ""
		if (ShowInfo == 0) then
			ShowInfo = 1
			display = Lang_Mode_Bank
		else
			ShowInfo = 0
			display = Lang_Mode_Character
		end
		
		SmartBags.InfosUpdate()
		SmartBags.settings.ShowInfo = ShowInfo	
		d(string.format(SmartBags.Color(ShowAddonNameInfo, cOrange).." > %s %s", Lang_DisplayOn, display))
	end	
end

-------------------------------------------------------------------------------------------------------------------------
-- CHAT LOG LOOT AND MONEY DISPLAY
-------------------------------------------------------------------------------------------------------------------------
function SmartBags.DisplayLootInfo(numID, lootedBy, itemName, quantity, itemSound, lootType, self)
	--Get total items (inventory and bank)
	local strName = ZO_LinkHandler_ParseLink(itemName)
	local NbItemsInBag = SmartBags.FindObjectInBag(1, strName)
	local NbItemsInBank = SmartBags.FindObjectInBag(2, strName)
	
	--Display in chat log
	if (LootLog) then
		d(string.format(SmartBags.Color(Lang_Received, cGreen).."%s"..SmartBags.Color(string.format(" x%s (Total : %s).", quantity, NbItemsInBag + NbItemsInBank), cGreen), SmartBags.GetItemLink(strName)))
	end	
end

-- Display in log gain/lost gold value
function SmartBags.DisplayGoldInfo(eventCode, newMoney, oldMoney, reason)
	moneyText = ""
	
	-- Gold gain
	if (newMoney > oldMoney) then
		if (newMoney - oldMoney > 1) then
			moneyText = Lang_Received.."%s "..Lang_Golds.."."
		elseif (newMoney - oldMoney == 1) then
			moneyText = Lang_Received.."%s "..Lang_Gold.."."
		end
	
		-- Gain gold display
		moneyText = SmartBags.Color(string.format(moneyText, newMoney - oldMoney), cGreen)	
	-- Gold lost
	elseif (newMoney < oldMoney) then
		if (oldMoney - newMoney  > 1) then
			moneyText = Lang_Lost.."%s "..Lang_Golds.."."
		elseif (oldMoney - newMoney  == 1) then
			moneyText = Lang_Lost.."%s "..Lang_Gold.."."
		end
	
		-- Lost gold display
		moneyText = SmartBags.Color(string.format(moneyText, oldMoney - newMoney), cRed)	
	end
	
	--Display in chat log
	if (moneyText ~= "") and (LootLog) then
		d(moneyText)
	end	
end

-------------------------------------------------------------------------------------------------------------------------
-- COLOR TOOLS FUNCTIONS
-------------------------------------------------------------------------------------------------------------------------
-- Format color text
function SmartBags.Color(_text, _color)
	return string.format("|c%s".._text.."|r", _color)
end

-- Change text color for bags
function SmartBags.SlotsColorCode(_slots, _maxslots)
	local _returntemp = ""
	
	if (_slots == _maxslots) then
		_returntemp = string.format("%s/%s", SmartBags.Color(_slots, cRed), SmartBags.Color(_maxslots, cRed))
	elseif (_slots - _maxslots > 0) and (_slots - _maxslots <= 20) then
		_returntemp = string.format("%s/%s", SmartBags.Color(_slots, cOrange), SmartBags.Color(_maxslots, cOrange))
	else
		_returntemp = string.format("%s/%s", SmartBags.Color(_slots, cWhite), SmartBags.Color(_maxslots, cWhite))
	end
	
	return _returntemp
end

-- Change text color for money (red if Money value equal 0)
function SmartBags.MoneyColorCode(_money)
	local _returntemp = ""
	
	if (_money == 0) then
		_returntemp = SmartBags.Color(_money, cRed)
	else
		_returntemp = SmartBags.Color(_money, cWhite)
	end
	
	return string.format(_returntemp)
end

-------------------------------------------------------------------------------------------------------------------------
-- ONMOVESTOP XML EVENT
-------------------------------------------------------------------------------------------------------------------------
function SmartBags.OnMoveStop(self)
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
-- INVENTORY CHANGE
EVENT_MANAGER:RegisterForEvent("SmartBags" , EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SmartBags.InfosUpdate)