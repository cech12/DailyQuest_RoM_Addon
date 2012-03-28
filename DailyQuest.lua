--[[
        DailyQuest
        
        Shows the number of daily quests in a moveable line in your interface
        
        Version: v_1.0.1
        Author: romoto3 (cech12@gmail.com)
]]--

function getDailyQuestText()
  local daily_quest_count, daily_quest_per_day = Daily_count();
  return _glossary_00978 .. ": " .. daily_quest_count .. "/" .. daily_quest_per_day;
end

function DailyQuest_OnLoad(this)
	this:RegisterEvent("RESET_QUESTTRACK");
	--this:RegisterEvent("QUEST_COMPLETE");
  
  SLASH_DQ1 = "/dq";
  SLASH_DQ2 = "/tq";
  SLASH_DQREFRESH1 = "/dqr";
  SLASH_DQREFRESH2 = "/tqa";
  
  SlashCmdList["DQ"] = dq_slash;
  SlashCmdList["DQREFRESH"] = DailyQuestRefresh;
  
  DailyQuestRefresh();
  DEFAULT_CHAT_FRAME:AddMessage("DailyQuest v_1.0.1 loaded");
end

function dq_slash()
  DEFAULT_CHAT_FRAME:AddMessage(getDailyQuestText());
end

function DailyQuestRefresh()
  DailyQuestText:SetText(getDailyQuestText());
end

-- waehrend "QUEST_COMPLETE" ist Daily_count() noch nicht aktualisiert. Dies erfolgt erst nach dem zweiten mal "RESET_QUESTTRACK"
function DailyQuest_OnEvent(event)
  --DEFAULT_CHAT_FRAME:AddMessage("jetzt " .. event);
  --if (event == "RESET_QUESTTRACK" and LAST_DAILY_QUEST_EVENT == "QUEST_COMPLETE") then -- ist zu frueh, variablen werden spaeter geaendert
  DailyQuestRefresh();
  --end
end

--function DailyQuest_OnUpdate()
--  DailyQuestText:SetText(_glossary_00978 .. ": " .. dailyQuestCount .. "/" .. dailyQuestsPerDay, 1, 1, 1);
--end