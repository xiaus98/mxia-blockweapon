-- server.lua
ESX = exports['es_extended']:getSharedObject()

CreateThread(function()
    if Config.UseDatabase then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `combat_cooldowns` (
                `identifier` VARCHAR(60) NOT NULL,
                `remaining_time` INT NOT NULL COMMENT 'Waktu tersisa dalam detik',
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]], {}, function(result)
            print('[Revive Combat Block] Database table checked/created')
            print('[Revive Combat Block] Mode: Paused when offline - Cooldown only runs when player is online')
        end)
    end
end)

local function SaveCooldown(identifier, remainingSeconds)
    if not Config.UseDatabase then return end
    
    MySQL.insert('INSERT INTO combat_cooldowns (identifier, remaining_time) VALUES (?, ?) ON DUPLICATE KEY UPDATE remaining_time = ?', {
        identifier,
        remainingSeconds,
        remainingSeconds
    }, function(affectedRows)
        if affectedRows > 0 then
            print(('[Revive Combat Block] Cooldown saved for %s: %d seconds remaining'):format(identifier, remainingSeconds))
        end
    end)
end

local function GetCooldown(identifier, callback)
    if not Config.UseDatabase then 
        callback(0)
        return 
    end
    
    MySQL.query('SELECT remaining_time FROM combat_cooldowns WHERE identifier = ?', {
        identifier
    }, function(result)
        if result and result[1] then
            local remainingTime = result[1].remaining_time
            
            if remainingTime > 0 then
                callback(remainingTime)
            else
                MySQL.query('DELETE FROM combat_cooldowns WHERE identifier = ?', {identifier})
                callback(0)
            end
        else
            callback(0)
        end
    end)
end

local function ClearCooldown(identifier)
    if not Config.UseDatabase then return end
    
    MySQL.query('DELETE FROM combat_cooldowns WHERE identifier = ?', {
        identifier
    }, function(affectedRows)
        if affectedRows > 0 then
            print(('[Revive Combat Block] Cooldown cleared for %s'):format(identifier))
        end
    end)
end

RegisterNetEvent('revive_combat_block:onRevive', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    SaveCooldown(xPlayer.identifier, Config.CombatCooldown)
    TriggerClientEvent('revive_combat_block:startCooldown', src, Config.CombatCooldown)
    
    print(('[Revive Combat Block] %s (%s) started combat cooldown'):format(xPlayer.getName(), xPlayer.identifier))
end)

RegisterNetEvent('revive_combat_block:checkCooldown', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    GetCooldown(xPlayer.identifier, function(remainingTime)
        if remainingTime > 0 then
            print(('[Revive Combat Block] Restoring cooldown for %s: %d seconds'):format(xPlayer.identifier, remainingTime))
            TriggerClientEvent('revive_combat_block:restoreCooldown', src, remainingTime)
        end
    end)
end)

RegisterNetEvent('revive_combat_block:updateCooldown', function(remainingTime)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    if remainingTime > 0 then
        SaveCooldown(xPlayer.identifier, remainingTime)
    else
        ClearCooldown(xPlayer.identifier)
    end
end)

RegisterNetEvent('revive_combat_block:clearCooldown', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    ClearCooldown(xPlayer.identifier)
end)

RegisterNetEvent('esx_ambulancejob:menghidupkan', function(target)
    if target then
        local xPlayer = ESX.GetPlayerFromId(target)
        if xPlayer then
            SaveCooldown(xPlayer.identifier, Config.CombatCooldown)
            TriggerClientEvent('revive_combat_block:startCooldown', target, Config.CombatCooldown)
        end
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer then
        print(('[Revive Combat Block] Player %s disconnected - cooldown saved in database'):format(xPlayer.identifier))
    end
end)

RegisterCommand('clearcombatcd', function(source, args, rawCommand)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    if xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
        local targetId = tonumber(args[1])
        
        if targetId then
            local targetPlayer = ESX.GetPlayerFromId(targetId)
            if targetPlayer then
                ClearCooldown(targetPlayer.identifier)
                TriggerClientEvent('revive_combat_block:clearCooldown', targetId)
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Success',
                    description = 'Combat cooldown cleared for player ' .. targetId,
                    type = 'success'
                })
                print(('[Revive Combat Block] Admin %s cleared cooldown for %s'):format(xPlayer.identifier, targetPlayer.identifier))
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Error',
                    description = 'Player not found',
                    type = 'error'
                })
            end
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Usage',
                description = '/clearcombatcd [player_id]',
                type = 'info'
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'You do not have permission',
            type = 'error'
        })
    end
end, false)

-- Option 3: Using oxmysql (if you're using oxmysql)
CreateThread(function()
    while true do
        Wait(3600000)
        if Config.UseDatabase then
            local affectedRows = MySQL.query.await('DELETE FROM combat_cooldowns WHERE remaining_time <= 0', {})
            if affectedRows > 0 then
                print(('[Revive Combat Block] Cleaned up %d completed cooldowns'):format(affectedRows))
            end
        end
    end
end)

--[[CreateThread(function()
    while true do
        Wait(3600000)
        
        if Config.UseDatabase then
            MySQL.query('DELETE FROM combat_cooldowns WHERE remaining_time <= 0', {}, function(affectedRows)
                if affectedRows > 0 then
                    print(('[Revive Combat Block] Cleaned up %d completed cooldowns'):format(affectedRows))
                end
            end)
        end
    end
end)--]]