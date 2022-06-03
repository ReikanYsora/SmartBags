-- Name: SmartBags
-- Version: 1.1.0
-- Author: Reikan
-- Description: Show free slots, inventory slots, bank slots, money, bank money, global items quality / Affiche la place disponible dans l'inventaire, dans la banque, l'argent en poche et l'argent en banque, ainsi que la qualité moyenne des objets
-- To Do : Tooltip for items types

SmartBags = {}
SmartBags.name = "SmartBags"
SmartBags.version = "v1.1.0"
SmartBags.settingsVersion = 2;
SmartBags.settingsDefaults = {
	ShowInfo = 0;
	LocalLang = "EN";
	wndMain = {
		x = 0;
		y = 60;
	}
}
-- Format color text
function SmartBags.Color(_text, _color)
	return string.format("|c%s".._text.."|r", _color)
end

local ShowInfo = 0
local ShowAddonNameInfo = SmartBags.Color(SmartBags.name, "ffffcc")

-- Localisation variables
local Lang = "EN"
local Lang_Mode_Character = ""
local Lang_Mode_Bank = ""
local Lang_AddonIsMoving = ""
local Lang_DisplayOn = ""
local Lang_Language = ""
local Lang_ItemQuality = ""

-- Initialisation
function SmartBags.Initialize( eventCode, addOnName )
	-- Initialisation only for SmartBags
	if ( addOnName ~= SmartBags.name ) then
		return
	end
	
	-- Create settings
	SmartBags.settings = ZO_SavedVars:New( "SmartBagsSettings" , SmartBags.settingsVersion, nil, SmartBags.settingsDefaults, nil );
	SmartBagsUI:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, SmartBags.settings.wndMain.x, SmartBags.settings.wndMain.y );
		
	-- Get settings (SHOWINFO)
	if (SmartBags.settings.ShowInfo ~= 0) then
		ShowInfo = SmartBags.settings.ShowInfo
	end
	
	if (SmartBags.settings.LocalLang == "EN") then
		Lang = SmartBags.settings.LocalLang
	elseif (SmartBags.settings.LocalLang == "FR") then
		Lang = SmartBags.settings.LocalLang
	else
		Lang = "EN"
	end
		
	-- refresh language variables at initialisation
	SmartBags.SetLang()
end

-- ADD_ON_LOADED event
EVENT_MANAGER:RegisterForEvent("SmartBags" , EVENT_ADD_ON_LOADED , SmartBags.Initialize)

-- Language definition
function SmartBags.SetLang()
	if (Lang == "FR") then
		Lang_DisplayOn = "Affichage défini sur "
		Lang_Mode_Character = "Espace d'inventaire"
		Lang_Mode_Bank = "Espace de banque"
		Lang_Language = "Langue"
		Lang_ItemQuality = "Qualité des objets : "
		SmartBags.settings.LocalLang = "FR"
	else
		Lang_DisplayOn = "Display enabled on "
		Lang_Mode_Character = "Character inventory slots"
		Lang_Mode_Bank = "Bank slots"
		Lang_Language = "Language"
		Lang_ItemQuality = "Items quality : "
		SmartBags.settings.LocalLang = "EN"
	end	
	
	d(string.format("%s %s > [%s]", ShowAddonNameInfo, Lang_Language, Lang))
end

-- Localisation / SlashComand
function SmartBags.SlashCommand(_lang)
	if (_lang == "EN") or (_lang == "en") then
		Lang = "EN"
	elseif (_lang == "FR") or (_lang == "fr") then
		Lang = "FR"
	end
	
	-- refresh language variables at validation
	SmartBags.SetLang()
end

SLASH_COMMANDS["/smartbags"] = SmartBags.SlashCommand

function SmartBags.Update()
	--Display
	if (ShowInfo == 0) then
		SmartBagsUIShowInfos:SetText(string.format("%s : %s", Lang_Mode_Character,SmartBags.BagInfos()))
		SmartBagsUIShowMoneyInfos:SetText(SmartBags.GoldInfos())
		SmartBagsUIShowInfosQuality:SetText(Lang_ItemQuality..""..SmartBags.GetQualityItems(1))
	else
		SmartBagsUIShowInfos:SetText(string.format("%s : %s", Lang_Mode_Bank, SmartBags.BankInfos()))
		SmartBagsUIShowMoneyInfos:SetText(SmartBags.BankGoldInfos())
		SmartBagsUIShowInfosQuality:SetText(Lang_ItemQuality..""..SmartBags.GetQualityItems(2))
	end
end
-- Bags infos
function SmartBags.BagInfos()
	bagIcon = ""
	bagSlots = 0	
	bagEmptySlots = 0
	bagIcon, bagSlots = GetBagInfo(1)
	ShowInfoBagsText = ""
	
	-- Check for items in bag1 (bags)
	for i = 0, bagSlots do
		if (CheckInventorySpaceSilently(i) == true) then
			bagEmptySlots = i
		end
	end
	
	-- Bags
	ShowInfoBagsText = (string.format(SmartBags.SlotsColorCode(bagSlots - bagEmptySlots, bagSlots)))
	
	--Display
	return string.format("%s", ShowInfoBagsText)
end

-- Current money
function SmartBags.GoldInfos()
	return SmartBags.MoneyColorCode(GetCurrentMoney())
end

-- Bank infos
function SmartBags.BankInfos()
	bankIcon = ""
	bankSlots = 0	
	bankNotEmptySlots = 0
	bankIcon, bankSlots = GetBagInfo(2)
	ShowInfoBankText = ""
	
	-- Check for items in bag2 (bank)
	for i = 0, bankSlots do
		if (GetItemLink(2, i, LINK_STYLE_DEFAULT) ~= "") then
			bankNotEmptySlots = bankNotEmptySlots + 1
		end
	end
		
	-- Bank
	ShowInfoBankText = string.format(SmartBags.SlotsColorCode(bankNotEmptySlots, bankSlots))
		
	--Display
	return string.format("%s", ShowInfoBankText)
end

-- Current bank money
function SmartBags.BankGoldInfos()
	return SmartBags.MoneyColorCode(GetBankedMoney())
end

-- Change display functions
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
		
		SmartBags.settings.ShowInfo = ShowInfo	
		d(string.format(ShowAddonNameInfo.." > %s(%s)", Lang_DisplayOn, display))
	end	
end

-- Items quality
function SmartBags.GetQualityItems(_bagID)
	bagIcon = ""
	bagSlots = 0	
	bagIcon, bagSlots = GetBagInfo(_bagID)		
	item_1 = 0
	item_2 = 0
	item_3 = 0
	item_4 = 0
	item_5 = 0
	item_6 = 0
	
	-- Check type items
	for i = 0, bagSlots do
		if (GetItemInfo(_bagID, i) ~= nil) then
			local _, _, _, _, _, _, _, quality = GetItemInfo(_bagID, i)
			
			if (quality == 1) then
				item_1 = item_1 + 1
			elseif (quality == 2) then
				item_2 = item_2 + 1
			elseif (quality == 3) then
				item_3 = item_3 + 1
			elseif (quality == 4) then
				item_4 = item_4 + 1
			elseif (quality == 5) then
				item_5 = item_5 + 1
			end
		end
	end
	
	return string.format("[%s] [%s] [%s] [%s] [%s]", SmartBags.Color(item_1, "ffffff"), SmartBags.Color(item_2, "7cfc00"), SmartBags.Color(item_3, "007AF5"), SmartBags.Color(item_4, "C20AFF"), SmartBags.Color(item_5, "FFCC33"))
end

-- TEXTS COLOR
-- Change text color for bags
function SmartBags.SlotsColorCode(_slots, _maxslots)
	local _returntemp = ""
	
	if (_slots == _maxslots) then
		_returntemp = string.format("%s/%s", SmartBags.Color(_slots, "cc0000"), SmartBags.Color(_maxslots, "cc0000"))
	elseif (_slots - _maxslots > 0) and (_slots - _maxslots <= 20) then
		_returntemp = string.format("%s/%s", SmartBags.Color(_slots, "cc6600"), SmartBags.Color(_maxslots, "ffffff"))
	else
		_returntemp = string.format("%s/%s", SmartBags.Color(_slots, "ffffff"), SmartBags.Color(_maxslots, "ffffff"))
	end
	
	return _returntemp
end

-- Change text color for money (red if Money value equal 0)
function SmartBags.MoneyColorCode(_money)
	local _returntemp = ""
	
	if (_money == 0) then
		_returntemp = SmartBags.Color(_money, "cc0000")
	else
		_returntemp = SmartBags.Color(_money, "ffffff")
	end
	
	return string.format(_returntemp)
end

-- OnMoveStop Event
function SmartBags.OnMoveStop(self)
	SmartBags.settings.wndMain.x = self:GetLeft();
	SmartBags.settings.wndMain.y = self:GetTop();
	SmartBags.settings.wndMain.width = self:GetWidth();
	SmartBags.settings.wndMain.height = self:GetHeight();	
end