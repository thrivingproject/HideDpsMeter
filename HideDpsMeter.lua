HideDpsMeterDB = HideDpsMeterDB or { enabled = true }

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

local hidden = {}

local function FindMeterFrames()
    local out = {}
    for k, v in pairs(_G) do
        if type(k) == "string"
            and k:lower():find("damagemeter")
            and type(v) == "table"
            and type(v.IsShown) == "function"
            and type(v.Hide) == "function"
        then
            out[#out + 1] = v
        end
    end
    return out
end

local function SetupOptions()
    local category = Settings.RegisterVerticalLayoutCategory("HideDpsMeter")
    local setting = Settings.RegisterAddOnSetting(
        category,
        "HIDEDPSMETER_ENABLED",
        "enabled",
        HideDpsMeterDB,
        Settings.VarType.Boolean,
        "Enabled",
        true
    )
    Settings.CreateCheckbox(category, setting, "Hide the Blizzard Damage Meter while in combat.")
    Settings.RegisterAddOnCategory(category)
end

f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        C_AddOns.LoadAddOn("Blizzard_DamageMeter")
        SetupOptions()
    elseif event == "PLAYER_REGEN_DISABLED" then
        if not HideDpsMeterDB.enabled then return end
        for _, w in ipairs(FindMeterFrames()) do
            if w:IsShown() then
                hidden[w] = true
                w:Hide()
            end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        for w in pairs(hidden) do
            w:Show()
            hidden[w] = nil
        end
    end
end)
