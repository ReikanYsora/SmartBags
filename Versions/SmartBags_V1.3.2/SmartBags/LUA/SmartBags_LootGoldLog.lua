-- Name: SmartBags
-- Version: 1.3.2
-- Author: Reikan
-- Description:
-- * Show in chat log loots and golds received or lost

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
		d(string.format(SmartBags.Color(SB_Lang_Received, SmartBags.GetLootGoldLogReceivedLootHexaColor()).."%s"..SmartBags.Color(string.format(" x%s. Total : %s %s %s%s", quantity, NbItemsInBag, SmartBags.Color("/", SmartBags.GetLootGoldLogReceivedLootHexaColor()),NbItemsInBank, SmartBags.Color(".", SmartBags.GetLootGoldLogReceivedLootHexaColor())), SmartBags.GetLootGoldLogReceivedLootHexaColor()), SmartBags.GetItemLink(strName)))
	else
		d(string.format(SmartBags.Color(SB_Lang_Received, SmartBags.GetLootGoldLogReceivedLootHexaColor()).."%s"..SmartBags.Color(string.format(" x%s.", quantity), SmartBags.GetLootGoldLogReceivedLootHexaColor()), SmartBags.GetItemLink(strName)))
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
							d(string.format(SmartBags.Color(SB_Lang_Received, SmartBags.GetLootGoldLogReceivedLootHexaColor()).."%s"..SmartBags.Color(string.format(" x%s. Total : %s %s %s%s", quantity, NbItemsInBag, SmartBags.Color("/", SmartBags.GetLootGoldLogReceivedLootHexaColor()),NbItemsInBank, SmartBags.Color(".", SmartBags.GetLootGoldLogReceivedLootHexaColor())), SmartBags.GetLootGoldLogReceivedLootHexaColor()), itemLink))
						else
							d(string.format(SmartBags.Color(SB_Lang_Received, SmartBags.GetLootGoldLogReceivedLootHexaColor()).."%s"..SmartBags.Color(string.format(" x%s.", quantity), SmartBags.GetLootGoldLogReceivedLootHexaColor()), itemLink))
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
		if (SmartBags.settings.ShowGolds) then
			-- Gold gain
			if (newMoney > oldMoney) then
				if (newMoney - oldMoney > 1) then
					moneyText = SB_Lang_Received.."%s "..SB_Lang_Golds.."."
				else
					moneyText = SB_Lang_Received.."%s "..SB_Lang_Gold.."."
				end
			
				-- Gain gold display
				moneyText = SmartBags.Color(string.format(moneyText, newMoney - oldMoney), SmartBags.GetLootGoldLogReceivedGoldHexaColor())	
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
		end
		
		-- Actualization
		SmartBags.InfosUpdate()
	end	
end


-------------------------------------------------------------------------------------------------------------------------
-- TEXT AND COLOR TOOLS FUNCTIONS
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

-- Format money display
function SmartBags.FormatMoney(_money)
	_formatMoney = ""
	if (_money ~= 0) then
		-- In the EN / DE version, coma replace dot
		local left,num,right = string.match(_money,'^([^%d]*%d)(%d*)(.-)$')
		if (SmartBags.settings.LocalLang == "FR") then
			_formatMoney = left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
		else
			_formatMoney = left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
		end		
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

-------------------------------------------------------------------------------------------------------------------------
-- EVENTS HANDLERS
-------------------------------------------------------------------------------------------------------------------------

-- MONEY UPDATE
EVENT_MANAGER:RegisterForEvent("SmartBags", EVENT_MONEY_UPDATE, SmartBags.DisplayGoldInfo)
-- LOOT UPDATE
EVENT_MANAGER:RegisterForEvent("SmartBags", EVENT_LOOT_RECEIVED, SmartBags.DisplayLootInfo)
-- CRAFT LOOT UPDATE
EVENT_MANAGER:RegisterForEvent("SmartBags" , EVENT_CRAFT_COMPLETED, SmartBags.DisplayCraftInfo)