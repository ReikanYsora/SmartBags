-- Name: SmartBags
-- Version: 1.3.0
-- Author: Reikan
-- Localization functions (FR / DE / EN)
-- !If translations can be improved, please do not hesitate to let me know!

-- Localisation variables
SB_Lang = "EN"
SB_Lang_Mode_Bag = ""
SB_Lang_Mode_Bank = ""
SB_Lang_Language = ""

-- LootGoldLog
SB_Lang_Received = ""
SB_Lang_PartyReceived = ""
SB_Lang_Lost = ""
SB_Lang_Gold = ""
SB_Lang_Golds = ""

-- Settings panel
SB_Lang_Settings_MainOptionsTitle = ""
SB_Lang_Settings_LockUnlockFrame = ""
SB_Lang_Settings_LockUnlockFrame_ToolTip = ""
SB_Lang_Settings_NormalStateColor = ""
SB_Lang_Settings_NormalStateColor_ToolTip = ""
SB_Lang_Settings_WarningStateColor = ""
SB_Lang_Settings_WarningStateColor_ToolTip = ""
SB_Lang_Settings_FullStateColor = ""
SB_Lang_Settings_FullStateColor_ToolTip = ""
SB_Lang_Settings_PercentWarningState = ""
SB_Lang_Settings_PercentWarningState_ToolTip = ""
SB_Lang_Settings_LangOptionsTitle = ""
SB_Lang_Settings_LangOptionsSelection = ""
SB_Lang_Settings_LangOptionsSelection_ToolTip = ""
SB_Lang_Settings_LangOptionsSelection_Warning_ToolTip = ""
SB_Lang_Settings_LootGoldLogOptionsTitle = ""
SB_Lang_Settings_LootGoldLogOptionsSelection = ""
SB_Lang_Settings_LootGoldLogOptionsSelection_ToolTip = ""
SB_LangLootGoldLog_SettingsReceiveColor = ""
SB_LangLootGoldLog_SettingsLostColor = ""
SB_LangLootGoldLog_ShowTotalItems = ""
SB_LangLootGoldLog_ShowTotalItems_Tooltip = ""
SB_LangLootGoldLog_ShowPartyItems = ""
SB_LangLootGoldLog_ShowPartyItems_Tooltip = ""
SB_LangLootGoldLog_SettingsPartyColor = ""

-- Language definition
function SmartBags.SetLangVariables()
	-- FR
	if (SmartBags.settings.LocalLang == "FR") then
		SB_Lang_Mode_Bag = "[Inventaire]"
		SB_Lang_Mode_Bank = "[Banque]"
		SB_Lang_Language = "Langue"
		SB_Lang_Received = "Vous recevez "
		SB_Lang_PartyReceived = " re\195\167oit "
		SB_Lang_Gold = "pi\195\168ce d'or"
		SB_Lang_Golds = "pi\195\168ces d'or"
		SB_Lang_Lost = "Vous perdez "
		SB_Lang_Settings_MainOptionsTitle = "Options principales"
		SB_Lang_Settings_LockUnlockFrame = "Autoriser le d\195\169placement de la fen\195\170tre"
		SB_Lang_Settings_LockUnlockFrame_ToolTip = "Active ou d\195\169sactive le d\195\169placement de la fen\195\170tre"
		SB_Lang_Settings_NormalStateColor = "Couleur de l'\195\169tat normal"
		SB_Lang_Settings_NormalStateColor_ToolTip = "Selectionner la couleur de l'\195\169tat normal (lorsque les sacs sont normalement remplis)"
		SB_Lang_Settings_WarningStateColor = "Couleur de l'\195\169tat d'alerte"
		SB_Lang_Settings_WarningStateColor_ToolTip = "Selectionner la couleur de l'\195\169tat d'alerte (lorsque les sacs sont presque pleins)"
		SB_Lang_Settings_FullStateColor = "Couleur de l'\195\169tat plein"
		SB_Lang_Settings_FullStateColor_ToolTip = "Selectionner la couleur de l'\195\169tat plein (lorsque les sacs sont pleins)"
		SB_Lang_Settings_PercentWarningState = "Pourcentage de l'\195\169tat d'alerte"
		SB_Lang_Settings_PercentWarningState_ToolTip = "Selectionner le pourcentage du declenchement de l'\195\169tat d'alerte"
		SB_Lang_Settings_LangOptionsTitle = "Options de localisation"
		SB_Lang_Settings_LangOptionsSelection = "Selectionner la langue"
		SB_Lang_Settings_LangOptionsSelection_ToolTip = "Langue d'affichage de l'addon"
		SB_Lang_Settings_LangOptionsSelection_Warning_ToolTip = "Modifier cette option rechargera l'interface"
		SB_Lang_Settings_LootGoldLogOptionsTitle = "Options de SmartBags LootGoldLog"
		SB_Lang_Settings_LootGoldLogOptionsSelection = "Activer SmartBags LootGoldLog"
		SB_Lang_Settings_LootGoldLogOptionsSelection_ToolTip = "Active / d\195\169sactive la fonction d'affichage des loots et de l'argent dans la fen\195\170tre de chat"
		SB_LangLootGoldLog_SettingsReceiveColor = "Couleur d'affichage pour un gain"
		SB_LangLootGoldLog_SettingsLostColor = "Couleur d'affichage pour une perte"
		SB_LangLootGoldLog_ShowTotalItems = "Afficher le total d'objets"
		SB_LangLootGoldLog_ShowTotalItems_Tooltip = "Affiche le total d'objets lors du ramassage d'un objet (regarde dans l'inventaire et la banque)"
		SB_LangLootGoldLog_ShowPartyItems = "Afficher les loots de groupe"
		SB_LangLootGoldLog_ShowPartyItems_Tooltip = "Affiche les loots que recoivent les membres de votre groupe"
		SB_LangLootGoldLog_SettingsPartyColor = "Couleur du butin de groupe"
	-- DE
	elseif (SmartBags.settings.LocalLang == "DE") then
		SB_Lang_Mode_Bag = "[Inventar]"
		SB_Lang_Mode_Bank = "[Bank]"
		SB_Lang_Language = "Sprache"
		SB_Lang_Received = "Sie erhalten "
		SB_Lang_PartyReceived = " erhalt "
		SB_Lang_Gold = "goldmunze"
		SB_Lang_Golds = "goldmunzen"
		SB_Lang_Lost = "Sie verlieren "
		SB_Lang_Settings_MainOptionsTitle = "SmartBags main options"
		SB_Lang_Settings_LockUnlockFrame = "Unlock SmartBags frame movement"
		SB_Lang_Settings_LockUnlockFrame_ToolTip = "Enable SmartBags move functions"
		SB_Lang_Settings_NormalStateColor = "Normal state color"
		SB_Lang_Settings_NormalStateColor_ToolTip = "Select the normal state color (when bags is not in warning state)"
		SB_Lang_Settings_WarningStateColor = "Warning state color"
		SB_Lang_Settings_WarningStateColor_ToolTip = "Select the warning state color (when bags is almost full)"
		SB_Lang_Settings_FullStateColor = "Full state color"
		SB_Lang_Settings_FullStateColor_ToolTip = "Select the full state color (when bags is full)"
		SB_Lang_Settings_PercentWarningState = "Percent warning state"
		SB_Lang_Settings_PercentWarningState_ToolTip = "Select the percent value when indicator change to warning state"
		SB_Lang_Settings_LangOptionsTitle = "Language options"
		SB_Lang_Settings_LangOptionsSelection = "Select language"
		SB_Lang_Settings_LangOptionsSelection_ToolTip = "AddOn language"
		SB_Lang_Settings_LangOptionsSelection_Warning_ToolTip = "Change this option will be reload ui"
		SB_Lang_Settings_LootGoldLogOptionsTitle = "SmartBags LootGoldLog options"
		SB_Lang_Settings_LootGoldLogOptionsSelection = "Enable SmartBags LootGoldLog"
		SB_Lang_Settings_LootGoldLogOptionsSelection_ToolTip = "Enable SmartBags LootGoldLog function in chat log ?"
		SB_LangLootGoldLog_SettingsReceiveColor = "Text color for receive loot(s)/gold(s)"
		SB_LangLootGoldLog_SettingsLostColor = "Text color for lost gold(s)"
		SB_LangLootGoldLog_ShowTotalItems = "Show total items on pickup"
		SB_LangLootGoldLog_ShowTotalItems_Tooltip = "Show total items when picking (search in the inventory and the bank and display it)"
		SB_LangLootGoldLog_ShowPartyItems = "Show group looted items"
		SB_LangLootGoldLog_ShowPartyItems_Tooltip = "Show received items of your group"
		SB_LangLootGoldLog_SettingsPartyColor = "Text color for looted group item"
	-- EN
	elseif (SmartBags.settings.LocalLang == "EN") then
		SB_Lang_Mode_Bag = "[Inventory]"
		SB_Lang_Mode_Bank = "[Bank]"
		SB_Lang_Language = "Language"
		SB_Lang_Received = "You receive "
		SB_Lang_PartyReceived = " received "
		SB_Lang_Gold = "gold"
		SB_Lang_Golds = "golds"	
		SB_Lang_Lost = "You lose "
		SB_Lang_Settings_MainOptionsTitle = "SmartBags main options"
		SB_Lang_Settings_LockUnlockFrame = "Unlock SmartBags frame movement"
		SB_Lang_Settings_LockUnlockFrame_ToolTip = "Enable SmartBags move functions"
		SB_Lang_Settings_NormalStateColor = "Normal state color"
		SB_Lang_Settings_NormalStateColor_ToolTip = "Select the normal state color (when bags is not in warning state)"
		SB_Lang_Settings_WarningStateColor = "Warning state color"
		SB_Lang_Settings_WarningStateColor_ToolTip = "Select the warning state color (when bags is almost full)"
		SB_Lang_Settings_FullStateColor = "Full state color"
		SB_Lang_Settings_FullStateColor_ToolTip = "Select the full state color (when bags is full)"
		SB_Lang_Settings_PercentWarningState = "Percent warning state"
		SB_Lang_Settings_PercentWarningState_ToolTip = "Select the percent value when indicator change to warning state"
		SB_Lang_Settings_LangOptionsTitle = "Language options"
		SB_Lang_Settings_LangOptionsSelection = "Select language"
		SB_Lang_Settings_LangOptionsSelection_ToolTip = "AddOn language"
		SB_Lang_Settings_LangOptionsSelection_Warning_ToolTip = "Change this option will be reload ui"
		SB_Lang_Settings_LootGoldLogOptionsTitle = "SmartBags LootGoldLog options"
		SB_Lang_Settings_LootGoldLogOptionsSelection = "Enable SmartBags LootGoldLog"
		SB_Lang_Settings_LootGoldLogOptionsSelection_ToolTip = "Enable SmartBags LootGoldLog function in chat log ?"
		SB_LangLootGoldLog_SettingsReceiveColor = "Text color for receive loot(s)/gold(s)"
		SB_LangLootGoldLog_SettingsLostColor = "Text color for lost gold(s)"
		SB_LangLootGoldLog_ShowTotalItems = "Show total items on pickup"
		SB_LangLootGoldLog_ShowTotalItems_Tooltip = "Show total items when picking (search in the inventory and the bank and display it)"
		SB_LangLootGoldLog_ShowPartyItems = "Show group looted items"
		SB_LangLootGoldLog_ShowPartyItems_Tooltip = "Show received items of your group"
		SB_LangLootGoldLog_SettingsPartyColor = "Text color for looted group item"
	end
end