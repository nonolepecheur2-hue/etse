

local Menu = {
    isOpen = false,
    selectedIndex = 1,
    currentCategory = "main",
    scrollbarTargetY = 0,
    scrollbarCurrentY = 0,
    transitionOffset = 0,
    transitionDirection = 0,
    categoryHistory = {},
    categoryIndexes = {}
}

local categories = {
    main = {
        title = "Main",
        items = {
            {label = "Player", action = "category", target = "player"},
            {label = "Serveur", action = "category", target = "serveur"},
            {label = "Combat", action = "category", target = "combat"},
            {label = "Véhicule", action = "category", target = "vehicule"},
            {label = "Visual", action = "category", target = "visual"},
            {label = "Paramètres", action = "category", target = "parametre"}
        }
    },

    player = {
        title = "Player",
        items = {
            {label = "Health", action = "category", target = "player_health"},
            {label = "Movement", action = "category", target = "player_movement"},
            {label = "personnaliser", action = "category", target = "player_personnalise"},
            {label = "Other", action = "category", target = "player_other"}
        }
    },

    player_health = {
        title = "Player - Health",
        items = {
            {label = "Godmode", action = "godmode"},
            {label = "Revive Player", action = "revive"},
            {label = "Heal Player", action = "heal"},
            {label = "Give Armor", action = "give_armor"},

        }
    },

    player_movement = {
        title = "Player - Movement",
        items = {
            {label = "Noclip", action = "noclip"},
            {label = "Slide Run", action = "sliderun"},
            {label = "Super Jump", action = "superjump"},
            {label = "Infinite Stamina", action = "infinite_stamina"},
            {label = "Player Invisible", action = "player_invisible"},
        }
    },
    
    player_personnalise = {
             title = "Player personalise",
             items = {
                       {label = "Random outfit", action = "random_outfit"},
             }
    },

    player_other = {
        title = "Player - Other",
        items = {
            {label = "Throw From Vehicle", action = "throwvehicle"},
            {label = "Super Strength", action = "superstrength"},
            {label = "Explosive Melee", action = "explosive_melee"},
            {label = "Carry Vehicle", action = "carry_vehicle"},      
            {label = "TP to Waypoint", action = "tp_to_waypoint"}, 
            {label = "Freecam", action = "freecam"},    
        }
    },

    serveur = {
        title = "Serveur",
        items = {
            {label = "player-list", action = "player-list"},
            {label = "Other", action = "category", target = "serveur_other"}
        }
    },
    
    serveur_other = {
            title = "Other",
            items = {
                    {label = "Spectate Selected Player", action = "spectate_toggle"},   
                    {label = "TP to Selected Player", action = "tp_to_player"},
           }
     },

             


    combat = {
        title = "Combat",
        items = {
            {label = "Aimbot", action = "aimbot"},
             {label = "Aimbot FOV", action = "aimbot_fov"},
        }
    },

    vehicule = {
        title = "Véhicule",
        items = {
            {label = "Boost Véhicule", action = "none"},
            {label = "Repair Véhicule", action = "none"}
        }
    },

    -- Visual modifié pour inclure Player ESP
    visual = {
        title = "Visual",
        items = {
            {label = "Player ESP", action = "category", target = "visual_playeresp"},
            {label = "Crosshair", action = "none"}
        }
    },

    -- Sous-catégorie Player ESP
    visual_playeresp = {
        title = "Visual - Player ESP",
        items = {
            {label = "Box", action = "esp_box"},
            {label = "Skeleton", action = "esp_skeleton"},
            {label = "Tracers", action = "esp_tracers"},
            {label = "Health Bar", action = "esp_health"},
            {label = "Armor Bar", action = "esp_armor"},
            {label = "Nametags", action = "esp_nametag"},
            {label = "Distance", action = "esp_distance"},
            {label = "Weapon", action = "esp_weapon"},
            {label = "Ignore Self", action = "esp_ignore_self"},
            {label = "Show Friends", action = "esp_friends"},
            {label = "Show Pedestrians", action = "esp_peds"},
            {label = "Show Invisible", action = "esp_invisible"}
        }
    },

    parametre = {
        title = "Paramètres",
        items = {
            {label = "Changer Couleur Menu", action = "none"},
            {label = "Reset Config", action = "none"}
        }
    }
}

-- Variables ESP
local esp_box = false
local esp_skeleton = false
local esp_tracers = false
local esp_health = false
local esp_armor = false
local esp_nametag = false
local esp_distance = false
local esp_weapon = false
local esp_ignore_self = false
local esp_friends = false
local esp_peds = false
local esp_invisible = false

-- Variables existantes
local godmodeEnabled = false
local noclipEnabled = false
local noclipSpeed = 2.0
local sliderunEnabled = false
local sliderunSpeed = 5.0
local superjumpEnabled = false
local throwvehicleEnabled = false
local superstrengthEnabled = false
local infiniteStaminaEnabled = false
local explosiveMeleeEnabled = false
local aimbotEnabled = false
local aimbotFOV = 25.0
aimbot_fov = false
local carryVehicleEnabled = false
local carriedVehicle = nil
spectateEnabled = false
local playerInvisibleEnabled = false
local freecamEnabled = false
local freecamCam = nil
local freecamSpeed = 1.0
local freecamFeature = 1
local freecamHeldVehicle = nil
local freecamHoldDistance = 5.0

local freecamFeatures = {
    "Nothing",
    "Car Spawn",
    "Teleport",
    "Shoot Rockets",
    "Car Spam",
    "Car Delete",
    "Physics Gun"
}



local Banner = {
    enabled = true,
    imagePath = nil,
    text = "VIP",
    subtitle = "MENU",
    height = 100
}




local bannerTexture = nil
local bannerWidth = 0
local bannerHeight = 0

local Style = {
    -- POSITION & DIMENSIONS
    x = 60,
    y = 80,
    width = 420,
    height = 40,
    itemSpacing = 5,

    -- COULEURS (inspiré du menu Plaid)
    bgColor = {0.02, 0.02, 0.02, 0.92},        -- Fond très sombre
    headerColor = {0.05, 0.05, 0.05, 1.0},     -- Bandeau noir profond
    selectedColor = {0.20, 0.55, 1.00, 0.95},  -- Bleu électrique moderne
    itemColor = {0.10, 0.10, 0.10, 0.85},      -- Fond item sombre
    itemHoverColor = {0.16, 0.16, 0.16, 0.90}, -- Hover gris foncé
    accentColor = {0.25, 0.55, 1.00, 1.0},     -- Bleu vif (lignes, sliders)
    textColor = {1.0, 1.0, 1.0, 1.0},          -- Blanc pur
    textSecondary = {0.75, 0.75, 0.75, 0.9},   -- Gris clair
    separatorColor = {0.25, 0.25, 0.25, 0.6},  -- Séparateurs gris
    footerColor = {0.05, 0.05, 0.05, 1.0},     -- Footer sombre

    scrollbarBg = {0.08, 0.08, 0.08, 0.8},     -- Scrollbar fond
    scrollbarThumb = {0.25, 0.55, 1.00, 0.95}, -- Scrollbar bleu

    -- TAILLES DE TEXTE
    titleSize = 24,
    subtitleSize = 16,
    itemSize = 18,
    infoSize = 14,
    footerSize = 14,
    bannerTitleSize = 34,
    bannerSubtitleSize = 18,

    -- DIMENSIONS
    headerHeight = 48,   -- plus fin
    footerHeight = 32,

    -- ARRONDIS
    headerRounding = 8.0,
    itemRounding = 8.0,
    footerRounding = 8.0,
    bannerRounding = 8.0,
    globalRounding = 10.0,

    -- SCROLLBAR
    scrollbarWidth = 8,
    scrollbarPadding = 12
}



-- Actions (avec ESP ajoutés)
local actions = {
    close = function()
        Menu.isOpen = false
        Susano.ResetFrame()
    end,

    category = function(target)
        Menu.categoryIndexes[Menu.currentCategory] = Menu.selectedIndex
        table.insert(Menu.categoryHistory, Menu.currentCategory)
        Menu.transitionDirection = 1
        Menu.transitionOffset = -50
        Menu.currentCategory = target
        Menu.selectedIndex = Menu.categoryIndexes[target] or 1
    end,

    godmode = function()
        godmodeEnabled = not godmodeEnabled
        print(godmodeEnabled and "^2✓ Godmode enabled^0" or "^1✗ Godmode disabled^0")
    end,

    revive = function()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        ClearPedBloodDamage(ped)
        ClearPedTasksImmediately(ped)
        print("^2✓ Revived^0")
    end,

    heal = function()
        local ped = PlayerPedId()
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        print("^2✓ Healed^0")
    end,

    noclip = function()
        noclipEnabled = not noclipEnabled
        print(noclipEnabled and "^2✓ Noclip enabled^0" or "^1✗ Noclip disabled^0")
    end,

    sliderun = function()
        sliderunEnabled = not sliderunEnabled
        print(sliderunEnabled and "^2✓ Slide Run enabled^0" or "^1✗ Slide Run disabled^0")
    end,

    superjump = function()
        superjumpEnabled = not superjumpEnabled
        print(superjumpEnabled and "^2✓ Super Jump enabled^0" or "^1✗ Super Jump disabled^0")
    end,

    throwvehicle = function()
        throwvehicleEnabled = not throwvehicleEnabled
        print(throwvehicleEnabled and "^2✓ Throw From Vehicle enabled^0" or "^1✗ Throw From Vehicle disabled^0")
    end,

    superstrength = function()
        superstrengthEnabled = not superstrengthEnabled
        print(superstrengthEnabled and "^2✓ Super Strength enabled^0" or "^1✗ Super Strength disabled^0")
    end,

    infinite_stamina = function()
        infiniteStaminaEnabled = not infiniteStaminaEnabled
        print(infiniteStaminaEnabled and "^2✓ Infinite Stamina enabled^0" or "^1✗ Infinite Stamina disabled^0")
    end,

    explosive_melee = function()
        explosiveMeleeEnabled = not explosiveMeleeEnabled
        print(explosiveMeleeEnabled and "^2✓ Explosive Melee enabled^0" or "^1✗ Explosive Melee disabled^0")
    end,
    
    aimbot = function()
        aimbotEnabled = not aimbotEnabled
        print(aimbotEnabled and  "^2✓ aimbot enabled^0" or "^1✗ aimbot disabled^0")
    end,
    
    aimbot_fov_toggle = function()
              aimbotFOVEnabled = not aimbotFOVEnabled
              print(aimbotFOVEnabled and "^2✓ Aimbot FOV enabled^0" or "^1✗ Aimbot FOV disabled^0")
    end,

    
    aimbot_fov = function(direction)
               if direction == "left" then
                     aimbotFOV = math.max(1, aimbotFOV - 1)
              else
                     aimbotFOV = math.min(180, aimbotFOV + 1)
             end

            print("^2Aimbot FOV: ^0" .. aimbotFOV)
    end,
    
    carry_vehicle = function()
            carryVehicleEnabled = not carryVehicleEnabled

            if not carryVehicleEnabled and carriedVehicle then
                  DetachEntity(carriedVehicle, true, true)
                  carriedVehicle = nil
           end

           print(carryVehicleEnabled and "^2✓ Carry Vehicle enabled^0" or "^1✗ Carry Vehicle disabled^0")
    end,
    
    spectate_toggle = function()
                     spectateEnabled = not spectateEnabled

                     if spectateEnabled then
                           if lastSelectedPlayer then
                                Susano.Spectate(GetPlayerPed(lastSelectedPlayer))
                                print("^2✓ Spectate enabled on player "..lastSelectedPlayer.."^0")
                          else
                                print("^1✗ Aucun joueur sélectionné^0")
                                spectateEnabled = false
                         end
                     else
                            Susano.StopSpectate()
                            print("^1✗ Spectate disabled^0")
                    end
    end,
    
    tp_to_player = function()
               if lastSelectedPlayer then
                    local targetPed = GetPlayerPed(GetPlayerFromServerId(lastSelectedPlayer))
                    if targetPed and targetPed ~= 0 then
                         local coords = GetEntityCoords(targetPed)
                         SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
                         print("^2✓ Téléporté au joueur "..lastSelectedPlayer.."^0")
                   else
                         print("^1✗ Joueur introuvable^0")
                  end
             else
                    print("^1✗ Aucun joueur sélectionné^0")
            end
    end,
    
    random_outfit = function()
              local ped = PlayerPedId()

              -- Random components (0 à 11)
              for i = 0, 11 do
                    local maxDraw = GetNumberOfPedDrawableVariations(ped, i)
                    if maxDraw > 0 then
                            local drawable = math.random(0, maxDraw - 1)
                            local maxTex = GetNumberOfPedTextureVariations(ped, i, drawable)
                            local texture = math.random(0, math.max(0, maxTex - 1))
                            SetPedComponentVariation(ped, i, drawable, texture, 0)
                    end
            end

            -- Random props (0 à 7)
            for i = 0, 7 do
                  if math.random(0, 1) == 1 then
                         ClearPedProp(ped, i)
                 else
                         local maxProp = GetNumberOfPedPropDrawableVariations(ped, i)
                          if maxProp > 0 then
                                  local prop = math.random(0, maxProp - 1)
                                  local maxTex = GetNumberOfPedPropTextureVariations(ped, i, prop)
                                  local tex = math.random(0, math.max(0, maxTex - 1))
                                  SetPedPropIndex(ped, i, prop, tex, true)
                         end
                  end
            end

            print("^2✓ Random outfit applied^0")
    end,
    
    tp_to_waypoint = function()
    local waypoint = GetFirstBlipInfoId(8) -- 8 = BLIP_WAYPOINT

    if DoesBlipExist(waypoint) then
        local coords = GetBlipInfoIdCoord(waypoint)
        local ped = PlayerPedId()

        -- On téléporte un peu au-dessus pour éviter de tomber sous la map
        SetEntityCoords(ped, coords.x, coords.y, coords.z + 1.0, false, false, false, false)

        print("^2✓ Téléporté au waypoint^0")
    else
        print("^1✗ Aucun waypoint trouvé^0")
    end
end,

give_armor = function()
    local ped = PlayerPedId()
    SetPedArmour(ped, 100)
    print("^2✓ Armor given^0")
end,

player_invisible = function()
    playerInvisibleEnabled = not playerInvisibleEnabled

    local ped = PlayerPedId()
    SetEntityVisible(ped, not playerInvisibleEnabled, false)

    print(playerInvisibleEnabled and "^2✓ Player invisible enabled^0" or "^1✗ Player invisible disabled^0")
end,

freecam = function()
    freecamEnabled = not freecamEnabled

    if freecamEnabled then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local rot = GetGameplayCamRot(2)

        freecamCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(freecamCam, pos)
        SetCamRot(freecamCam, rot, 2)
        SetCamActive(freecamCam, true)
        RenderScriptCams(true, false, 0, true, true)

        print("^2✓ Freecam enabled^0")
    else
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(freecamCam, false)
        freecamCam = nil

        if freecamHeldVehicle then
            SetEntityCollision(freecamHeldVehicle, true, true)
            SetEntityAlpha(freecamHeldVehicle, 255, false)
            freecamHeldVehicle = nil
        end

        print("^1✗ Freecam disabled^0")
    end
end,








    -- ESP actions
    esp_box = function() esp_box = not esp_box end,
    esp_skeleton = function() esp_skeleton = not esp_skeleton end,
    esp_tracers = function() esp_tracers = not esp_tracers end,
    esp_health = function() esp_health = not esp_health end,
    esp_armor = function() esp_armor = not esp_armor end,
    esp_nametag = function() esp_nametag = not esp_nametag end,
    esp_distance = function() esp_distance = not esp_distance end,
    esp_weapon = function() esp_weapon = not esp_weapon end,
    esp_ignore_self = function() esp_ignore_self = not esp_ignore_self end,
    esp_friends = function() esp_friends = not esp_friends end,
    esp_peds = function() esp_peds = not esp_peds end,
    esp_invisible = function() esp_invisible = not esp_invisible end
}

function RunAimbotLogic()
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)

    local bestTarget = nil
    local bestFov = aimbotFOV

    for _, player in ipairs(GetActivePlayers()) do
        if player ~= PlayerId() then
            local ped = GetPlayerPed(player)
            if DoesEntityExist(ped) and not IsEntityDead(ped) then

                local coords = GetEntityCoords(ped)
                local onScreen, sx, sy = World3dToScreen2d(coords.x, coords.y, coords.z)

                if onScreen then
                    local dx = sx - 0.5
                    local dy = sy - 0.5
                    local fovDist = math.sqrt(dx*dx + dy*dy) * 100

                    if fovDist < bestFov then
                        bestFov = fovDist
                        bestTarget = ped
                    end
                end
            end
        end
    end

    if bestTarget then
        local targetCoords = GetEntityCoords(bestTarget)
        TaskAimGunAtCoord(myPed, targetCoords.x, targetCoords.y, targetCoords.z, 50, false, false)
    end
end

----------------------------------------------------------------------
-- PLAYER LIST (simple + thread + catégorie dynamique)
----------------------------------------------------------------------

local playerListItems = {}

-- Catégorie auto pour ta liste
categories.player_list = {
    title = "Players",
    items = playerListItems
}

-- Action quand tu cliques "player-list"
actions["player-list"] = function()
    Menu.categoryIndexes[Menu.currentCategory] = Menu.selectedIndex
    table.insert(Menu.categoryHistory, Menu.currentCategory)
    Menu.currentCategory = "player_list"
    Menu.selectedIndex = 1
end

-- Thread refresh auto
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(800)

        local newItems = {}

        for _, p in ipairs(GetActivePlayers()) do
            local sid = GetPlayerServerId(p)
            local name = GetPlayerName(p) or "unknown"

            table.insert(newItems, {
                label = string.format("%d | %s", sid, name),
                action = "none"
            })
        end

        table.sort(newItems, function(a, b)
            local ida = tonumber(a.label:match("^(%d+)")) or 0
            local idb = tonumber(b.label:match("^(%d+)")) or 0
            return ida < idb
        end)

        playerListItems = newItems
        categories.player_list.items = playerListItems
    end
end)
 


-- Petit helper : rectangle “dégradé” (simulé en plusieurs bandes)
local function DrawVerticalGradient(x, y, w, h, top, bottom, rounding)
    local steps = 18
    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        local r = top[1] + (bottom[1] - top[1]) * t
        local g = top[2] + (bottom[2] - top[2]) * t
        local b = top[3] + (bottom[3] - top[3]) * t
        local a = top[4] + (bottom[4] - top[4]) * t
        local yy = y + (h * i / steps)
        Susano.DrawRectFilled(x, yy, w, h / steps + 0.2, r, g, b, a, rounding)
    end
end

-- Helper : clamp texte à droite (si pas de fonction AlignRight, on calcule la largeur)
local function DrawTextRight(xRight, y, text, size, r,g,b,a)
    local tw = Susano.GetTextWidth(text, size)
    Susano.DrawText(xRight - tw, y, text, size, r,g,b,a)
end

local selectedPlayers = {}   -- stockage des joueurs sélectionnés
local maxListHeight = 380    -- hauteur max du panneau scrollable

local selectedPlayers = {}   -- stockage des joueurs sélectionnés
local maxListHeight = 380    -- hauteur max du panneau scrollable

function DrawMenu()
    if not Menu.isOpen then return end
    Susano.BeginFrame()

    local category = categories[Menu.currentCategory]
    if not category then
        Menu.currentCategory = "main"
        category = categories["main"]
    end

    local x, y = Style.x, Style.y
    local w = Style.width
    local itemH = 34
    local gap = 4

    -------------------------------------------------
    -- STYLE
    -------------------------------------------------
    local cBanner = {0.10,0.10,0.10,0.90}
    local cHeader = {0.05,0.05,0.05,0.85}
    local cPanel  = {0.00,0.00,0.00,0.35}
    local cItem   = {0.05,0.05,0.05,0.35}
    local cSel    = {0.75,0.75,0.75,0.35}
    local cText   = {1,1,1,0.9}

    local curY = y

    -------------------------------------------------
    -- BANNER
    -------------------------------------------------
    if Banner.enabled then
        if bannerTexture then
            Susano.DrawImage(bannerTexture, x, curY, w, Banner.height, 1,1,1,1,0)
        else
            Susano.DrawRectFilled(x, curY, w, Banner.height, cBanner[1],cBanner[2],cBanner[3],cBanner[4],0)
        end
        curY = curY + Banner.height
    end

    -------------------------------------------------
    -- HEADER
    -------------------------------------------------
    Susano.DrawRectFilled(x, curY, w, 26, cHeader[1],cHeader[2],cHeader[3],cHeader[4],0)
    Susano.DrawText(x+10, curY+5, "Main Menu", 14, 1,1,1,0.7)
    curY = curY + 30

    -------------------------------------------------
    -- SCROLLING POUR PLAYER LIST
    -------------------------------------------------
    local itemsCount = #category.items
    local totalHeight = itemsCount * (itemH + gap)
    local scrollable = (Menu.currentCategory == "player_list" and totalHeight > maxListHeight)

    local panelHeight = scrollable and maxListHeight or totalHeight
    Susano.DrawRectFilled(x, curY-6, w, panelHeight+40, cPanel[1],cPanel[2],cPanel[3],cPanel[4],0)

    -- Calcul du scroll
    if scrollable then
        if Menu.selectedIndex < 1 then Menu.selectedIndex = 1 end
        if Menu.selectedIndex > itemsCount then Menu.selectedIndex = itemsCount end

        local visibleItems = math.floor(maxListHeight / (itemH + gap))
        local startIndex = math.max(1, Menu.selectedIndex - math.floor(visibleItems/2))
        local endIndex = math.min(itemsCount, startIndex + visibleItems - 1)

        -- Scrollbar GRIS
        local sbHeight = maxListHeight * (visibleItems / itemsCount)
        local sbY = curY + ((Menu.selectedIndex - 1) / itemsCount) * maxListHeight
        Susano.DrawRectFilled(x + w - 10, sbY, 6, sbHeight, 0.6,0.6,0.6,0.9, 4)

        category._startIndex = startIndex
        category._endIndex = endIndex
    else
        category._startIndex = 1
        category._endIndex = itemsCount
    end

    -------------------------------------------------
    -- SLIDERS
    -------------------------------------------------
    local sliderActions = {
        noclip = {var=function() return noclipSpeed end, min=0.5, max=10},
        sliderun = {var=function() return sliderunSpeed end, min=1, max=20},
        aimbot_fov = {var=function() return aimbotFOV end, min=5, max=180}
    }

    -------------------------------------------------
    -- TOGGLES
    -------------------------------------------------
    local toggleStates = {
        godmode = godmodeEnabled,
        noclip = noclipEnabled,
        sliderun = sliderunEnabled,
        superjump = superjumpEnabled,
        throwvehicle = throwvehicleEnabled,
        superstrength = superstrengthEnabled,
        infinite_stamina = infiniteStaminaEnabled,
        explosive_melee = explosiveMeleeEnabled,
        aimbot = aimbotEnabled,
        carry_vehicle = carryVehicleEnabled,
        spectate_toggle = spectateEnabled,
        player_invisible = playerInvisibleEnabled,
        freecam = freecamEnabled,



        esp_box = esp_box,
        esp_skeleton = esp_skeleton,
        esp_tracers = esp_tracers,
        esp_health = esp_health,
        esp_armor = esp_armor,
        esp_nametag = esp_nametag,
        esp_distance = esp_distance,
        esp_weapon = esp_weapon,
        esp_ignore_self = esp_ignore_self,
        esp_friends = esp_friends,
        esp_peds = esp_peds,
        esp_invisible = esp_invisible
    }

    -------------------------------------------------
    -- ITEMS
    -------------------------------------------------
    for i = category._startIndex, category._endIndex do
        local item = category.items[i]
        local iy = curY + ((i - category._startIndex) * (itemH + gap))
        local selected = (i == Menu.selectedIndex)

        local bg = selected and cSel or cItem
        Susano.DrawRectFilled(x, iy, w, itemH, bg[1],bg[2],bg[3],bg[4],0)
        Susano.DrawText(x+12, iy+7, item.label, 18, cText[1],cText[2],cText[3],1)

        -------------------------------------------------
        -- FLECHE DE CATÉGORIE
        -------------------------------------------------
        if item.action == "category" then
            Susano.DrawText(x+w-18, iy+7, ">", 18, 1,1,1,0.7)
        end

        -------------------------------------------------
        -- SLIDER
        -------------------------------------------------
        local slider = sliderActions[item.action]
        if slider then
            local v = slider.var()
            local percent = (v-slider.min)/(slider.max-slider.min)

            local bw,bh = 100,6
            local bx = x+w-bw-60
            local by = iy+(itemH-bh)/2

            Susano.DrawRectFilled(bx,by,bw,bh,0.2,0.2,0.2,0.8,3)
            Susano.DrawRectFilled(bx,by,bw*percent,bh,0.9,0.9,0.9,0.9,3)
            Susano.DrawText(x+w-18, iy+7, string.format("%.0f",v), 14,1,1,1,0.8)
        end

        -------------------------------------------------
        -- TOGGLE NORMAL
        -------------------------------------------------
        if toggleStates[item.action] ~= nil then
            local isOn = toggleStates[item.action]
            local tw,th = 36,14
            local tx = x+w-tw-12
            local ty = iy+(itemH-th)/2

            Susano.DrawRectFilled(tx,ty,tw,th, isOn and 0.9 or 0.2, isOn and 0.9 or 0.2, isOn and 0.9 or 0.2,0.9,7)
            local k = 10
            local kx = isOn and (tx+tw-k-2) or (tx+2)
            Susano.DrawRectFilled(kx,ty+2,k,k,1,1,1,1,5)
        end

        -------------------------------------------------
        -- TOGGLE POUR PLAYER LIST
        -------------------------------------------------
        if Menu.currentCategory == "player_list" then
            local sid = tonumber(item.label:match("^(%d+)"))
            if sid then
                local isSel = selectedPlayers[sid]
                local tw,th = 36,14
                local tx = x+w-tw-12
                local ty = iy+(itemH-th)/2

                Susano.DrawRectFilled(tx,ty,tw,th, isSel and 0.9 or 0.2, isSel and 0.9 or 0.2, isSel and 0.9 or 0.2,0.9,7)
                local k = 10
                local kx = isSel and (tx+tw-k-2) or (tx+2)
                Susano.DrawRectFilled(kx,ty+2,k,k,1,1,1,1,5)
            end
        end
    end

    Susano.SubmitFrame()
end



local VK_F5 = 0x74
local VK_UP = 0x26
local VK_DOWN = 0x28
local VK_RETURN = 0x0D
local VK_BACK = 0x08
local VK_LEFT = 0x25
local VK_RIGHT = 0x27

Citizen.CreateThread(function()
    local lastF5Press = false
    local lastUpPress = false
    local lastDownPress = false
    local lastEnterPress = false
    local lastBackPress = false
    local lastLeftPress = false
    local lastRightPress = false

    local enterPressed = false -- ✅ pour que ça existe après le if

    while true do
        Citizen.Wait(0)

        local _, f5Pressed = Susano.GetAsyncKeyState(VK_F5)
        if f5Pressed and not lastF5Press then
            Menu.isOpen = not Menu.isOpen
            if Menu.isOpen then
                Menu.currentCategory = "main"
                Menu.selectedIndex = 1
                print("^2Menu opened^0")
            else
                Susano.ResetFrame()
                print("^1Menu closed^0")
            end
        end
        lastF5Press = f5Pressed

        if Menu.isOpen then
            local category = categories[Menu.currentCategory]

            local _, upPressed = Susano.GetAsyncKeyState(VK_UP)
            if upPressed and not lastUpPress then
                Menu.selectedIndex = Menu.selectedIndex - 1
                if Menu.selectedIndex < 1 then
                    Menu.selectedIndex = #category.items
                end
            end
            lastUpPress = upPressed

            local _, downPressed = Susano.GetAsyncKeyState(VK_DOWN)
            if downPressed and not lastDownPress then
                Menu.selectedIndex = Menu.selectedIndex + 1
                if Menu.selectedIndex > #category.items then
                    Menu.selectedIndex = 1
                end
            end
            lastDownPress = downPressed

            local _, leftPressed = Susano.GetAsyncKeyState(VK_LEFT)
            local _, rightPressed = Susano.GetAsyncKeyState(VK_RIGHT)

            if (leftPressed and not lastLeftPress) or (rightPressed and not lastRightPress) then
                local item = category.items[Menu.selectedIndex]
                if item then
                    if item.action == "noclip" then
                        if leftPressed then
                            noclipSpeed = math.max(0.5, noclipSpeed - 0.5)
                        else
                            noclipSpeed = math.min(10.0, noclipSpeed + 0.5)
                        end
                    elseif item.action == "sliderun" then
                        if leftPressed then
                            sliderunSpeed = math.max(1.0, sliderunSpeed - 1.0)
                        else
                            sliderunSpeed = math.min(20.0, sliderunSpeed + 1.0)
                        end
                    elseif item.action == "aimbot_fov" then
                        if leftPressed then
                            aimbotFOV = math.max(1, aimbotFOV - 1)
                        else
                            aimbotFOV = math.min(180, aimbotFOV + 1)
                        end
                    end
                end
            end
            lastLeftPress = leftPressed
            lastRightPress = rightPressed

            local _, backPressed = Susano.GetAsyncKeyState(VK_BACK)
            if backPressed and not lastBackPress then
                if Menu.currentCategory ~= "main" then
                    Menu.categoryIndexes[Menu.currentCategory] = Menu.selectedIndex

                    Menu.transitionDirection = -1
                    Menu.transitionOffset = 50

                    if #Menu.categoryHistory > 0 then
                        Menu.currentCategory = table.remove(Menu.categoryHistory)
                        Menu.selectedIndex = Menu.categoryIndexes[Menu.currentCategory] or 1
                    else
                        Menu.currentCategory = "main"
                        Menu.selectedIndex = Menu.categoryIndexes["main"] or 1
                    end
                else
                    Menu.isOpen = false
                    Susano.ResetFrame()
                    print("^1Menu closed^0")
                end
            end
            lastBackPress = backPressed

            -- ✅ ENTER (enterPressed reste accessible après)
            local _, ep = Susano.GetAsyncKeyState(VK_RETURN)
            enterPressed = ep

            if enterPressed and not lastEnterPress then
                local item = category.items[Menu.selectedIndex]

                -- Gestion spéciale pour la player-list
                if Menu.currentCategory == "player_list" then
                    if item then
                        local sid = tonumber(item.label:match("^(%d+)"))
                        if sid then
                            selectedPlayers[sid] = not selectedPlayers[sid]
                            lastSelectedPlayer = sid
                        end
                    end
                    goto skip_action
                end

                -- empêcher ENTER d'agir sur les sliders
                if item and item.action ~= "aimbot_fov" then
                    local action = actions[item.action]
                    if action then
                        if item.target then
                            action(item.target)
                        else
                            action()
                        end
                    end
                end
            end

            -- ✅ comme avant: draw dans Menu.isOpen
            DrawMenu()
        else
            -- si menu fermé, on réinitialise pour éviter un “sticky press”
            enterPressed = false
        end

        ::skip_action::
        lastEnterPress = enterPressed
    end
end)




Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- NOCLIP
        if noclipEnabled then
            local ped = PlayerPedId()
            local entity = ped
            local inVehicle = IsPedInAnyVehicle(ped, false)
            if inVehicle then
                entity = GetVehiclePedIsIn(ped, false)
            end

            SetEntityCollision(entity, false, false)
            if inVehicle then
                FreezeEntityPosition(entity, true)
            else
                FreezeEntityPosition(ped, true)
            end
            SetEntityInvincible(ped, true)

            local pos = GetEntityCoords(entity, false)
            local camRot = GetGameplayCamRot(2)
            local pitch = math.rad(camRot.x)
            local yaw = math.rad(camRot.z)

            local forward = {
                x = -math.sin(yaw) * math.cos(pitch),
                y =  math.cos(yaw) * math.cos(pitch),
                z =  math.sin(pitch)
            }
            local right = {
                x =  math.cos(yaw),
                y =  math.sin(yaw),
                z =  0.0
            }

            local speed = noclipSpeed
            if IsControlPressed(0, 21) then speed = speed * 3.0 end

            if IsControlPressed(0, 32) then
                pos = vector3(pos.x + forward.x * speed, pos.y + forward.y * speed, pos.z + forward.z * speed)
            end
            if IsControlPressed(0, 33) then
                pos = vector3(pos.x - forward.x * speed, pos.y - forward.y * speed, pos.z - forward.z * speed)
            end
            if IsControlPressed(0, 35) then
                pos = vector3(pos.x + right.x * speed, pos.y + right.y * speed, pos.z + right.z * speed)
            end
            if IsControlPressed(0, 34) then
                pos = vector3(pos.x - right.x * speed, pos.y - right.y * speed, pos.z - right.z * speed)
            end
            if IsControlPressed(0, 22) then
                pos = vector3(pos.x, pos.y, pos.z + speed)
            end
            if IsControlPressed(0, 36) then
                pos = vector3(pos.x, pos.y, pos.z - speed)
            end

            SetEntityCoordsNoOffset(entity, pos.x, pos.y, pos.z, true, true, true)
            if inVehicle then SetEntityVelocity(entity, 0.0, 0.0, 0.0) end
        else
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)
                SetEntityCollision(veh, true, true)
                FreezeEntityPosition(veh, false)
            end
            if not godmodeEnabled then
                SetEntityInvincible(ped, false)
            end
            SetEntityCollision(ped, true, true)
            FreezeEntityPosition(ped, false)
        end

        -- GODMODE
        if godmodeEnabled then
            local ped = PlayerPedId()
            SetEntityInvincible(ped, true)
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            if health < maxHealth then
                SetEntityHealth(ped, maxHealth)
            end
            SetPedCanRagdoll(ped, false)
            SetPedCanBeKnockedOffVehicle(ped, 1)
        end

        -- STAMINA
        if infiniteStaminaEnabled then
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) and not IsPedInAnyVehicle(ped, false) then
                RestorePlayerStamina(PlayerId(), 1.0)
            end
        end

        -- SUPERJUMP
        if superjumpEnabled then
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) then
                SetSuperJumpThisFrame(PlayerId())
            end
        end

        -- EXPLOSIVE MELEE
        if explosiveMeleeEnabled then
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) and (IsPedArmed(ped, 1) or GetSelectedPedWeapon(ped) == `WEAPON_UNARMED`) then
                if IsControlJustPressed(0, 24) then
                    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.2, 0.0)
                    AddExplosion(coords.x, coords.y, coords.z, 1, 1.0, true, false, 1.0)
                end
            end
        end

        -- SLIDERUN
        if sliderunEnabled then
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) and not IsPedInAnyVehicle(ped, false) then
                if IsPedRunning(ped) or IsPedSprinting(ped) then
                    local velocity = GetEntityVelocity(ped)
                    local heading = GetEntityHeading(ped)
                    local radians = math.rad(heading)
                    local forwardX = -math.sin(radians) * sliderunSpeed
                    local forwardY =  math.cos(radians) * sliderunSpeed
                    SetEntityVelocity(ped, forwardX, forwardY, velocity.z)
                end
            end
        end
    end
end)


       
local function W2S(x, y, z)
    local ok, sx, sy = World3dToScreen2d(x, y, z)
    if not ok then return false, 0, 0 end

    local resX, resY = GetActiveScreenResolution()
    return true, sx * resX, sy * resY
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local anyESP =
            esp_box or esp_outlines or esp_skeleton or esp_chams or esp_tracers or
            esp_health or esp_armor or esp_nametag or esp_distance or esp_weapon or
            esp_ignore_self or esp_friends or esp_peds or esp_invisible

        if not anyESP then
            Susano.BeginFrame()
            Susano.SubmitFrame()
            goto continue
        end

        local myPed      = PlayerPedId()
        local myCoords   = GetEntityCoords(myPed)
        local myServerId = GetPlayerServerId(PlayerId())
        local camCoords  = GetGameplayCamCoord()

        Susano.BeginFrame()

        for _, player in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(player)
            if ped == 0 or not DoesEntityExist(ped) then goto skip end

            if ped == myPed and esp_ignore_self then goto skip end

            local serverId = GetPlayerServerId(player)
            if esp_friends and serverId == myServerId then goto skip end

            if not IsPedAPlayer(ped) and not esp_peds then goto skip end
            if not IsEntityVisible(ped) and not esp_invisible then goto skip end

            local coords = GetEntityCoords(ped)
            local dist   = #(coords - myCoords)
            if dist > 300.0 then goto skip end

            ----------------------------------------------------------------------
            -- PROJECTION 2D (HEAD / FEET)
            ----------------------------------------------------------------------
            local head  = GetPedBoneCoords(ped, 31086)
            local footL = GetPedBoneCoords(ped, 14201)
            local footR = GetPedBoneCoords(ped, 52301)

            local hOk, hx, hy   = W2S(head.x,  head.y,  head.z  + 0.18)
            local flOk, flx, fly = W2S(footL.x, footL.y, footL.z - 0.02)
            local frOk, frx, fry = W2S(footR.x, footR.y, footR.z - 0.02)

            if not (hOk and flOk and frOk) then goto skip end

            local fy     = math.max(fly, fry)
            local height = fy - hy
            if height <= 0 then goto skip end

            local rawLeft  = math.min(flx, frx)
            local rawRight = math.max(flx, frx)
            local rawWidth = rawRight - rawLeft

            local width   = rawWidth * 1.25
            local centerX = (flx + frx) / 2
            local left    = centerX - width / 2
            local right   = centerX + width / 2
            local centerY = (hy + fy) / 2

            ----------------------------------------------------------------------
            -- BOX (bounding box 3D → 2D, couvre tout le joueur)
            ----------------------------------------------------------------------
            if esp_box then
                  local model = GetEntityModel(ped)
                  local minDim, maxDim = GetModelDimensions(model)
                  local entityCoords = GetEntityCoords(ped)
                     
                     
                  local bbMin = vector3(entityCoords.x + minDim.x, entityCoords.y + minDim.y, entityCoords.z + minDim.z)
                  local bbMax = vector3(entityCoords.x + maxDim.x, entityCoords.y + maxDim.y, entityCoords.z + maxDim.z)

                  local ok1, x1, y1 = W2S(bbMin.x, bbMin.y, bbMin.z)
                  local ok2, x2, y2 = W2S(bbMax.x, bbMax.y, bbMax.z)
                  
                     
                  if ok1 and ok2 then
                        local bLeft   = math.min(x1, x2)
                        local bRight  = math.max(x1, x2)
                        local bTop    = math.min(y1, y2)
                        local bBottom = math.max(y1, y2)

                        local bWidth  = bRight - bLeft
                        local bHeight = bBottom - bTop

                        Susano.DrawRectFilled(bLeft, bTop, bWidth, bHeight, 0, 0, 0, 0.45, 0)

                        local t = 1.5
                        Susano.DrawRect(bLeft, bTop, bWidth, t, 1, 1, 1, 1, 1)
                        Susano.DrawRect(bLeft, bBottom - t, bWidth, t, 1, 1, 1, 1, 1)
                        Susano.DrawRect(bLeft, bTop, t, bHeight, 1, 1, 1, 1, 1)
                        Susano.DrawRect(bRight - t, bTop, t, bHeight, 1, 1, 1, 1, 1)

                       -- variables pour usage ultérieur si besoin
                       left    = bLeft
                       right   = bRight
                       hy      = bTop
                       fy      = bBottom
                       height  = bHeight
                       centerX = (bLeft + bRight) / 2
                       centerY = (bTop + bBottom) / 2
                       width   = bWidth
              end
     end


            ----------------------------------------------------------------------
            -- TRACERS
            ----------------------------------------------------------------------
            if esp_tracers then
                local ok1, mx, my = W2S(myCoords.x, myCoords.y, myCoords.z - 0.9)
                local ok2, tx, ty = W2S(coords.x,   coords.y,   coords.z   - 0.9)
                if ok1 and ok2 then
                    Susano.DrawLine(mx, my, tx, ty, 1, 1, 1, 1, 2)
                end
            end

            ----------------------------------------------------------------------
            -- SKELETON BLANC (bones GTA V propres)
            ----------------------------------------------------------------------
            if esp_skeleton then
                local bones = {
                    -- spine
                    {0, 11816}, {11816, 23553}, {23553, 24816}, {24816, 24817},{24817, 24818},{24818, 39317},{39317, 31086},

                    -- left arm
                    {39317, 45509}, {45509, 61163}, {45509, 61163}, {61163, 18905},

                    -- right arm
                    {39317, 40269}, {40269, 28252}, {28252, 57005},

                    -- left leg
                    {11816, 58271}, {58271, 63931}, {63931, 14201},

                    -- right leg
                    {11816, 51826}, {51826, 36864}, {36864, 52301}
                }

                local function offset(pos)
                    local dir = pos - camCoords
                    local len = #(dir)
                    if len > 0 then dir = dir / len end
                    return pos + dir * 0.03
                end

                for _, b in ipairs(bones) do
                    local p1 = offset(GetPedBoneCoords(ped, b[1]))
                    local p2 = offset(GetPedBoneCoords(ped, b[2]))

                    local ok1, x1, y1 = W2S(p1.x, p1.y, p1.z)
                    local ok2, x2, y2 = W2S(p2.x, p2.y, p2.z)

                    if ok1 and ok2 then
                        local dx = x1 - x2
                        local dy = y1 - y2
                        local d2 = dx*dx + dy*dy

                        if d2 < 50000 then
                            Susano.DrawLine(x1, y1, x2, y2, 1, 1, 1, 1, 2)
                        end
                    end
                end
            end

            ----------------------------------------------------------------------
            -- NAMETAG
            ----------------------------------------------------------------------
            if esp_nametag then
                  local head = GetPedBoneCoords(ped, 31086)

                   -- petit offset vertical au dessus de la tête
                  local ok, sx, sy = W2S(head.x, head.y, head.z + 0.55)

                  if ok then
                        local name = GetPlayerName(player)

                        -- largeur texte pour centrage parfait
                        local textW = Susano.GetTextWidth(name, 18)
 
                        Susano.DrawText(
                                 sx - textW / 2, -- CENTRAGE HORIZONTAL
                                 sy - 4,         -- léger offset vertical
                                 name,
                                 18,
                                 1, 1, 1, 1
                         )
                end
        end

            ----------------------------------------------------------------------
            -- DISTANCE
            ----------------------------------------------------------------------
            if esp_distance then
                Susano.DrawText(centerX, fy + 20, string.format("%.1f m", dist), 16, 0.8, 0.8, 0.8, 1)
            end

           ----------------------------------------------------------------------
           -- WEAPON (nom arme en bas centré SAFE FiveM)
           ----------------------------------------------------------------------
           if esp_weapon then
                 local weaponHash = GetSelectedPedWeapon(ped)

                -- fallback simple propre
                 local name = tostring(weaponHash)

                -- si dispo (certaines builds)
                 if GetWeaponDisplayNameFromHash then
                        local label = GetWeaponDisplayNameFromHash(weaponHash)
                        name = GetLabelText(label)
               end

               local size = 16
               local textW = Susano.GetTextWidth(name, size)

              Susano.DrawText(
                       centerX - textW / 2,
                       fy + 36,
                       name,
                       size,
                       1, 0.85, 0.45, 1
              )
     end


            ----------------------------------------------------------------------
            -- HEALTH BAR
            ----------------------------------------------------------------------
            if esp_health then
                  local hp    = GetEntityHealth(ped)
                  local maxHp = GetEntityMaxHealth(ped)

                  -- évite division par 0 + clamp
                  local pct = 0.0
                  if maxHp > 100 then
                         pct = (hp - 100) / (maxHp - 100)
                  end
                  if pct < 0.0 then pct = 0.0 end
                  if pct > 1.0 then pct = 1.0 end

                  -- mêmes bornes que la box (hy -> fy)
                  local barW = 4
                  local pad  = 2 -- espace entre la box et la barre (0 si tu veux collé collé)
                  local barX = left - barW - pad

                  -- fond (pile hauteur box)
                  Susano.DrawRectFilled(barX, hy, barW, height, 0, 0, 0, 0.7, 0)

                  -- remplissage: part du bas et monte
                  local fillH = height * pct
                  local fillY = fy - fillH

                  Susano.DrawRectFilled(barX, fillY, barW, fillH, 0, 1, 0, 1, 0)
         end

         ----------------------------------------------------------------------
         -- ARMOR BAR (même style que health, mais à droite)
         ----------------------------------------------------------------------
         if esp_armor then
               local armor = GetPedArmour(ped)

               local pct = armor / 100.0
               if pct < 0.0 then pct = 0.0 end
               if pct > 1.0 then pct = 1.0 end

               local barW = 4
               local pad  = 2 -- espace entre box et barre
               local barX = right + pad

               -- fond (pile même hauteur que la box)
              Susano.DrawRectFilled(barX, hy, barW, height, 0, 0, 0, 0.7, 0)

              -- remplissage depuis le bas (COMME HEALTH)
              local fillH = height * pct
              local fillY = fy - fillH

             Susano.DrawRectFilled(barX, fillY, barW, fillH, 0, 0.6, 1, 1, 0)
    end


            ::skip::
        end

        Susano.SubmitFrame()

        ::continue::
    end
end)

----------------------------------------------------------------------
-- THREAD : AFFICHAGE DU CERCLE FOV (VISUEL UNIQUEMENT)
----------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Affichage uniquement si le toggle est activé
        if not aimbotFOVEnabled then
            goto continue
        end

        -- Taille du cercle basée sur ton slider
        local radius = aimbotFOV * 0.0025

        -- Position écran (centre)
        local cx = 0.5
        local cy = 0.5

        -- Couleur or premium
        local r, g, b, a = 0.95, 0.80, 0.25, 0.95

        -- Cercle simulé avec des lignes (compatible toutes versions Susano)
        local segments = 90
        for i = 0, segments - 1 do
            local t1 = (i     / segments) * 2.0 * math.pi
            local t2 = ((i+1) / segments) * 2.0 * math.pi

            local x1 = cx + math.cos(t1) * radius
            local y1 = cy + math.sin(t1) * radius

            local x2 = cx + math.cos(t2) * radius
            local y2 = cy + math.sin(t2) * radius

            Susano.DrawLine(x1, y1, x2, y2, r, g, b, a)
        end

        ::continue::
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if carryVehicleEnabled then
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)

            -- Affichage au-dessus de la tête
            SetTextFont(0)
            SetTextScale(0.35, 0.35)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("~y~Y~s~ pour porter\n~o~O~s~ pour jeter")
            EndTextCommandDisplayText(0.5, 0.45)

            -- Touche Y → porter
            if IsControlJustPressed(0, 246) then -- Y
                if not carriedVehicle then
                    local forward = GetEntityForwardVector(ped)
                    local checkPos = pCoords + forward * 4.0

                    local veh = GetClosestVehicle(checkPos.x, checkPos.y, checkPos.z, 5.0, 0, 70)
                    if veh and veh ~= 0 then
                        carriedVehicle = veh

                        AttachEntityToEntity(
                            carriedVehicle,
                            ped,
                            GetPedBoneIndex(ped, 0x60F1),
                            0.0, 2.5, 0.0,
                            0.0, 0.0, 0.0,
                            false, false, true, false, 2, true
                        )

                        SetEntityCollision(carriedVehicle, false, false)
                    end
                end
            end

            -- Touche O → jeter
            if IsControlJustPressed(0, 79) then -- O
                if carriedVehicle then
                    local ped = PlayerPedId()
                    local forward = GetEntityForwardVector(ped)

                    DetachEntity(carriedVehicle, true, true)
                    SetEntityCollision(carriedVehicle, true, true)

                    -- FORCE DE LANCER
                    ApplyForceToEntity(
                        carriedVehicle,
                        1,                                  -- force type
                        forward.x * 80.0,                   -- force X
                        forward.y * 80.0,                   -- force Y
                        15.0,                               -- force Z
                        0.0, 0.0, 0.0,                      -- rotation force
                        0, false, true, true, false, true
                    )

                    carriedVehicle = nil
                end
            end
        end
    end
end)

-- Helper : convertir un Server ID -> Player (index FiveM)
local function ServerIdToPlayer(serverId)
    if not serverId then return nil end

    for _, p in ipairs(GetActivePlayers()) do
        if GetPlayerServerId(p) == serverId then
            return p
        end
    end

    return nil
end

-- Override / fix spectate (remplace l'ancien Susano.Spectate / StopSpectate)
actions.spectate_toggle = function()
    spectateEnabled = not spectateEnabled

    if spectateEnabled then
        if lastSelectedPlayer then
            local targetPlayer = ServerIdToPlayer(lastSelectedPlayer)
            if targetPlayer then
                local targetPed = GetPlayerPed(targetPlayer)
                if targetPed and targetPed ~= 0 and DoesEntityExist(targetPed) then
                    NetworkSetInSpectatorMode(true, targetPed)
                    print("^2✓ Spectate enabled on player " .. lastSelectedPlayer .. "^0")
                else
                    print("^1✗ Ped introuvable^0")
                    spectateEnabled = false
                end
            else
                print("^1✗ Joueur introuvable (server id)^0")
                spectateEnabled = false
            end
        else
            print("^1✗ Aucun joueur sélectionné^0")
            spectateEnabled = false
        end
    else
        -- Désactive spectate (le 2e param peut être n'importe quel ped valide)
        NetworkSetInSpectatorMode(false, PlayerPedId())
        print("^1✗ Spectate disabled^0")
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if tpToPlayerRequested then
            tpToPlayerRequested = false

            if lastSelectedPlayer then
                local targetPed = GetPlayerPed(GetPlayerFromServerId(lastSelectedPlayer))
                if targetPed and targetPed ~= 0 then
                    local coords = GetEntityCoords(targetPed)
                    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
                    print("^2✓ Téléporté au joueur "..lastSelectedPlayer.."^0")
                else
                    print("^1✗ Joueur introuvable^0")
                end
            else
                print("^1✗ Aucun joueur sélectionné^0")
            end
        end
    end
end)

function UpdateFreecam()
    if not freecamCam then return end

    DisableAllControlActions(0)

    local pos = GetCamCoord(freecamCam)
    local rot = GetCamRot(freecamCam, 2)
    local moveSpeed = freecamSpeed

    if IsControlPressed(0, 21) then moveSpeed = moveSpeed * 3 end

    local heading = math.rad(rot.z)
    local pitch = math.rad(rot.x)

    local dir = vector3(
        -math.sin(heading) * math.cos(pitch),
         math.cos(heading) * math.cos(pitch),
         math.sin(pitch)
    )

    local move = vector3(0,0,0)

    if IsControlPressed(0, 32) then move = move + dir * moveSpeed end
    if IsControlPressed(0, 33) then move = move - dir * moveSpeed end
    if IsControlPressed(0, 34) then move = move + vector3(-dir.y, dir.x, 0) * moveSpeed end
    if IsControlPressed(0, 35) then move = move + vector3(dir.y, -dir.x, 0) * moveSpeed end
    if IsControlPressed(0, 38) then move = move + vector3(0,0,moveSpeed) end
    if IsControlPressed(0, 44) then move = move - vector3(0,0,moveSpeed) end

    SetCamCoord(freecamCam, pos + move)

    local dx = GetControlNormal(0, 1) * -5.0
    local dy = GetControlNormal(0, 2) * -5.0

    local newX = math.max(-89.0, math.min(89.0, rot.x + dy))
    local newZ = rot.z + dx

    SetCamRot(freecamCam, vector3(newX, rot.y, newZ), 2)

    FreecamDrawCrosshair()

    -----------------------------------------
    -- FEATURES
    -----------------------------------------

    local camPos = GetCamCoord(freecamCam)
    local camRot = GetCamRot(freecamCam, 2)
    local pitch2 = math.rad(camRot.x)
    local heading2 = math.rad(camRot.z)
    local camDir = vector3(
        -math.sin(heading2) * math.cos(pitch2),
         math.cos(heading2) * math.cos(pitch2),
         math.sin(pitch2)
    )

    -- Car Delete
    if freecamFeatures[freecamFeature] == "Car Delete" then
        local veh, hit = FreecamGetVehicle(100.0)
        if veh then
            DrawLine(pos.x, pos.y, pos.z, hit.x, hit.y, hit.z, 255,0,0,255)
            if IsControlJustPressed(0, 24) then DeleteEntity(veh) end
        end
    end

    -- Physics Gun
    if freecamFeatures[freecamFeature] == "Physics Gun" then
        if freecamHeldVehicle then
            local holdPos = camPos + camDir * freecamHoldDistance
            SetEntityCoordsNoOffset(freecamHeldVehicle, holdPos.x, holdPos.y, holdPos.z, true, true, true)
            SetEntityVelocity(freecamHeldVehicle, 0,0,0)
            SetEntityCollision(freecamHeldVehicle, false, false)
            SetEntityAlpha(freecamHeldVehicle, 200, false)

            if IsControlJustPressed(0, 25) then
                SetEntityCollision(freecamHeldVehicle, true, true)
                SetEntityAlpha(freecamHeldVehicle, 255, false)
                ApplyForceToEntity(freecamHeldVehicle, 1, camDir.x*100, camDir.y*100, camDir.z*100, 0,0,0, 0, false,true,true,false,true)
                freecamHeldVehicle = nil
            end

            if IsControlJustPressed(0, 24) then
                SetEntityCollision(freecamHeldVehicle, true, true)
                SetEntityAlpha(freecamHeldVehicle, 255, false)
                freecamHeldVehicle = nil
            end
        else
            local veh, hit = FreecamGetVehicle(10.0)
            if veh and IsControlJustPressed(0, 24) then
                freecamHeldVehicle = veh
                SetEntityCollision(veh, false, false)
                SetEntityAlpha(veh, 200, false)
            end
        end
    end

    -- Car Spawn
    if freecamFeatures[freecamFeature] == "Car Spawn" and IsControlJustPressed(0, 24) then
        SpawnCarAtPos(camPos + camDir * 5.0)
    end

    -- Teleport
    if freecamFeatures[freecamFeature] == "Teleport" and IsControlJustPressed(0, 24) then
        TeleportPlayerToPos(camPos + camDir * 5.0)
    end

    -- Shoot Rockets
    if freecamFeatures[freecamFeature] == "Shoot Rockets" and IsControlJustPressed(0, 24) then
        ShootRocketFromCam()
    end

    -- Car Spam
    if freecamFeatures[freecamFeature] == "Car Spam" and IsControlJustPressed(0, 24) then
        SpamCarsAtPos(camPos + camDir * 5.0)
    end

    -- Scroll features
    local scroll = GetControlNormal(0, 14)
    if scroll > 0.5 then
        freecamFeature = freecamFeature % #freecamFeatures + 1
        Citizen.Wait(200)
    elseif scroll < -0.5 then
        freecamFeature = freecamFeature - 1
        if freecamFeature < 1 then freecamFeature = #freecamFeatures end
        Citizen.Wait(200)
    end

    DrawText2D(0.5, 0.95, "Feature: "..freecamFeatures[freecamFeature], 0.5, 255,255,255,255, 4, true)
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if freecamEnabled then
            UpdateFreecam()
        end
    end
end)



