-- client.lua
local isInCombatCooldown = false
local cooldownEndTime = 0
local currentCooldownThread = nil
local lastBlockedWeapon = nil
local currentNotificationId = nil

-- Fungsi untuk memulai cooldown
local function StartCombatCooldown(duration)
    if not duration then
        duration = Config.CombatCooldown
    end
    
    isInCombatCooldown = true
    cooldownEndTime = GetGameTimer() + (duration * 1000)
    lastBlockedWeapon = nil
    currentNotificationId = nil
    
    -- Tampilkan NUI
    if Config.UseNUI then
        SendNUIMessage({
            action = "showCooldown",
            duration = duration,
            maxDuration = Config.CombatCooldown
        })
    end
    
    -- Tampilkan progress bar
--    lib.progressBar({
  --      duration = duration * 1000,
  --      label = 'Pemulihan...',
  --      useWhileDead = false,
  --      canCancel = false,
  --      disable = {
  --          move = false,
  --          car = false,
  --          combat = true
  --      }
  --  })
    
    -- Hapus senjata sementara
    SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)
    
    -- Thread untuk monitoring cooldown
    if currentCooldownThread then
        currentCooldownThread = nil
    end
    
    CreateThread(function()
        currentCooldownThread = true
        
        while isInCombatCooldown do
            Wait(100)
            
            local timeLeft = cooldownEndTime - GetGameTimer()
            
            -- Update NUI setiap frame
            if Config.UseNUI then
                local seconds = math.max(0, math.ceil(timeLeft / 1000))
                SendNUIMessage({
                    action = "updateTime",
                    time = seconds
                })
            end
            
            if timeLeft <= 0 then
                isInCombatCooldown = false
                lastBlockedWeapon = nil
                currentNotificationId = nil
                
                -- Hide NUI
                if Config.UseNUI then
                    SendNUIMessage({
                        action = "hideCooldown"
                    })
                end
                
                -- Hapus cooldown dari database
                TriggerServerEvent('revive_combat_block:clearCooldown')
                
                lib.notify({
                    title = 'Combat Ready',
                    description = Config.Locale.combat_ready,
                    type = 'success',
                    position = 'top',
                    duration = 5000
                })
                currentCooldownThread = nil
                break
            end
        end
    end)
end

-- Event dari server saat player direvive
RegisterNetEvent('revive_combat_block:startCooldown', function(duration)
    StartCombatCooldown(duration)
end)

-- Event untuk restore cooldown dari database saat login
RegisterNetEvent('revive_combat_block:restoreCooldown', function(remainingTime)
    if remainingTime and remainingTime > 0 then
        lib.notify({
            title = 'Cooldown Dipulihkan',
            description = string.format(Config.Locale.cooldown_restored, remainingTime),
            type = 'warning',
            position = 'top',
            duration = 5000
        })
        lib.notify({
            title = 'Punch/Shoot Unavailable',
            description = string.format(Config.Locale.weapon_removed, remainingTime),
            type = 'warning',
            position = 'top',
            duration = 5000
        })
        StartCombatCooldown(remainingTime)
    end
end)

-- Hook ke esx_ambulancejob revive event (compatibility)
RegisterNetEvent('esx_ambulancejob:menghidupkan', function()
    TriggerServerEvent('revive_combat_block:onRevive')
end)

-- Alternative revive events (untuk compatibility dengan berbagai script)
RegisterNetEvent('hospital:client:Revive', function()
    TriggerServerEvent('revive_combat_block:onRevive')
end)

RegisterNetEvent('playerSpawned', function()
    -- Request cooldown status dari server saat spawn
    TriggerServerEvent('revive_combat_block:checkCooldown')
end)

-- Saat player loaded, cek apakah ada cooldown tersimpan
AddEventHandler('esx:playerLoaded', function(playerData)
    Wait(2000)
    TriggerServerEvent('revive_combat_block:checkCooldown')
end)

-- Main thread untuk block combat
CreateThread(function()
    while true do
        Wait(0)
        
        if isInCombatCooldown then
            local ped = PlayerPedId()
            
            -- Block melee attacks
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            
            -- Block weapon wheel dan shooting
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 47, true)
            DisableControlAction(0, 58, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            
            if not Config.AllowInventory then
                DisableControlAction(0, 167, true)
            end
            
            -- Cek jika player mencoba menggunakan senjata
            local currentWeapon = GetSelectedPedWeapon(ped)
            local weaponHash = GetHashKey('WEAPON_UNARMED')
            
            if currentWeapon ~= weaponHash then
                SetCurrentPedWeapon(ped, weaponHash, true)
                RemoveAllPedWeapons(ped, true)
              --  RemoveAllPedWeapon(ped, weaponHash, true)
                
                if currentWeapon ~= lastBlockedWeapon then
                    if currentNotificationId then
                        exports.ox_lib:dismissNotify(currentNotificationId)
                    end
                    
                    local timeLeft = math.ceil((cooldownEndTime - GetGameTimer()) / 1000)
                    currentNotificationId = lib.notify({
                        id = 'combat_blocked_' .. currentWeapon,
                        title = 'Combat Diblokir',
                        description = string.format(Config.Locale.cooldown_active, timeLeft),
                        type = 'error',
                        position = 'top',
                        duration = 5000
                    })
                    
                    lastBlockedWeapon = currentWeapon
                end
            end
        else
            Wait(500)
        end
    end
end)

-- Thread untuk check punching/melee
CreateThread(function()
    while true do
        Wait(0)
        
        if isInCombatCooldown then
            local ped = PlayerPedId()
            
            if IsPedInMeleeCombat(ped) then
                ClearPedTasks(ped)
            --    lib.notify({
            --        title = 'Terlalu Lemah',
            --        description = Config.Locale.combat_blocked,
            --        type = 'error',
            --        position = 'top'
            --    })
            end
        else
            Wait(500)
        end
    end
end)

-- Update database setiap 5 detik saat cooldown aktif
CreateThread(function()
    while true do
        Wait(5000)
        
        if isInCombatCooldown then
            local timeLeft = math.ceil((cooldownEndTime - GetGameTimer()) / 1000)
            if timeLeft > 0 then
                TriggerServerEvent('revive_combat_block:updateCooldown', timeLeft)
            end
        end
    end
end)

-- Command untuk testing
RegisterCommand('testrevive', function()
    TriggerServerEvent('revive_combat_block:onRevive')
end, false)