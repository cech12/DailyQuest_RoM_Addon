--[[
        DailyQuest
        
        Shows the number of daily quests in a moveable line in your interface
        
        Version: v1.2.0
        Author: romoto3 (cech12@gmail.com)
]]--

--------------------------------------------------------------------------------------
-- Init

local VERSION = "v1.2.0";
g_DailyQuest = nil;

function g_DailyQuestConfig_Init()
	if (not g_DailyQuestConfig) then g_DailyQuestConfig = {}; end
	if (g_DailyQuestConfig.Enable == nil) then g_DailyQuestConfig.Enable = true;	end
	if (g_DailyQuestConfig.Show == nil) then g_DailyQuestConfig.Show = true;	end
	if (g_DailyQuestConfig.Lock == nil) then	g_DailyQuestConfig.Lock = false; end
	if (g_DailyQuestConfig.FontSize == nil) then g_DailyQuestConfig.FontSize = 12; end
	if (g_DailyQuestConfig.r == nil) then g_DailyQuestConfig.r = 1; end
	if (g_DailyQuestConfig.g == nil) then g_DailyQuestConfig.g = 1; end
	if (g_DailyQuestConfig.b == nil) then g_DailyQuestConfig.b = 1; end
	if (g_DailyQuestConfig.a == nil) then g_DailyQuestConfig.a = 1; end
end;

--------------------------------------------------------------------------------------
-- AddonManager

function DailyQuest_RegisterWithAddonManager()
  if AddonManager then
    local addon = {
      name = "DailyQuest", 
      description = "DailyQuest shows the number of daily quests in a moveable line in your interface.", 
      category = "Information",
      version = VERSION,
      author = "romoto3",
      configFrame = DailyQuestSettings,
      slashCommands = "/dq /dqs",
      enableScript = DailyQuest_Enable,
      disableScript = DailyQuest_Disable,
      icon = "Interface/BagFrame/ClockButton-Normal",
    }
  
    if AddonManager.RegisterAddonTable then
      AddonManager.RegisterAddonTable(addon)
    else
      AddonManager.RegisterAddon(addon.name, addon.description, addon.icon, addon.category, 
        addon.configFrame, addon.slashCommands, addon.miniButton, addon.onClickScript)
    end
  else
    g_DailyQuestConfig.Enable = true;
  end
end

function DailyQuest_Enable() 
  g_DailyQuestConfig.Enable = true;
  DailyQuestRefresh();
  DailyQuestShowHide();
end
function DailyQuest_Disable()
  g_DailyQuestConfig.Enable = false;
  DailyQuestShowHide();
end

--------------------------------------------------------------------------------------
-- Move-Button

function DailyQuestButton_OnMouseDown(this,key)
	if (g_DailyQuestConfig.Lock == false) then
		if (key == "RBUTTON") then
			UIPanelAnchorFrame_StartMoving(DailyQuestAnchorFrame);
		end
	end
end

function DailyQuestButton_OnMouseUp()
	UIPanelAnchorFrame_StopMoving();
end

function DailyQuestSettings_OpenClose()
  if (g_DailyQuestConfig.Enable) then
    if (DailyQuestSettings:IsVisible() == false) then
      ShowUIPanel(DailyQuestSettings);
    else
      HideUIPanel(DailyQuestSettings);
    end
  else
    HideUIPanel(DailyQuestSettings);
  end
end

function DailyQuestButton_OnClick(this,key)
	if (key == "LBUTTON") then
    DailyQuestSettings_OpenClose();
	end
end

--------------------------------------------------------------------------------------
-- Text-Line

function getDailyQuestText()
  local daily_quest_count, daily_quest_per_day = Daily_count();
  return _glossary_00978 .. ": " .. daily_quest_count .. "/" .. daily_quest_per_day;
end

function DailyQuest_OnLoad(this)
	SaveVariables("g_DailyQuestConfig");
  
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("RESET_QUESTTRACK");
	--this:RegisterEvent("QUEST_COMPLETE");
  
  SLASH_DQ1 = "/dq";
  SLASH_DQREFRESH1 = "/dqr";
  SLASH_DQSETTINGS1 = "/dqs";
  
  SlashCmdList["DQ"] = dq_slash;
  SlashCmdList["DQREFRESH"] = DailyQuestRefresh;
  SlashCmdList["DQSETTINGS"] = DailyQuestSettings_OpenClose;
  
  DEFAULT_CHAT_FRAME:AddMessage("DailyQuest " .. VERSION .. " loaded"); -- wird nach DailyQuestRefresh nicht angezeigt
  DailyQuestRefresh();
  DailyQuestShowHide();
end

function dq_slash()
  if (g_DailyQuestConfig.Enable) then
    DEFAULT_CHAT_FRAME:AddMessage(getDailyQuestText());
  end
end

function DailyQuestRefresh()
  if (g_DailyQuestConfig) then
    if (g_DailyQuestConfig.Enable) then
      DailyQuestText:SetText(""); --SetFontSize reagiert nur bei einer Textaenderung
      DailyQuestText:SetFontSize(g_DailyQuestConfig.FontSize);
      DailyQuestText:SetColor(g_DailyQuestConfig.r, g_DailyQuestConfig.g, g_DailyQuestConfig.b);
      DailyQuestText:SetAlpha(g_DailyQuestConfig.a);
      DailyQuestText:SetText(getDailyQuestText());
    end
  end
end

function DailyQuestShowHide()
  if (g_DailyQuestConfig.Enable) then
    if (g_DailyQuestConfig.Show) then
      ShowUIPanel(DailyQuestAnchorFrame);
      ShowUIPanel(DailyQuest);
    else
      HideUIPanel(DailyQuestAnchorFrame);
      HideUIPanel(DailyQuest);
      DEFAULT_CHAT_FRAME:AddMessage("DailyQuest: /dqs to open DailyQuest Settings"); 
    end
  else
    HideUIPanel(DailyQuestAnchorFrame);
    HideUIPanel(DailyQuest);
  end
end

-- waehrend "QUEST_COMPLETE" ist Daily_count() noch nicht aktualisiert. Dies erfolgt erst nach dem zweiten mal "RESET_QUESTTRACK"
function DailyQuest_OnEvent(event)
  --DEFAULT_CHAT_FRAME:AddMessage("jetzt " .. event);
	if (event == "VARIABLES_LOADED") then
		g_DailyQuestConfig_Init();
    DailyQuest_RegisterWithAddonManager(); --for the AddonManager
	else
  --if (event == "RESET_QUESTTRACK" and LAST_DAILY_QUEST_EVENT == "QUEST_COMPLETE") then -- ist zu frueh, variablen werden spaeter geaendert
    DailyQuestRefresh();
  end
end

--------------------------------------------------------------------------------
--SETTINGS

function DailyQuestSettings_OnLoad(this)
  DailyQuestSettingsHeadline:SetText("DailyQuest " .. QUEST_TRACK_TOOLTIP_SETTING);

	DailyQuestSetting_FontSize:SetValueStepMode("FLOAT");
	DailyQuestSetting_FontSize:SetMinMaxValues(8, 20);
	DailyQuestSetting_FontSize:SetValue(1.0);
end

function DailyQuestSettings_OnShow(this)
	DailyQuestSetting_Show:SetChecked(g_DailyQuestConfig.Show);
	DailyQuestSetting_Lock:SetChecked(g_DailyQuestConfig.Lock);
  
	DailyQuestSetting_FontSize:SetValue(g_DailyQuestConfig.FontSize);

	g_OldOptions = {};
	for k,v in pairs(g_DailyQuestConfig) do 
		g_OldOptions[k] = v;
	end
end

--Settings

function DailyQuestSetting_Show_OnClick(this)
	g_DailyQuestConfig.Show = this:IsChecked();
  DailyQuestShowHide();
end

function DailyQuestSetting_Lock_OnClick(this)
	g_DailyQuestConfig.Lock = this:IsChecked();
  --DailyQuestRefresh();
end

function DailyQuestChangeColor()
	g_DailyQuestConfig.a = ColorPickerFrame.a ;
	g_DailyQuestConfig.r = ColorPickerFrame.r ;
	g_DailyQuestConfig.g = ColorPickerFrame.g ;
	g_DailyQuestConfig.b = ColorPickerFrame.b ;
  DailyQuestRefresh();
end

function DailyQuestSetting_Color_OnClick(this)
	local info = {};
	info.alphaMode = 1;  -- alpha Slider
	info.r	= g_DailyQuestConfig.r;   -- default 1
	info.g	= g_DailyQuestConfig.g;   -- default 1
	info.b	= g_DailyQuestConfig.b;  -- default 1
	info.a	= g_DailyQuestConfig.a;   -- default 1
	info.brightnessUp = 1; -- default 1
	info.brightnessDown = 0; -- default 0
	info.callbackFuncOkay = DailyQuestChangeColor;
	info.callbackFuncUpdate = DailyQuestChangeColor;
	info.callbackFuncCancel = DailyQuestChangeColor;

	OpenColorPickerFrameEx(info);
end

function DailyQuestSetting_FontSize_OnValueChanged()
	Font_OnValueChanged  = DailyQuestSetting_FontSize:GetValue();
	Font_OnValueChanged = math.floor(Font_OnValueChanged);
  
	DailyQuestSetting_FontSize_Size:SetText("");
	DailyQuestSetting_FontSize_Size:SetText(Font_OnValueChanged);

	if (g_DailyQuestConfig) then
		g_DailyQuestConfig.FontSize = Font_OnValueChanged;
    DailyQuestRefresh();
	end
end

--Buttons

function DailyQuestSettings_Default_OnClick()
	g_DailyQuestConfig = nil;
	g_DailyQuestConfig_Init();
  
  DailyQuestRefresh();
  DailyQuestShowHide();
	DailyQuestSettings_OnShow(DailyQuestSettings);
end

function DailyQuestSettings_Apply_OnClick()
	if (g_DailyQuestConfig) then
		for k,v in pairs(g_DailyQuestConfig) do 
			g_OldOptions[k] = v;
		end
	end
end

function DailyQuestSettings_Cancel_OnClick(this)
	if (g_OldOptions) then
		for k,v in pairs(g_OldOptions) do 
			g_DailyQuestConfig[k] = v;
		end
	end
  DailyQuestRefresh();
  DailyQuestShowHide();
	HideUIPanel(DailyQuestSettings);
end

function DailyQuestSettings_OK_OnClick()
	g_OldOptions = nil;	
	HideUIPanel(DailyQuestSettings);
end