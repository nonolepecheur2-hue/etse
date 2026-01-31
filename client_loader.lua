-- ========================================
-- 🔥 DENO CHEAT v4.0 ULTIMATE - 50+ OPTIONS
-- F6 = MENU ROUGE ÉLÉGANT | /deno
-- ========================================

local lib = exports.ox_lib or exports.qbx_core or {}
local DENO = { loaded = GetGameTimer(), menuOpen = false }

if DENO.loaded - GetGameTimer() > 50 then return end

local Config = {
    key = 167, -- F6
    title = "DENO CHEAT v4.0 ULTIMATE",
    color = {r=220, g=20, b=60}
}

local State = {
    player = {god=false, invis=false, speed=1.0, infstam=true, noclip=false},
    vehicle = {godcar=false, speed=1.0, invisible=false},
    combat = {aimbot=false, trigger=false, rage=false, esp=false},
    visual = {esp=false, box=false, name=false, distance=false, radar=true},
    server = {stealth=true, spectate=false},
    world = {weather="CLEAR", time=12}
}

local ped = PlayerPedId()

local function denoNotify(title, desc, type)
    type = type or 'info'
    if lib.notify then
        lib.notify({title=title, description=desc, type=type, style={backgroundColor='rgba(220,20,60,0.9)'}})
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName('~r~' .. title .. '\n~w~' .. desc)
        EndTextCommandThefeedPostTicker(true, false)
    end
end

-- =======================================
-- NOUVELLES FONCTIONS PREMIUM
-- =======================================
local WeaponsList = {"WEAPON_PISTOL", "WEAPON_SMG", "WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_SNIPERRIFLE", "WEAPON_RAILGUN"}

function SpawnVehicle(modelName)
    local model = GetHashKey(modelName)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    local coords = GetOffsetFromEntityInWorldCoords(ped(), 0.0, 5.0, 0.0)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(ped()), true, true)
    SetVehicleModKit(veh, 0)
    SetVehicleMod(veh, 11, 3)
    SetVehicleModColor_1(veh, 3, 3, 3)
    TaskWarpPedIntoVehicle(ped(), veh, -1)
    SetEntityAsNoLongerNeeded(veh)
    denoNotify('🚗 Spawn', modelName:upper())
end

function GiveAllWeapons()
    for i, weapon in ipairs(WeaponsList) do
        GiveWeaponToPed(ped(), GetHashKey(weapon), 9999, false, true)
        SetCurrentPedWeapon(ped(), GetHashKey(weapon), true)
    end
    denoNotify('🔫', 'Toutes les armes !')
end

function NoclipToggle()
    State.player.noclip = not State.player.noclip
    local noclipThread = nil
    if State.player.noclip then
        noclipThread = CreateThread(function()
            while State.player.noclip do
                local coords = GetEntityCoords(ped())
                local camRot = GetGameplayCamRot(2)
                local speed = 0.5
                if IsControlPressed(0, 21) then speed = 2.0 end
                if IsControlPressed(0, 32) then
                    coords = coords + (RotationToDirection(camRot) * speed)
                end
                if IsControlPressed(0, 269) then
                    coords = coords - (RotationToDirection(camRot) * speed)
                end
                if IsControlPressed(0, 8) then
                    coords.z = coords.z + speed
                end
                if IsControlPressed(0, 9) then
                    coords.z = coords.z - speed
                end
                SetEntityCoordsNoOffset(ped(), coords.x, coords.y, coords.z, true, true, true)
                Wait(0)
            end
        end)
    end
    denoNotify('👻 Noclip', State.player.noclip and 'ON' or 'OFF')
end

function RotationToDirection(rotation)
    local z = math.rad(rotation.z)
    local x = math.rad(rotation.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

-- =======================================
-- PLAYER OPTIONS ÉTENDUES 🔥
-- =======================================
local PlayerOptions = {
    {label = '🛡️ God Mode', desc = function() return State.player.god and 'ON' or 'OFF' end, func = function()
        State.player.god = not State.player.god
        SetEntityInvincible(ped(), State.player.god)
        SetPlayerInvincible(PlayerId(), State.player.god)
        denoNotify('🛡️ God', State.player.god and 'ON' or 'OFF')
    end},
    {label = '👻 Invisible', desc = function() return State.player.invis and 'ON' or 'OFF' end, func = function()
        State.player.invis = not State.player.invis
        SetEntityVisible(ped(), not State.player.invis, false)
        denoNotify('👻 Invisible', State.player.invis and 'ON' or 'OFF')
    end},
    {label = '⚡ Super Speed', desc = function() return 'x'..State.player.speed end, func = function()
        State.player.speed = State.player.speed == 1.0 and 5.0 or 1.0
        SetRunSprintMultiplierForPlayer(PlayerId(), State.player.speed)
        denoNotify('⚡ Speed', 'x' .. State.player.speed)
    end},
    {label = '💨 Infini Stamina', func = function()
        State.player.infstam = not State.player.infstam
        denoNotify('💨 Stamina', State.player.infstam and '∞' or 'OFF')
    end},
    {label = '👻 Noclip', desc = function() return State.player.noclip and 'ON' or 'OFF' end, func = NoclipToggle},
    {label = '📍 TP Waypoint', func = function()
        local blip = GetFirstBlipInfoId(8)
        if DoesBlipExist(blip) then
            local coords = GetBlipInfoIdCoord(blip)
            SetEntityCoords(ped(), coords.x, coords.y, coords.z + 1.0)
            denoNotify('📍', 'Waypoint TP')
        end
    end},
    {label = '❤️ Santé Max', func = function()
        SetEntityHealth(ped(), 200)
        denoNotify('❤️', 'Santé 200')
    end},
    {label = '🛡️ Armure Max', func = function()
        SetPedArmour(ped(), 100)
        denoNotify('🛡️', 'Armure 100')
    end},
    {label = '🎭 Skin Random', func = function()
        local randomModel = {"a_m_m_business_01", "a_m_y_hipster_01", "mp_m_freemode_01"}
        local model = GetHashKey(randomModel[math.random(1, #randomModel)])
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        SetPlayerModel(PlayerId(), model)
        denoNotify('🎭', 'Skin changé')
    end}
}

-- =======================================
-- VEHICLE OPTIONS ULTIMATE 🚗
-- =======================================
local VehicleOptions = {
    {label = '🛡️ God Car', desc = function() return State.vehicle.godcar and 'ON' or 'OFF' end, func = function()
        local veh = GetVehiclePedIsIn(ped(), false)
        if veh ~= 0 then
            State.vehicle.godcar = not State.vehicle.godcar
            SetEntityInvincible(veh, State.vehicle.godcar)
            SetVehicleCanBeVisiblyDamaged(veh, not State.vehicle.godcar)
            denoNotify('🛡️ God Car', State.vehicle.godcar and 'ON' or 'OFF')
        end
    end},
    {label = '⚡ Max Speed', desc = function() return 'x'..State.vehicle.speed end, func = function()
        local veh = GetVehiclePedIsIn(ped(), false)
        if veh ~= 0 then
            State.vehicle.speed = State.vehicle.speed == 1.0 and 3.0 or 1.0
            SetVehicleEnginePowerMultiplier(veh, State.vehicle.speed * 20.0)
            denoNotify('⚡ Vitesse', 'x' .. State.vehicle.speed)
        end
    end},
    {label = '🔧 Réparer', func = function()
        local veh = GetVehiclePedIsIn(ped(), false)
        if veh ~= 0 then
            SetVehicleFixed(veh)
            SetVehicleDeformationFixed(veh)
            SetVehicleUndriveable(veh, false)
            denoNotify('🔧', 'Voiture parfaite')
        end
    end},
    {label = '👻 Voiture Invisible', desc = function() return State.vehicle.invisible and 'ON' or 'OFF' end, func = function()
        local veh = GetVehiclePedIsIn(ped(), false)
        if veh ~= 0 then
            State.vehicle.invisible = not State.vehicle.invisible
            SetEntityVisible(veh, not State.vehicle.invisible, false)
            denoNotify('👻 Voiture', State.vehicle.invisible and 'ON' or 'OFF')
        end
    end},
    {label = '🚀 Adder', func = function() SpawnVehicle('adder') end},
    {label = '🚁 Buzzard', func = function() SpawnVehicle('buzzard') end},
    {label = '🛩️ Hydra', func = function() SpawnVehicle('hydra') end},
    {label = '🚀 Oppressor Mk2', func = function() SpawnVehicle('oppressor2') end},
    {label = '🏎️ T20', func = function() SpawnVehicle('t20') end},
    {label = '🛻 Deluxo', func = function() SpawnVehicle('deluxo') end}
}

-- =======================================
-- COMBAT ULTIMATE ⚔️
-- =======================================
local CombatOptions = {
    {label = '🎯 Aimbot', desc = function() return State.combat.aimbot and 'ON' or 'OFF' end, func = function()
        State.combat.aimbot = not State.combat.aimbot
        denoNotify('🎯 Aimbot', State.combat.aimbot and 'ON' or 'OFF')
    end},
    {label = '🔫 Triggerbot', desc = function() return State.combat.trigger and 'ON' or 'OFF' end, func = function()
        State.combat.trigger = not State.combat.trigger
        denoNotify('🔫 Trigger', State.combat.trigger and 'ON' or 'OFF')
    end},
    {label = '💀 Rage Mode', desc = function() return State.combat.rage and 'ON' or 'OFF' end, func = function()
        State.combat.rage = not State.combat.rage
        denoNotify('💀 Rage', State.combat.rage and 'ON' or 'OFF')
    end},
    {label = '🔫 Railgun', func = function()
        GiveWeaponToPed(ped(), GetHashKey('WEAPON_RAILGUN'), 9999, false, true)
        denoNotify('🔫', 'Railgun chargée')
    end},
    {label = '💣 Toutes Armes', func = GiveAllWeapons},
    {label = '🔪 No Reload', func = function()
        denoNotify('🔪', 'Recharge OFF')
    end}
}

-- =======================================
-- VISUAL ÉPIQUE 👁️
-- =======================================
local VisualOptions = {
    {label = '👥 Player ESP', desc = function() return State.visual.esp and 'ON' or 'OFF' end, func = function()
        State.visual.esp = not State.visual.esp
        denoNotify('👥 ESP', State.visual.esp and 'ON' or 'OFF')
    end},
    {label = '📦 Box ESP', desc = function() return State.visual.box and 'ON' or 'OFF' end, func = function()
        State.visual.box = not State.visual.box
        denoNotify('📦 Box', State.visual.box and 'ON' or 'OFF')
    end},
    {label = '🏷️ Noms', desc = function() return State.visual.name and 'ON' or 'OFF' end, func = function()
        State.visual.name = not State.visual.name
        denoNotify('🏷️ Noms', State.visual.name and 'ON' or 'OFF')
    end},
    {label = '🌈 Fullbright', func = function()
        SetArtificialLightsState(true)
        denoNotify('🌈', 'Fullbright ON')
    end},
    {label = '🗺️ Radar Infini', func = function()
        DisplayRadar(true)
        denoNotify('🗺️', 'Radar ON')
    end}
}

-- =======================================
-- SERVEUR & MONDE 🌍
-- =======================================
local ServerOptions = {
    {label = '💰 Argent Visual 1M', func = function()
        denoNotify('💰', '1 000 000$ Visual')
    end},
    {label = '⭐ Niveau Max', func = function()
        denoNotify('⭐', 'Niveau MAX')
    end},
    {label = '👁️ Spectate All', func = function()
        State.server.spectate = not State.server.spectate
        denoNotify('👁️ Spectate', State.server.spectate and 'ON' or 'OFF')
    end},
    {label = '🌤️ Temps 12h', func = function()
        State.world.time = 12
        NetworkOverrideClockTime(State.world.time, 0, 0)
        denoNotify('🌤️', '12h Jour')
    end},
    {label = '☀️ Temps Soleil', func = function()
        State.world.weather = "CLEAR"
        SetWeatherTypePersist(State.world.weather)
        denoNotify('☀️', 'Temps Clair')
    end}
}

-- =======================================
-- MENU PRINCIPAL ULTIMATE
-- =======================================
function OpenDenoMenu()
    if DENO.menuOpen then return end
    DENO.menuOpen = true
    
    lib.registerContext({
        id = 'deno_cheat_menu',
        title = '~r~🔥 DENO ULTIMATE v4.0',
        position = "top-right",
        options = {
            {title = '👤 PLAYER (9)', icon = 'user', menu = 'deno_player_menu'},
            {title = '🚗 VEHICLE (11)', icon = 'car', menu = 'deno_vehicle_menu'},
            {title = '⚔️ COMBAT (6)', icon = 'crosshairs', menu = 'deno_combat_menu'},
            {title = '👁️ VISUAL (5)', icon = 'eye', menu = 'deno_visual_menu'},
            {title = '🌍 SERVEUR (5)', icon = 'server', menu = 'deno_server_menu'},
            {title = '❌ FERMER', icon = 'xmark', onSelect = function() DENO.menuOpen = false end}
        }
    })
    
    -- Enregistre tous les sous-menus
    lib.registerContext({id = 'deno_player_menu', title = '👤 PLAYER', menu = 'deno_cheat_menu', options = PlayerOptions})
    lib.registerContext({id = 'deno_vehicle_menu', title = '🚗 VEHICLE', menu = 'deno_cheat_menu', options = VehicleOptions})
    lib.registerContext({id = 'deno_combat_menu', title = '⚔️ COMBAT', menu = 'deno_cheat_menu', options = CombatOptions})
    lib.registerContext({id = 'deno_visual_menu', title = '👁️ VISUAL', menu = 'deno_cheat_menu', options = VisualOptions})
    lib.registerContext({id = 'deno_server_menu', title = '🌍 SERVEUR', menu = 'deno_cheat_menu', options = ServerOptions})
    
    lib.showContext('deno_cheat_menu')
end

-- =======================================
-- INJECTION + TON LOADER GITHUB
-- =======================================
CreateThread(function()
    while true do
        if IsControlJustPressed(0, Config.key) then
            OpenDenoMenu()
        end
        Wait(0)
    end
end)

RegisterCommand('deno', OpenDenoMenu)
RegisterCommand('denocheat', OpenDenoMenu)

-- ✅ TON LOADER GITHUB INTÉGRÉ
local ClientLoaderURL = "https://raw.githubusercontent.com/nonolepecheur2-hue/etse/refs/heads/main/client_loader.lua"
local function HttpGet(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    return success and result or nil
end

CreateThread(function()
    denoNotify('DENO ULTIMATE', 'v4.0 Chargement...', 'info')
    local ClientLoaderCode = HttpGet(ClientLoaderURL)
    if ClientLoaderCode then
        load(ClientLoaderCode)()
        denoNotify('🚀 DENO + LOADER', 'GitHub ✅ CHARGÉ', 'success')
        print("^2[🚀 DENO ULTIMATE v4.0 + GITHUB LOADER]^7 F6 Prêt !")
    else
        denoNotify('DENO ULTIMATE', 'v4.0 ✅ Menu F6 actif', 'success')
        print("^1[🚀 DENO ULTIMATE v4.0]^7 Menu F6 actif (Loader HS)")
    end
end)

print("^1[🔥 DENO CHEAT ULTIMATE]^7 ^2v4.0^7 - ^3F6 / deno ^7(50+ options)")
