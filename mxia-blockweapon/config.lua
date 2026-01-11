-- config.lua
Config = {}

-- Cooldown dalam detik setelah revive sebelum bisa menggunakan senjata/memukul
Config.CombatCooldown = 900

-- Izinkan aksi tertentu saat cooldown
Config.AllowInventory = true  -- Izinkan buka inventory
Config.AllowVehicleEntry = true  -- Izinkan masuk kendaraan
Config.AllowOxTarget = true  -- Izinkan menggunakan ox_target

-- Database settings
Config.UseDatabase = true  -- Set false untuk disable database persistence

-- NUI Settings
Config.UseNUI = true  -- Set true untuk menggunakan NUI HTML, false untuk native text

-- Pesan notifikasi
Config.Locale = {
    combat_blocked = 'You Are Still Recovering!',
    cooldown_active = 'You Just Revived, Wait %s Second For Punch And Shooting',
    weapon_removed = 'Punch/Weapon Unavailable Temporary',
    combat_ready = 'You Are Recovered',
    cooldown_restored = 'Cooldown Combat: %s Second Left'
}

-- Daftar senjata yang diblokir (bisa dikustomisasi)
Config.BlockedWeapons = {
    'WEAPON_UNARMED',
    'WEAPON_PISTOL',
    'WEAPON_COMBATPISTOL',
    'WEAPON_APPISTOL',
    'WEAPON_PISTOL50',
    'WEAPON_MICROSMG',
    'WEAPON_SMG',
    'WEAPON_ASSAULTRIFLE',
    'WEAPON_CARBINERIFLE',
    'WEAPON_ADVANCEDRIFLE',
    'WEAPON_MG',
    'WEAPON_COMBATMG',
    'WEAPON_PUMPSHOTGUN',
    'WEAPON_SAWNOFFSHOTGUN',
    'WEAPON_ASSAULTSHOTGUN',
    'WEAPON_BULLPUPSHOTGUN',
    'WEAPON_STUNGUN',
    'WEAPON_SNIPERRIFLE',
    'WEAPON_HEAVYSNIPER',
    'WEAPON_GRENADELAUNCHER',
    'WEAPON_RPG',
    'WEAPON_MINIGUN',
    'WEAPON_GRENADE',
    'WEAPON_STICKYBOMB',
    'WEAPON_SMOKEGRENADE',
    'WEAPON_BZGAS',
    'WEAPON_MOLOTOV',
    'WEAPON_FIREEXTINGUISHER',
    'WEAPON_PETROLCAN',
    'WEAPON_KNIFE',
    'WEAPON_NIGHTSTICK',
    'WEAPON_HAMMER',
    'WEAPON_BAT',
    'WEAPON_GOLFCLUB',
    'WEAPON_CROWBAR',
    'WEAPON_BOTTLE',
    'WEAPON_DAGGER',
    'WEAPON_HATCHET',
    'WEAPON_KNUCKLE',
    'WEAPON_MACHETE',
    'WEAPON_FLASHLIGHT',
    'WEAPON_SWITCHBLADE',
    'WEAPON_POOLCUE',
    'WEAPON_WRENCH',
    'WEAPON_BATTLEAXE'
}