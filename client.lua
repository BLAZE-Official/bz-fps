---@diagnostic disable: trailing-space
local loopType = nil

-- Functions

---@param shadow boolean
---@param air boolean
local function setShadowAndAir(shadow, air)
    RopeDrawShadowEnabled(shadow)
    CascadeShadowsClearShadowSampleType()
    CascadeShadowsSetAircraftMode(air)
end

---@param entity boolean
---@param dynamic boolean
---@param tracker number
---@param depth number
---@param bounds number
local function setEntityTracker(entity, dynamic, tracker, depth, bounds)
    CascadeShadowsEnableEntityTracker(entity)
    CascadeShadowsSetDynamicDepthMode(dynamic)
    CascadeShadowsSetEntityTrackerScale(tracker)
    CascadeShadowsSetDynamicDepthValue(depth)
    CascadeShadowsSetCascadeBoundsScale(bounds)
end

---@param distance number
---@param tweak number
local function setLights(distance, tweak)
    SetFlashLightFadeDistance(distance)
    SetLightsCutoffDistanceTweak(tweak)
end

---@param notify string
local function notify(message)
    print(message)
end

---@param type string
local function bzfps(type)
    if type == "normal" then
        setShadowAndAir(true, true)
        setEntityTracker(true, true, 5.0, 5.0, 5.0)
        setLights(10.0, 10.0)
        notify("Mode: Normal")
    elseif type == "boost" then
        setShadowAndAir(true, false)
        setEntityTracker(true, false, 5.0, 3.0, 3.0)
        setLights(3.0, 3.0)
        notify("Mode: Boost")
    else
        notify("Usage: /fps [normal/boost]")
        notify("Invalid type: " .. type)
        return
    end
    loopType = type
end

-- Commands

RegisterCommand("fps", function(_, args)
    if args[1] == nil then
        notify("Usage: /fps [normal/boost]")
        return
    end
    umfpsBooster(args[1])
end, false)

-- Main Loop

-- // Distance rendering and entity handler
CreateThread(function()
    while true do
        if loopType == "boost" then
            --// Find closest ped and set the alpha
            for _, ped in ipairs(GetGamePool('CPed')) do
                if not IsEntityOnScreen(ped) then
                    SetEntityAlpha(ped, 0)
                else
                    if GetEntityAlpha(ped) == 0 then
                        SetEntityAlpha(ped, 255)
                    end
                end
                SetPedAoBlobRendering(ped, false)
                Wait(1)
            end
            --// Find closest object and set the alpha
            for _, obj in ipairs(GetGamePool('CObject')) do
                if not IsEntityOnScreen(obj) then
                    SetEntityAlpha(obj, 0)
                    SetEntityAsNoLongerNeeded(obj)
                else
                    if GetEntityAlpha(obj) == 0 then
                        SetEntityAlpha(obj, 255)
                    end
                end
                Wait(1)
            end
        else
            Wait(500)
        end
        Wait(8)
    end
end)

--// Clear broken things, disable wind, and other tiny things that dont require the frame tick
CreateThread(function()
    while true do
        if loopType == "boost" then
            ClearAllBrokenGlass()
            ClearAllHelpMessages()
            LeaderboardsReadClearAll()
            ClearBrief()
            ClearGpsFlags()
            ClearPrints()
            ClearSmallPrints()
            ClearReplayStats()
            LeaderboardsClearCacheData()
            ClearFocus()
            ClearHdArea()
            SetWindSpeed(0.0)
            Wait(1000)
        else
            Wait(1500)
        end
    end
end)
