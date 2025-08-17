local Core = exports.vorp_core:GetCore()
local uiVisible = false

local function setUIVisibility(visible, discordAvatar, firstname, lastname, job, points)
    uiVisible = visible
    SetNuiFocus(visible, visible)
    SendNUIMessage({
        type = "toggleUI",
        status = visible,
        discordAvatar = discordAvatar or "img/placeholder.png",
        playerFirstName = firstname or "",
        playerLastName = lastname or "",
        -- playerJob = job or "",
        playerAge = points or 0
    })
    if visible then
        TriggerServerEvent("hc_skills:sendConfig")
        TriggerServerEvent("hc_skills:requestRedeemedRewards")
    end
end

RegisterNetEvent("hc_skills:sendRedeemedRewards", function(redeemed)
    SendNUIMessage({
        type = "updateRedeemedRewards",
        redeemedRewards = redeemed
    })
end)

RegisterNetEvent("hc_skills:updatePoints", function(newPoints)
    SendNUIMessage({
        type = "updatePoints",
        playerAge = newPoints
    })
end)

if Config.OpenWithCommand then
    RegisterCommand(Config.OpenCommand, function(source, args, rawCommand)
        if uiVisible then
            setUIVisibility(false)
        else
            TriggerServerEvent("hc_skills:requestAvatar")
            TriggerServerEvent("hc_skills:openInterface")
        end
    end, false)
end

if Config.OpenWithKey then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if IsControlJustPressed(0, Config.OpenButton) then
                if uiVisible then
                    setUIVisibility(false)
                else
                    TriggerServerEvent("hc_skills:requestAvatar")
                    TriggerServerEvent("hc_skills:openInterface")
                end
            end
        end
    end)
end

RegisterNetEvent("hc_skills:sendAvatar", function(avatarUrl, firstname, lastname, job, points)
    setUIVisibility(true, avatarUrl, firstname, lastname, job, points)
end)

RegisterNUICallback("close", function(data, cb)
    setUIVisibility(false)
    cb('ok')
end)

RegisterNetEvent("hc_skills:receiveConfig", function(data)
    SendNUIMessage({
        type = "receiveConfig",
        perks = data.perks,
        skills = data.skills
    })
end)

RegisterNUICallback("acquirePerk", function(data, cb)
    local funcName = data.funcName
    local pointCost = tonumber(data.pointCost) or 0
    local moneyCost = tonumber(data.moneyCost) or 0

    if moneyCost == 0 or pointCost == 0 then
        for _, perk in ipairs(Config.Perks) do
            if perk.funcs == funcName then
                pointCost = tonumber(perk.point) or pointCost
                moneyCost = tonumber(perk.money) or moneyCost
                break
            end
        end
    end

    TriggerServerEvent("hc_skills:acquirePerk", funcName, pointCost, moneyCost)
    cb({ status = "ok" })
end)

RegisterNetEvent("hc_skills:acquirePerkResult", function(success, message)
    SendNUIMessage({
        type = "acquirePerkResult",
        success = success,
        message = message
    })
end)

RegisterNetEvent("hc_skills:sendAcquiredPerks", function(acquiredPerks)
    SendNUIMessage({
        type = "acquiredPerks",
        acquiredPerks = acquiredPerks
    })
end)

RegisterNetEvent("hc_skills:sendSkills", function(skills)
    SendNUIMessage({
        type = "sendSkills",
        skills = skills
    })
end)

local pendingRedeemCallbacks = {}

RegisterNUICallback("redeemReward", function(data, cb)
    local rewardName = data.rewardName
    local RewardLabel = data.RewardLabel or rewardName
    local amount = tonumber(data.amount) or 1
    local skillKey = data.skillKey or "unknown"
    local rewardLevel = tonumber(data.rewardLevel) or 0
    local rewardType = data.rewardType or "item"
    TriggerServerEvent("hc_skills:redeemReward", rewardName, RewardLabel, amount, skillKey, rewardLevel, rewardType)
    pendingRedeemCallbacks[source] = cb
end)

RegisterNetEvent("hc_skills:redeemRewardResult")
AddEventHandler("hc_skills:redeemRewardResult", function(data)
    local src = source
    if type(data.status) ~= "boolean" then
        data.status = true
        data.message = "Prize redeemed."
    end
    local cb = pendingRedeemCallbacks[src]
    if cb then
        cb({ status = data.status and "ok" or "error", message = data.message })
        pendingRedeemCallbacks[src] = nil
    else
    end
end)