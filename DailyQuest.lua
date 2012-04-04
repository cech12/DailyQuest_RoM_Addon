--[[
        DailyQuest
        
        Shows the number of daily quests in a moveable line in your interface
        
        Version: v1.1.0
        Author: romoto3 (cech12@gmail.com)
]]--

--------------------------------------------------------------------------------------
-- Init

g_DailyQuest = nil;

function g_DailyQuestConfig_Init()
	if (not g_DailyQuestConfig) then g_DailyQuestConfig = {}; end
	if (g_DailyQuestConfig.Show == nil) then g_DailyQuestConfig.Show = true;	end
	if (g_DailyQuestConfig.Lock == nil) then	g_DailyQuestConfig.Lock = false; end
	--if (g_DailyQuestConfig.Color == nil) then g_DailyQuestConfig.Color = true; end
end;

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

function DailyQuestButton_OnClick(this,key)
	if (key == "LBUTTON") then
		if (DailyQuestSettings:IsVisible() == false) then
			--ShowUIPanel(GameConfigFrame); -- hier wird das normale Interface-Menü aufgerufen
			--OnClick_GCF_Tab(6);           -- TODO: neues Menü mit Einstellungsmoeglichkeiten (Farbe, Fixierung, Anzeigen)
      ShowUIPanel(DailyQuestSettings);
		else
			HideUIPanel(DailyQuestSettings);
		end
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
  SLASH_DQ2 = "/tq";
  SLASH_DQREFRESH1 = "/dqr";
  SLASH_DQREFRESH2 = "/tqa";
  
  SlashCmdList["DQ"] = dq_slash;
  SlashCmdList["DQREFRESH"] = DailyQuestRefresh;
  
  DailyQuestRefresh();
  DEFAULT_CHAT_FRAME:AddMessage("DailyQuest v1.1.0 loaded");
end

function dq_slash()
  DEFAULT_CHAT_FRAME:AddMessage(getDailyQuestText());
end

function DailyQuestRefresh()
  DailyQuestText:SetText(getDailyQuestText());
end

--function DailyQuestSetColor()
--  DailyQuestText:SetTextColor(g_DailyQuestConfig.Color);
--end

-- waehrend "QUEST_COMPLETE" ist Daily_count() noch nicht aktualisiert. Dies erfolgt erst nach dem zweiten mal "RESET_QUESTTRACK"
function DailyQuest_OnEvent(event)
  --DEFAULT_CHAT_FRAME:AddMessage("jetzt " .. event);
	if (event == "VARIABLES_LOADED") then
		g_DailyQuestConfig_Init();
	else
  --if (event == "RESET_QUESTTRACK" and LAST_DAILY_QUEST_EVENT == "QUEST_COMPLETE") then -- ist zu frueh, variablen werden spaeter geaendert
    DailyQuestRefresh();
  end
end

--function DailyQuest_OnUpdate()
--  DailyQuestText:SetText(_glossary_00978 .. ": " .. dailyQuestCount .. "/" .. dailyQuestsPerDay, 1, 1, 1);
--end