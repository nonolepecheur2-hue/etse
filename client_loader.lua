

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
            {label = "Other", action = "category", target = "player_other"}
        }
    },

    player_health = {
        title = "Player - Health",
        items = {
            {label = "Godmode", action = "godmode"},
            {label = "Revive Player", action = "revive"},
            {label = "Heal Player", action = "heal"}
        }
    },

    player_movement = {
        title = "Player - Movement",
        items = {
            {label = "Noclip", action = "noclip"},
            {label = "Slide Run", action = "sliderun"},
            {label = "Super Jump", action = "superjump"},
            {label = "Infinite Stamina", action = "infinite_stamina"}

        }
    },

    player_other = {
        title = "Player - Other",
        items = {
            {label = "Throw From Vehicle", action = "throwvehicle"},
            {label = "Super Strength", action = "superstrength"},
            {label = "Explosive Melee", action = "explosive_melee"}
            
        }
    },

    serveur = {
        title = "Serveur",
        items = {
            {label = "player-list", action = "player-list"},
            {label = "Option Serveur 2", action = "none"}
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
    x = 70,
    y = 100,
    width = 380,
    height = 48,
    itemSpacing = 4,

    -- COULEURS VIP
    bgColor = {0.05, 0.05, 0.05, 0.90},        -- Fond sombre
    headerColor = {0.08, 0.08, 0.08, 1.0},     -- Bandeau noir
    selectedColor = {0.90, 0.75, 0.20, 0.95},  -- OR premium
    itemColor = {0.12, 0.12, 0.12, 0.85},      -- Fond item
    itemHoverColor = {0.18, 0.18, 0.18, 0.90}, -- Hover
    accentColor = {0.95, 0.80, 0.25, 1.0},     -- OR vif
    textColor = {1.0, 1.0, 1.0, 1.0},          -- Blanc pur
    textSecondary = {0.85, 0.85, 0.85, 0.9},   -- Gris clair
    separatorColor = {0.4, 0.4, 0.4, 0.5},
    footerColor = {0.08, 0.08, 0.08, 1.0},

    scrollbarBg = {0.10, 0.10, 0.10, 0.8},
    scrollbarThumb = {0.95, 0.80, 0.25, 0.95}, -- OR

    -- TAILLES
    titleSize = 22,
    subtitleSize = 16,
    itemSize = 18,
    infoSize = 14,
    footerSize = 14,
    bannerTitleSize = 32,
    bannerSubtitleSize = 18,

    -- DIMENSIONS
    headerHeight = 55,
    footerHeight = 36,

    -- ARRONDIS
    headerRounding = 6.0,
    itemRounding = 6.0,
    footerRounding = 6.0,
    bannerRounding = 6.0,
    globalRounding = 8.0,

    scrollbarWidth = 8,
    scrollbarPadding = 10
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

function DrawMenu()
    if not Menu.isOpen then return end
    Susano.BeginFrame()

    local category = categories[Menu.currentCategory]
    if not category then
        Menu.currentCategory = "main"
        category = categories["main"]
    end

    local x, y = Style.x, Style.y
    local width = Style.width
    local itemH = Style.height
    local spacing = Style.itemSpacing

    -- === COULEURS STYLE “VIP” ===
    local goldText      = {0.88, 0.74, 0.30, 0.95}
    local goldTextSoft  = {0.80, 0.66, 0.25, 0.90}
    local panelBg       = {0.02, 0.02, 0.02, 0.92}
    local headerBg      = {0.00, 0.00, 0.00, 0.92}
    local footerBg      = {0.00, 0.00, 0.00, 0.90}
    local borderGold    = {0.90, 0.75, 0.20, 0.95}

    -- Dégradé sélection
    local selTop        = {0.92, 0.80, 0.35, 0.95}
    local selBottom     = {0.55, 0.42, 0.12, 0.95}

    local currentY = y

    -- === BANNIÈRE ===
    if Banner.enabled then
        if bannerTexture and bannerTexture > 0 then
            Susano.DrawImage(bannerTexture, x, currentY, width, Banner.height, 1, 1, 1, 1, Style.bannerRounding)
        else
            Susano.DrawRectFilled(x, currentY, width, Banner.height, 0.05, 0.03, 0.01, 0.95, Style.bannerRounding)
            local titleWidth = Susano.GetTextWidth(Banner.text, Style.bannerTitleSize)
            Susano.DrawText(x + (width - titleWidth)/2, currentY + 28, Banner.text, Style.bannerTitleSize,
                borderGold[1], borderGold[2], borderGold[3], 1.0)
        end
        currentY = currentY + Banner.height
    end

    -- === “Main Menu” (barre noire sous bannière) ===
    local headerH = 44
    Susano.DrawRectFilled(x, currentY, width, headerH, headerBg[1], headerBg[2], headerBg[3], headerBg[4], 0.0)

    local sub = "Main Menu"
    local subW = Susano.GetTextWidth(sub, Style.subtitleSize)
    Susano.DrawText(x + (width - subW)/2, currentY + 12, sub, Style.subtitleSize,
        1.0, 1.0, 1.0, 0.90)

    currentY = currentY + headerH

    -- === ZONE ITEMS ===
    local startY = currentY
    local itemsCount = #category.items
    local itemsAreaH = itemsCount * (itemH + spacing) - spacing
    if itemsAreaH < 0 then itemsAreaH = 0 end

    -- Fond panneau + bordure or
    local panelH = itemsAreaH + 16
    local panelY = startY - 8

    -- Bordure extérieure
    Susano.DrawRectFilled(x - 2, panelY - 2, width + 4, panelH + 4,
        borderGold[1], borderGold[2], borderGold[3], 0.95, 0.0)

    -- Fond intérieur
    Susano.DrawRectFilled(x, panelY, width, panelH,
        panelBg[1], panelBg[2], panelBg[3], panelBg[4], 0.0)

        -- === ITEMS ===
    for i, item in ipairs(category.items) do
        local itemY = startY + ((i - 1) * (itemH + spacing))
        local isSelected = (i == Menu.selectedIndex)

        -- Fond item
        if isSelected then
            DrawVerticalGradient(x, itemY, width, itemH, selTop, selBottom, 0.0)
        else
            Susano.DrawRectFilled(x, itemY, width, itemH, 0, 0, 0, 0.10, 0.0)
        end

        -- Texte item
        local textX = x + 18
        Susano.DrawText(textX, itemY + 12, item.label, Style.itemSize,
            goldText[1], goldText[2], goldText[3], isSelected and 1.0 or 0.90)

        -- Flèche catégorie
        if item.action == "category" and item.target then
            Susano.DrawText(x + width - 22, itemY + 12, "›", Style.itemSize,
                goldTextSoft[1], goldTextSoft[2], goldTextSoft[3], 0.95)
        end

        -- Distance (player list)
        if item.distance then
            DrawTextRight(x + width - 50, itemY + 14, item.distance, Style.itemSize - 4,
                1, 1, 1, isSelected and 0.95 or 0.65)
        end

        ---------------------------------------------------------
        -- DÉTECTION SLIDER (Noclip, SlideRun, Aimbot FOV)
        ---------------------------------------------------------
        local sliderActions = {
            noclip = { var = function() return noclipSpeed end, min = 0.5, max = 10.0 },
            sliderun = { var = function() return sliderunSpeed end, min = 1.0, max = 20.0 },
            aimbot_fov = { var = function() return aimbotFOV end, min = 5.0, max = 120.0 }
        }

        local isSlider = sliderActions[item.action] ~= nil

        ---------------------------------------------------------
        -- DÉTECTION BOUTON (revive / heal)
        ---------------------------------------------------------
        local isButton = (item.action == "revive" or item.action == "heal")

        ---------------------------------------------------------
        -- AFFICHAGE SLIDER
        ---------------------------------------------------------
        if isSlider then
            local data = sliderActions[item.action]
            local currentValue = data.var()
            local minValue = data.min
            local maxValue = data.max

            local sliderWidth = 120
            local sliderHeight = 6
            local sliderX = x + width - sliderWidth - 60
            local sliderY = itemY + (itemH - sliderHeight) / 2

            local percent = (currentValue - minValue) / (maxValue - minValue)

            -- Fond slider
            Susano.DrawRectFilled(sliderX, sliderY, sliderWidth, sliderHeight,
                0.15, 0.15, 0.15, 0.85, 3.0)

            -- Barre remplie
            Susano.DrawRectFilled(sliderX, sliderY, sliderWidth * percent, sliderHeight,
                Style.accentColor[1], Style.accentColor[2], Style.accentColor[3], 1.0, 3.0)

            -- Thumb
            local thumbSize = 12
            local thumbX = sliderX + (sliderWidth * percent) - (thumbSize / 2)
            local thumbY = itemY + (itemH - thumbSize) / 2
            Susano.DrawRectFilled(thumbX, thumbY, thumbSize, thumbSize,
                1, 1, 1, 1, 6.0)

            -- Valeur affichée
            local valueText = string.format("%.0f", currentValue)
            DrawTextRight(x + width - 18, itemY + 12, valueText, Style.itemSize - 2,
                goldText[1], goldText[2], goldText[3], 0.95)
        end

        ---------------------------------------------------------
        -- AFFICHAGE TOGGLE (si pas slider)
        ---------------------------------------------------------
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
            aimbot_fov = aimbotFOVEnabled,


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
            esp_invisible = esp_invisible,
        }

      ---------------------------------------------------------
      -- AFFICHAGE TOGGLE (même si slider)
      ---------------------------------------------------------
      if not isButton and toggleStates[item.action] ~= nil then
            local toggleW, toggleH = 40, 18
            local toggleX = x + width - toggleW - 18
            local toggleY = itemY + (itemH - toggleH) / 2

            local isOn = toggleStates[item.action]

            if isOn then
                Susano.DrawRectFilled(toggleX, toggleY, toggleW, toggleH,
                         borderGold[1], borderGold[2], borderGold[3], 0.95, 9.0)
           else
                  Susano.DrawRectFilled(toggleX, toggleY, toggleW, toggleH,
                           0.2, 0.2, 0.2, 0.70, 9.0)
           end

           local thumb = 14
           local thumbX = isOn and (toggleX + toggleW - thumb - 2) or (toggleX + 2)
           local thumbY = toggleY + (toggleH - thumb) / 2

          Susano.DrawRectFilled(thumbX, thumbY, thumb, thumb,
                    1, 1, 1, 1, 7.0)
  end
       
end


    -- === Scrollbar à gauche (style or) ===
    if itemsCount > 0 then
        local scrollbarX = x - 14
        local scrollbarY = startY
        local scrollbarH = itemsCount * (itemH + spacing) - spacing

        -- Fond de la barre
        Susano.DrawRectFilled(scrollbarX, scrollbarY, 8, scrollbarH,
            0, 0, 0, 0.55, 4.0)

        local thumbH = math.max(24, scrollbarH / itemsCount)
        local thumbY = scrollbarY + ((Menu.selectedIndex - 1) /
            math.max(1, itemsCount - 1)) * (scrollbarH - thumbH)

        -- Curseur
        Susano.DrawRectFilled(scrollbarX + 1, thumbY, 6, thumbH,
            borderGold[1], borderGold[2], borderGold[3], 0.95, 4.0)
    end

    -- === Footer ===
    local footerY = panelY + panelH + 10
    Susano.DrawRectFilled(x - 2, footerY, width + 4, 40,
        footerBg[1], footerBg[2], footerBg[3], footerBg[4], 0.0)

    -- Texte footer
    Susano.DrawText(x + 12, footerY + 12, "Made By Nylox",
        Style.footerSize, 1, 1, 1, 0.85)

    -- Position item
    local posText = string.format("%d/%d", Menu.selectedIndex, itemsCount)
    DrawTextRight(x + width - 12, footerY + 12, posText,
        Style.footerSize, 1, 1, 1, 0.85)

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
            
            local _, enterPressed = Susano.GetAsyncKeyState(VK_RETURN)
            if enterPressed and not lastEnterPress then
                  local item = category.items[Menu.selectedIndex]

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
lastEnterPress = enterPressed

            
            DrawMenu()
        end


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
            local forward = { x = -math.sin(yaw) * math.cos(pitch), y =  math.cos(yaw) * math.cos(pitch), z = math.sin(pitch) }
            local right   = { x =  math.cos(yaw),                       y =  math.sin(yaw),                       z = 0.0 }

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

        if infiniteStaminaEnabled then
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) and not IsPedInAnyVehicle(ped, false) then
                RestorePlayerStamina(PlayerId(), 1.0)
            end
        end

        if superjumpEnabled then
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) then
                SetSuperJumpThisFrame(PlayerId())
            end
        end

        if explosiveMeleeEnabled then
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) and (IsPedArmed(ped, 1) or GetSelectedPedWeapon(ped) == `WEAPON_UNARMED`) then
                -- clic d'attaque (clic gauche / gâchette)
                if IsControlJustPressed(0, 24) then
                    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.2, 0.0)

                    AddExplosion(
                        coords.x, coords.y, coords.z,
                        1,      -- type explosion
                        1.0,    -- dégâts
                        true,   -- son
                        false,  -- invisible
                        1.0     -- camera shake
                    )
                end
            end
        end

        if sliderunEnabled then
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) and not IsPedInAnyVehicle(ped, false) then
                if IsPedRunning(ped) or IsPedSprinting(ped) then
                    local velocity = GetEntityVelocity(ped)
                    local heading = GetEntityHeading(ped)
                    local radians = math.rad(heading)
                    local forwardX = -math.sin(radians) * sliderunSpeed
                    local forwardY = math.cos(radians) * sliderunSpeed
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




