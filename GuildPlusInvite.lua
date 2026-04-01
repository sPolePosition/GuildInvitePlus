local f = CreateFrame("Frame")

local function GPI_Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[GuildPlusInvite]|r " .. msg)
end

local function GPI_Trim(s)
    if not s then return "" end
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

local function GPI_CanInvite()
    if not GetNumPartyMembers or not GetNumRaidMembers then
        return true
    end

    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
        return true
    end

    if IsPartyLeader and IsPartyLeader() then
        return true
    end

    if GetNumRaidMembers() > 0 and IsRaidLeader and IsRaidLeader() then
        return true
    end

    if GetNumRaidMembers() > 0 and IsRaidOfficer and IsRaidOfficer() then
        return true
    end

    return false
end

local function GPI_Invite(name)
    if not name or name == "" then return end

    local short = name
    if string.find(short, "-") then
        short = string.gsub(short, "%-.+$", "")
    end

    if short == UnitName("player") then
        return
    end

    InviteByName(short)
    GPI_Print("Inviting " .. short)
end

SLASH_GPI1 = "/gpi"
SlashCmdList["GPI"] = function(msg)
    msg = string.lower(GPI_Trim(msg))

    if msg == "on" then
        GPI_ENABLED = 1
        GPI_Print("Auto-invite enabled.")
    elseif msg == "off" then
        GPI_ENABLED = 0
        GPI_Print("Auto-invite disabled.")
    else
        local status = "OFF"
        if GPI_ENABLED == nil or GPI_ENABLED == 1 then
            status = "ON"
        end
        GPI_Print("Status: " .. status)
        GPI_Print("Usage: /gpi on  or  /gpi off")
    end
end

f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("CHAT_MSG_GUILD")

f:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        if GPI_ENABLED == nil then
            GPI_ENABLED = 1
        end
        GPI_Print("Loaded. Guild '+' auto-invite is " .. ((GPI_ENABLED == 1) and "ON" or "OFF"))
        return
    end

    if event == "CHAT_MSG_GUILD" then
        if GPI_ENABLED ~= 1 then
            return
        end

        local msg = GPI_Trim(arg1)
        local sender = arg2

        if msg ~= "+" then
            return
        end

        if not GPI_CanInvite() then
            GPI_Print("Saw '+' from " .. tostring(sender) .. " but you do not have invite permission.")
            return
        end

        GPI_Invite(sender)
    end
end)
