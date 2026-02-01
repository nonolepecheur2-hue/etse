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
            {label = "Super Jump", action = "superjump"}
        }
    },

    player_other = {
        title = "Player - Other",
        items = {
            {label = "Throw From Vehicle", action = "throwvehicle"},
            {label = "Super Strength", action = "superstrength"}
        }
    },

    serveur = {
        title = "Serveur",
        items = {
            {label = "Option Serveur 1", action = "none"},
            {label = "Option Serveur 2", action = "none"}
        }
    },

    combat = {
        title = "Combat",
        items = {
            {label = "Aimbot", action = "none"},
            {label = "Triggerbot", action = "none"}
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
            {label = "Outlines", action = "esp_outlines"},
            {label = "Skeleton", action = "esp_skeleton"},
            {label = "Chams", action = "esp_chams"},
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
local esp_outlines = false
local esp_skeleton = false
local esp_chams = false
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

    -- ESP actions
    esp_box = function() esp_box = not esp_box end,
    esp_outlines = function() esp_outlines = not esp_outlines end,
    esp_skeleton = function() esp_skeleton = not esp_skeleton end,
    esp_chams = function() esp_chams = not esp_chams end,
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


function DrawMenu()
    if not Menu.isOpen then return end
    
    Susano.BeginFrame()
    
    local category = categories[Menu.currentCategory]
    if not category then
        Menu.currentCategory = "main"
        category = categories["main"]
    end
    
    local x, y = Style.x, Style.y
    local width, height = Style.width, Style.height
    local spacing = Style.itemSpacing
    
    local currentY = y
    
  if Banner.enabled then
        if bannerTexture and bannerTexture > 0 then
            Susano.DrawImage(bannerTexture, x, currentY, width, Banner.height, 1, 1, 1, 1, Style.bannerRounding)
        else
            Susano.DrawRectFilled(x, currentY, width, Banner.height, 
                0.08, 0.08, 0.15, 0.95, Style.bannerRounding)
            
            Susano.DrawRectFilled(x, currentY, width, Banner.height / 2, 
                0.15, 0.2, 0.35, 0.4, Style.bannerRounding)
            
            local titleWidth = Susano.GetTextWidth(Banner.text, Style.bannerTitleSize)
            Susano.DrawText(x + (width - titleWidth) / 2, currentY + 30, 
                Banner.text, Style.bannerTitleSize, 
                Style.accentColor[1], Style.accentColor[2], Style.accentColor[3], 1.0)
            
            local subWidth = Susano.GetTextWidth(Banner.subtitle, Style.bannerSubtitleSize)
            Susano.DrawText(x + (width - subWidth) / 2, currentY + 65, 
                Banner.subtitle, Style.bannerSubtitleSize, 
                Style.textSecondary[1], Style.textSecondary[2], Style.textSecondary[3], 0.9)
        end
        
        currentY = currentY + Banner.height
    end
    
    Susano.DrawRectFilled(x, currentY, width, Style.headerHeight,
        Style.headerColor[1], Style.headerColor[2], Style.headerColor[3], Style.headerColor[4], 
        Style.headerRounding)
    
    local titleText = category.title:upper()
    Susano.DrawText(x + 15, currentY + 14, 
        titleText, Style.titleSize, 
        Style.textColor[1], Style.textColor[2], Style.textColor[3], 1.0)
    Susano.DrawText(x + 15.3, currentY + 14, 
        titleText, Style.titleSize, 
        Style.textColor[1], Style.textColor[2], Style.textColor[3], 0.8)
    
    local versionText = "v1.0"
    local versionWidth = Susano.GetTextWidth(versionText, Style.footerSize)
    Susano.DrawText(x + width - versionWidth - 15, currentY + 17, 
        versionText, Style.footerSize, 
        Style.textSecondary[1], Style.textSecondary[2], Style.textSecondary[3], 0.8)
    
    currentY = currentY + Style.headerHeight
    
    local startY = currentY
    for i, item in ipairs(category.items) do
        local itemY = startY + ((i - 1) * (height + spacing))
        local isSelected = (i == Menu.selectedIndex)
        
        if isSelected then
            Susano.DrawRectFilled(x, itemY, width, height, 
                Style.selectedColor[1], Style.selectedColor[2], Style.selectedColor[3], Style.selectedColor[4], 
                Style.itemRounding)
        else
            Susano.DrawRectFilled(x, itemY, width, height, 
                Style.itemColor[1], Style.itemColor[2], Style.itemColor[3], Style.itemColor[4], 
                Style.itemRounding)
        end
        
        local textX = x + 15
        Susano.DrawText(textX, itemY + 12, 
            item.label, Style.itemSize, 
            Style.textColor[1], Style.textColor[2], Style.textColor[3], 1.0)
        Susano.DrawText(textX + 0.3, itemY + 12, 
            item.label, Style.itemSize, 
            Style.textColor[1], Style.textColor[2], Style.textColor[3], 0.7)
        
        if item.action == "category" and item.target then
            local arrowX = x + width - 20
            Susano.DrawText(arrowX, itemY + 12, ">", Style.itemSize, 
                Style.textColor[1], Style.textColor[2], Style.textColor[3], 1.0)
        else
            local toggleStates = {
    godmode = godmodeEnabled,
    noclip = noclipEnabled,
    sliderun = sliderunEnabled,
    superjump = superjumpEnabled,
    throwvehicle = throwvehicleEnabled,
    superstrength = superstrengthEnabled,

    -- ESP toggles
    esp_box = esp_box,
    esp_outlines = esp_outlines,
    esp_skeleton = esp_skeleton,
    esp_chams = esp_chams,
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

        
        local sliderActions = {"noclip", "sliderun"}
        local isSlider = false
        for _, sliderAction in ipairs(sliderActions) do
            if item.action == sliderAction then
                isSlider = true
                break
            end
        end
        
        local buttonActions = {"revive", "heal"}
        local isButton = false
        for _, btnAction in ipairs(buttonActions) do
            if item.action == btnAction then
                isButton = true
                break
            end
        end
        
        if isSlider then
            local sliderWidth = 100
            local sliderHeight = 6
            local sliderX = x + width - sliderWidth - 80
            local sliderY = itemY + (height - sliderHeight) / 2
            
            local currentValue, minValue, maxValue
            if item.action == "noclip" then
                currentValue = noclipSpeed
                minValue = 0.5
                maxValue = 10.0
            elseif item.action == "sliderun" then
                currentValue = sliderunSpeed
                minValue = 1.0
                maxValue = 20.0
            end
            
            local percent = (currentValue - minValue) / (maxValue - minValue)
            
            Susano.DrawRectFilled(sliderX, sliderY, sliderWidth, sliderHeight, 
                0.2, 0.2, 0.2, 0.7, 3.0)
            
            Susano.DrawRectFilled(sliderX, sliderY, sliderWidth * percent, sliderHeight, 
                Style.accentColor[1], Style.accentColor[2], Style.accentColor[3], 1.0, 3.0)
            
            local thumbSize = 12
            local thumbX = sliderX + (sliderWidth * percent) - (thumbSize / 2)
            local thumbY = itemY + (height - thumbSize) / 2
            Susano.DrawRectFilled(thumbX, thumbY, thumbSize, thumbSize, 
                1.0, 1.0, 1.0, 1.0, 6.0)
            
            local valueText = string.format("%.0f", currentValue)
            local valuePadding = 5
            Susano.DrawText(sliderX + sliderWidth + valuePadding, itemY + 15, valueText, Style.itemSize - 4, 
                Style.textSecondary[1], Style.textSecondary[2], Style.textSecondary[3], 0.8)
                
        end
        
        if not isButton and toggleStates[item.action] ~= nil then
            local toggleWidth = 40
            local toggleHeight = 20
            local toggleX = x + width - toggleWidth - 20
            local toggleY = itemY + (height - toggleHeight) / 2
            local toggleRounding = 10.0
            
            local isOn = toggleStates[item.action]
            
            if isOn then
                Susano.DrawRectFilled(toggleX, toggleY, toggleWidth, toggleHeight, 
                    Style.accentColor[1], Style.accentColor[2], Style.accentColor[3], 0.9, toggleRounding)
            else
                Susano.DrawRectFilled(toggleX, toggleY, toggleWidth, toggleHeight, 
                    0.3, 0.3, 0.3, 0.6, toggleRounding)
            end
            
            local thumbSize = 16
            local thumbY = toggleY + (toggleHeight - thumbSize) / 2
            local thumbX
            if isOn then
                thumbX = toggleX + toggleWidth - thumbSize - 2
            else
                thumbX = toggleX + 2
            end
            
            Susano.DrawRectFilled(thumbX, thumbY, thumbSize, thumbSize, 
                1.0, 1.0, 1.0, 1.0, 8.0)
            end
        end
    end
    
    if #category.items > 0 then
        local itemsAreaHeight = #category.items * (height + spacing)
        local scrollbarX = x - Style.scrollbarWidth - 10
        local scrollbarY = startY
        local scrollbarHeight = itemsAreaHeight
        
        Susano.DrawRectFilled(scrollbarX, scrollbarY, Style.scrollbarWidth, scrollbarHeight,
            Style.scrollbarBg[1], Style.scrollbarBg[2], Style.scrollbarBg[3], Style.scrollbarBg[4],
            Style.scrollbarWidth / 2)
        
        local thumbHeight = math.max(20, scrollbarHeight / #category.items)
        local thumbY = scrollbarY + ((Menu.selectedIndex - 1) / math.max(1, #category.items - 1)) * (scrollbarHeight - thumbHeight)
        
        if not Menu.scrollbarCurrentY then
            Menu.scrollbarCurrentY = thumbY
        end
        local smoothSpeed = 0.3
        Menu.scrollbarCurrentY = Menu.scrollbarCurrentY + (thumbY - Menu.scrollbarCurrentY) * smoothSpeed
        
        Susano.DrawRectFilled(scrollbarX, Menu.scrollbarCurrentY, Style.scrollbarWidth, thumbHeight,
            Style.scrollbarThumb[1], Style.scrollbarThumb[2], Style.scrollbarThumb[3], Style.scrollbarThumb[4],
            Style.scrollbarWidth / 2)
    end
    
    local footerY = startY + (#category.items * (height + spacing)) + 8
    Susano.DrawRectFilled(x, footerY, width, Style.footerHeight, 
        Style.footerColor[1], Style.footerColor[2], Style.footerColor[3], Style.footerColor[4], 
        Style.footerRounding)
    
    local footerText = "susanomenu.xyz | v1.0"
    Susano.DrawText(x + 15, footerY + 10, 
        footerText, Style.footerSize, 
        Style.textSecondary[1], Style.textSecondary[2], Style.textSecondary[3], 0.7)
    
    local posText = string.format("%d/%d", Menu.selectedIndex, #category.items)
    local posWidth = Susano.GetTextWidth(posText, Style.footerSize)
    Susano.DrawText(x + width - posWidth - 15, footerY + 10, 
        posText, Style.footerSize, 
        Style.textSecondary[1], Style.textSecondary[2], Style.textSecondary[3], 0.7)
    
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
                if item then
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
        
        if superjumpEnabled then
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) then
                SetSuperJumpThisFrame(PlayerId())
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

Citizen.CreateThread(function()
    if Banner.enabled and Banner.imagePath then
        local texId, w, h = Susano.LoadTexture(Banner.imagePath)
        if texId and texId > 0 then
            bannerTexture = texId
            bannerWidth = w
            bannerHeight = h
            print("^2✓ Banner loaded: " .. Banner.imagePath .. "^0")
        else
            print("^1✗ Unable to load banner^0")
        end
    end
end)

Citizen.CreateThread(function()
    Wait(1000)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if not (
            esp_box or esp_outlines or esp_skeleton or esp_tracers or
            esp_health or esp_armor or esp_nametag or esp_distance or
            esp_weapon or esp_friends or esp_peds or esp_invisible
        ) then
            goto continue
        end

        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)
        local myServerId = GetPlayerServerId(PlayerId())

        for _, player in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(player)
            if ped == 0 or not DoesEntityExist(ped) then goto skip end

            -- Ignore self
            if ped == myPed and esp_ignore_self then goto skip end

            -- Friends (si activé, on skip les potes)
            local serverId = GetPlayerServerId(player)
            if esp_friends and serverId == myServerId then goto skip end

            -- Peds / invisibles
            if not IsPedAPlayer(ped) and not esp_peds then goto skip end
            if not IsEntityVisible(ped) and not esp_invisible then goto skip end

            local coords = GetEntityCoords(ped)
            local dist = #(coords - myCoords)
            if dist > 300.0 then goto skip end

            ----------------------------------------------------------------------
            -- PROJECTION 2D : TÊTE + PIED GAUCHE + PIED DROIT
            ----------------------------------------------------------------------
            local head = GetPedBoneCoords(ped, 31086)
            local footL = GetPedBoneCoords(ped, 14201)   -- pied gauche
            local footR = GetPedBoneCoords(ped, 52301)   -- pied droit

            local hOk, hx, hy = World3dToScreen2d(head.x, head.y, head.z + 0.15)
            local flOk, flx, fly = World3dToScreen2d(footL.x, footL.y, footL.z - 0.02)
            local frOk, frx, fry = World3dToScreen2d(footR.x, footR.y, footR.z - 0.02)

            if not (hOk and flOk and frOk) then goto skip end

            local fy = math.max(fly, fry)
            local height = fy - hy
            if height <= 0 then goto skip end

            local left = math.min(flx, frx)
            local right = math.max(flx, frx)
            local width = right - left
            local centerX = (left + right) / 2
            local centerY = (hy + fy) / 2

            ----------------------------------------------------------------------
            -- BOX (RECTANGLE 2D PROPRE)
            ----------------------------------------------------------------------
            if esp_box then
                -- Fond léger
                DrawRect(centerX, centerY, width, height, 0, 0, 0, 120)

                -- Bordures fines
                DrawRect(centerX, hy, width, 0.0015, 255, 255, 255, 255) -- top
                DrawRect(centerX, fy, width, 0.0015, 255, 255, 255, 255) -- bottom
                DrawRect(left, centerY, 0.0015, height, 255, 255, 255, 255) -- left
                DrawRect(right, centerY, 0.0015, height, 255, 255, 255, 255) -- right
            end

            ----------------------------------------------------------------------
            -- OUTLINES (CONTOUR RENFORCÉ)
            ----------------------------------------------------------------------
            if esp_outlines then
                DrawRect(centerX, hy, width, 0.0025, 0, 0, 0, 255)
                DrawRect(centerX, fy, width, 0.0025, 0, 0, 0, 255)
                DrawRect(left, centerY, 0.0025, height, 0, 0, 0, 255)
                DrawRect(right, centerY, 0.0025, height, 0, 0, 0, 255)
            end

            ----------------------------------------------------------------------
            -- TRACERS (3D)
            ----------------------------------------------------------------------
            if esp_tracers then
                DrawLine(
                    myCoords.x, myCoords.y, myCoords.z - 0.9,
                    coords.x, coords.y, coords.z - 0.9,
                    255, 255, 255, 255
                )
            end

            ----------------------------------------------------------------------
            -- SKELETON (ALIGNÉ, LISIBLE)
            ----------------------------------------------------------------------
            if esp_skeleton then
                local bones = {
                    -- Head / Neck / Spine
                    {31086, 39317},   -- head → neck
                    {39317, 24816},   -- neck → upper spine
                    {24816, 24817},   -- upper spine → mid spine
                    {24817, 0},       -- mid spine → pelvis

                    -- Left arm
                    {39317, 18905},   -- neck → left clavicle
                    {18905, 57005},   -- clavicle → left hand

                    -- Right arm
                    {39317, 28252},   -- neck → right clavicle
                    {28252, 61163},   -- clavicle → right hand

                    -- Left leg
                    {0, 14201},       -- pelvis → left thigh
                    {14201, 65245},   -- thigh → left calf
                    {65245, 55120},   -- calf → left foot

                    -- Right leg
                    {0, 51826},       -- pelvis → right thigh
                    {51826, 36864},   -- thigh → right calf
                    {36864, 52301},   -- calf → right foot
                }

                for _, b in ipairs(bones) do
                    local p1 = GetPedBoneCoords(ped, b[1])
                    local p2 = GetPedBoneCoords(ped, b[2])
                    DrawLine(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, 0, 255, 0, 255)
                end
            end

            ----------------------------------------------------------------------
            -- NAMETAG (PETIT, PROPRE, CENTRÉ)
            ----------------------------------------------------------------------
            if esp_nametag then
                SetTextFont(0)
                SetTextScale(0.22, 0.22)
                SetTextColour(255, 255, 255, 255)
                SetTextCentre(true)
                SetTextOutline()
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(GetPlayerName(player))
                EndTextCommandDisplayText(centerX, hy - 0.015)
            end

            ----------------------------------------------------------------------
            -- DISTANCE
            ----------------------------------------------------------------------
            if esp_distance then
                SetTextFont(0)
                SetTextScale(0.20, 0.20)
                SetTextColour(200, 200, 200, 255)
                SetTextCentre(true)
                SetTextOutline()
                BeginTextCommandDisplayText("STRING")
                AddTextComponentString(string.format("%.1f m", dist))
                EndTextCommandDisplayText(centerX, fy + 0.02)
            end

            ----------------------------------------------------------------------
            -- WEAPON (SIMPLE HASH POUR L’INSTANT)
            ----------------------------------------------------------------------
            if esp_weapon then
                local weapon = GetSelectedPedWeapon(ped)
                SetTextFont(0)
                SetTextScale(0.20, 0.20)
                SetTextColour(255, 200, 100, 255)
                SetTextCentre(true)
                SetTextOutline()
                BeginTextCommandDisplayText("STRING")
                AddTextComponentString(tostring(weapon))
                EndTextCommandDisplayText(centerX, hy - 0.035)
            end

            ----------------------------------------------------------------------
            -- HEALTH BAR (COLLÉE À GAUCHE)
            ----------------------------------------------------------------------
            if esp_health then
                local hp = GetEntityHealth(ped)
                local maxHp = GetEntityMaxHealth(ped)
                local pct = math.max(0.0, math.min(1.0, (hp - 100) / (maxHp - 100)))

                local barH = height
                local barW = 0.0035

                DrawRect(left - 0.010, centerY, barW, barH, 0, 0, 0, 180)

                local fillH = barH * pct
                local centerYFill = fy - fillH / 2

                local r, g = 0, 255
                if pct < 0.5 then
                    r = 255
                    g = 255 * (pct * 2)
                else
                    r = 255 * (2 - pct * 2)
                    g = 255
                end

                DrawRect(left - 0.010, centerYFill, barW, fillH, r, g, 0, 255)
            end

            ----------------------------------------------------------------------
            -- ARMOR BAR (COLLÉE À DROITE)
            ----------------------------------------------------------------------
            if esp_armor then
                local armor = GetPedArmour(ped)
                local pct = math.max(0.0, math.min(1.0, armor / 100.0))

                local barH = height
                local barW = 0.0035

                DrawRect(right + 0.010, centerY, barW, barH, 0, 0, 0, 180)

                local fillH = barH * pct
                local centerYFill = fy - fillH / 2

                DrawRect(right + 0.010, centerYFill, barW, fillH, 0, 150, 255, 255)
            end

            ::skip::
        end

        ::continue::
    end
end)
