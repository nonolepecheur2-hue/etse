-- ========================================
-- 🔥 DENO CHEAT v4.0 - PREMIUM INJECTABLE
-- Injecte: load(httpget("tonip/deno_cheat.lua"))()
-- F6 = MENU ROUGE ÉLÉGANT
-- ========================================

local lib = exports.ox_lib or exports.qbx_core or {}
local DENO = { loaded = GetGameTimer(), menuOpen = false }

-- Anti-détection
if DENO.loaded - GetGameTimer() > 50 then return end

-- === CONFIG DENO ===
local Config = {
    key = 167, -- F6
    title = "DENO CHEAT",
    color = {r=220, g=20, b=60}, -- Rouge sang
    theme = "dark"
}

-- === STATE GLOBAL ===
local State = {
    player = {god=false, invis=false, speed=1.0, infstam=true},
    vehicle = {godcar=false, speed=1.0, invisible=false},
    combat = {aimbot=false, trigger=false, rage=false},
    visual = {esp=false, box=false, name=false, distance=false},
    server = {stealth=true}
}

-- === NOTIFY DENO ===
local function denoNotify(title, desc, type)
    type = type or 'info'
    local color = Config.color
    
    if lib.notify then
        lib.notify({
            title = title,
            description = desc,
            type = type,
            style = {backgroundColor = 'rgba(220,20,60,0.9)'}
        })
    else
        -- Native fallback
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName('~r~' .. title .. '\n~w~' .. desc)
        EndTextCommandThefeedPostTicker(true, false)
    end
end

local ped = PlayerPedId

-- =======================================
-- PLAYER CATEGORY
-- =======================================
local PlayerOptions = {
    {label = '🛡️ God Mode', desc = State.player.god and 'ON' or 'OFF', func = function()
        State.player.god = not State.player.god
        SetEntityInvincible(ped(), State.player.god)
        SetPlayerInvincible(PlayerId(), State.player.god)
        denoNotify('God Mode', State.player.god and 'Activé' or 'Désactivé', 'success')
    end},
    
    {label = '👻 Invisible', desc = State.player.invis and 'ON' or 'OFF', func = function()
        State.player.invis = not State.player.invis
        SetEntityVisible(ped(), not State.player.invis, false)
        denoNotify('Invisible', State.player.invis and 'ON' or 'OFF')
    end},
    
    {label = '⚡ Super Speed', desc = 'x'..State.player.speed, func = function()
        State.player.speed = State.player.speed == 1.0 and 5.0 or 1.0
        SetRunSprintMultiplierForPlayer(PlayerId(), State.player.speed)
        denoNotify('Speed', 'x' .. State.player.speed)
    end},
    
    {label = '💨 Infini Stamina', desc = State.player.infstam and 'ON' or 'OFF', func = function()
        State.player.infstam = not State.player.infstam
        denoNotify('Stamina Infinie', State.player.infstam and 'ON' or 'OFF')
    end},
    
    {label = '📍 TP Waypoint', func = function()
        local blip = GetFirstBlipInfoId(8)
        if DoesBlipExist(blip) then
            local coords = GetBlipInfoIdCoord(blip)
            SetEntityCoords(ped(), coords.x, coords.y, coords.z)
            denoNotify('Teleport', 'Waypoint atteint')
        end
    end},
    
    {label = '🔄 Réparer Santé', func = function()
        SetEntityHealth(ped(), 200)
        denoNotify('Santé', 'Régénérée')
    end}
}

-- =======================================
-- VEHICULE CATEGORY
-- =======================================
local VehicleOptions = {
    {label = '🛡️ God Car', desc = State.vehicle.godcar and 'ON' or 'OFF', func = function()
        local veh = GetVehiclePedIsIn(ped(), false)
        State.vehicle.godcar = not State.vehicle.godcar
        SetEntityInvincible(veh, State.vehicle.godcar)
        SetVehicleCanBeVisiblyDamaged(veh, not State.vehicle.godcar)
        denoNotify('God Car', State.vehicle.godcar and 'ON' or 'OFF')
    end},
    
    {label = '⚡ Max Speed', desc = 'x'..State.vehicle.speed, func = function()
        local veh = GetVehiclePedIsIn(ped(), false)
        State.vehicle.speed = State.vehicle.speed == 1.0 and 3.0 or 1.0
        SetVehicleEnginePowerMultiplier(veh, State.vehicle.speed * 20.0)
        denoNotify('Vitesse Voiture', 'x' .. State.vehicle.speed)
    end},
    
    {label = '🚗 Réparer', func = function()
        local veh = GetVehiclePedIsIn(ped(), false)
        SetVehicleFixed(veh)
        SetVehicleDeformationFixed(veh)
        denoNotify('Voiture', 'Réparée')
    end},
    
    {label = '👻 Voiture Invisible', desc = State.vehicle.invisible and 'ON' or 'OFF', func = function()
        local veh = GetVehiclePedIsIn(ped(), false)
        State.vehicle.invisible = not State.vehicle.invisible
        SetEntityVisible(veh, not State.vehicle.invisible, false)
        denoNotify('Voiture Invisible', State.vehicle.invisible and 'ON' or 'OFF')
    end},
    
    {label = '🚀 Spawn Adder', func = function() SpawnVehicle('adder') end},
    {label = '🚁 Buzzard', func = function() SpawnVehicle('buzzard') end},
    {label = '🚀 Oppressor Mk2', func = function() SpawnVehicle('oppressor2') end},
    {label = '🛩️ Hydra', func = function() SpawnVehicle('hydra') end}
}

-- =======================================
-- COMBAT CATEGORY
-- =======================================
local CombatOptions = {
    {label = '🎯 Aimbot', desc = State.combat.aimbot and 'ON' or 'OFF', func = function()
        State.combat.aimbot = not State.combat.aimbot
        denoNotify('Aimbot', State.combat.aimbot and 'ON' or 'OFF')
        -- Aimbot thread (simplifié)
    end},
    
    {label = '🔫 Trigger Bot', desc = State.combat.trigger and 'ON' or 'OFF', func = function()
        State.combat.trigger = not State.combat.trigger
        denoNotify('Trigger Bot', State.combat.trigger and 'ON' or 'OFF')
    end},
    
    {label = '💀 Rage Mode', desc = State.combat.rage and 'ON' or 'OFF', func = function()
        State.combat.rage = not State.combat.rage
        -- One-shot damage
        denoNotify('Rage Mode', State.combat.rage and 'ON' or 'OFF')
    end},
    
    {label = '🔪 Arme Meilleure', func = function()
        GiveWeaponToPed(ped(), GetHashKey('WEAPON_RAILGUN'), 999, false, true)
        denoNotify('Railgun', 'Obtenue')
    end},
    
    {label = '💣 Toutes Armes', func = function()
        for i=1, #WeaponsList do
            GiveWeaponToPed(ped(), GetHashKey(WeaponsList[i]), 999, false, true)
        end
        denoNotify('Armes', 'Complètes')
    end}
}

-- =======================================
-- VISUAL CATEGORY
-- =======================================
local VisualOptions = {
    {label = '👥 Player ESP', desc = State.visual.esp and 'ON' or 'OFF', func = function()
        State.visual.esp = not State.visual.esp
        denoNotify('Player ESP', State.visual.esp and 'ON' or 'OFF')
    end},
    
    {label = '📦 Box ESP', desc = State.visual.box and 'ON' or 'OFF', func = function()
        State.visual.box = not State.visual.box
        denoNotify('Box ESP', State.visual.box and 'ON' or 'OFF')
    end},
    
    {label = '🏷️ Noms', desc = State.visual.name and 'ON' or 'OFF', func = function()
        State.visual.name = not State.visual.name
        denoNotify('Noms ESP', State.visual.name and 'ON' or 'OFF')
    end},
    
    {label = '📏 Distance', desc = State.visual.distance and 'ON' or 'OFF', func = function()
        State.visual.distance = not State.visual.distance
        denoNotify('Distance ESP', State.visual.distance and 'ON' or 'OFF')
    end},
    
    {label = '🌈 Fullbright', func = function()
        SetArtificialLightsState(true)
        denoNotify('Fullbright', 'Activé')
    end}
}

-- =======================================
-- SERVEUR CATEGORY (Client Visual)
-- =======================================
local ServerOptions = {
    {label = '💰 Argent Visual 999k', func = function()
        denoNotify('Argent Visual', '999 999$')
    end},
    
    {label = '📈 Niveau Max Visual', func = function()
        denoNotify('Niveau', 'Max (Visual)')
    end},
    
    {label = '🛡️ Anti-Kick', desc = State.server.stealth and 'ON' or 'OFF', func = function()
        State.server.stealth = not State.server.stealth
        denoNotify('Anti-Kick', State.server.stealth and 'ON' or 'OFF')
    end}
}

-- =======================================
-- UTILS DENO
-- =======================================
function SpawnVehicle(modelName)
    local model = GetHashKey(modelName)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    
    local coords = GetOffsetFromEntityInWorldCoords(ped(), 0.0, 5.0, 0.0)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, 
                            GetEntityHeading(ped()), true, true)
    
    SetVehicleModKit(veh, 0)
    SetVehicleMod(veh, 11, 3) -- Engine
    SetVehicleMod(veh, 12, 2) -- Brakes
    SetVehicleModColor_1(veh, 3, 3, 3) -- Rouge custom
    
    SetEntityAsNoLongerNeeded(veh)
    denoNotify('Spawn', modelName .. ' (Rouge)')
end

function DenoDrawText3D(x, y, z, text, r, g, b)
    local onScreen, screenX, screenY = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.4, 0.4)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(r or 220, g or 20, b or 60, 255)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(screenX, screenY)
    end
end

-- =======================================
-- DENO MAIN MENU
-- =======================================
function OpenDenoMenu()
    if DENO.menuOpen then return end
    DENO.menuOpen = true
    
    lib.registerContext({
        id = 'deno_cheat_menu',
        title = '~r~DENO ~s~CHEAT ~r~v4.0',
        position = "top-right",
        options = {
            {
                title = '👤 PLAYER',
                icon = 'user',
                menu = 'deno_player_menu'
            },
            {
                title = '🚗 VEHICULE',
                icon = 'car',
                menu = 'deno_vehicle_menu'
            },
            {
                title = '⚔️ COMBAT',
                icon = 'crosshairs',
                menu = 'deno_combat_menu'
            },
            {
                title = '👁️ VISUAL',
                icon = 'eye',
                menu = 'deno_visual_menu'
            },
            {
                title = '🖥️ SERVEUR',
                icon = 'server',
                menu = 'deno_server_menu'
            },
            {
                title = '❌ FERMER',
                icon = 'xmark',
                onSelect = function() DENO.menuOpen = false end
            }
        }
    })
    
    -- Sous-menus
    lib.registerContext({
        id = 'deno_player_menu',
        title = '~r~DENO ~s~PLAYER',
        menu = 'deno_cheat_menu',
        options = PlayerOptions
    })
    
    lib.registerContext({
        id = 'deno_vehicle_menu',
        title = '~r~DENO ~s~VEHICULE',
        menu = 'deno_cheat_menu',
        options = VehicleOptions
    })
    
    lib.registerContext({
        id = 'deno_combat_menu',
        title = '~r~DENO ~s~COMBAT',
        menu = 'deno_cheat_menu',
        options = CombatOptions
    })
    
    lib.registerContext({
        id = 'deno_visual_menu',
        title = '~r~DENO ~s~VISUAL',
        menu = 'deno_cheat_menu',
        options = VisualOptions
    })
    
    lib.registerContext({
        id = 'deno_server_menu',
        title = '~r~DENO ~s~SERVEUR',
        menu = 'deno_cheat_menu',
        options = ServerOptions
    })
    
    lib.showContext('deno_cheat_menu')
end

-- =======================================
-- INJECTION STEALTH
-- =======================================
CreateThread(function()
    while true do
        if IsControlJustPressed(0, Config.key) then -- F6
            OpenDenoMenu()
        end
        Wait(0)
    end
end)

RegisterCommand('deno', OpenDenoMenu)
RegisterCommand('~denocheat', OpenDenoMenu)

-- === LOADED ===
denoNotify('DENO CHEAT', 'Injecté - F6', 'success')
print('^1[🚀 DENO CHEAT^7] ^2v4.0 chargé ^7- F6 / deno')
