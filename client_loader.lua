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
    imagePath = "",
    text = "SUSANO MENU",
    subtitle = "Premium Edition",
    height = 100
}

local bannerTexture = nil
local bannerWidth = 0
local bannerHeight = 0

local Style = {
    x = 70,
    y = 100,
    width = 350,
    height = 42,
    itemSpacing = 0,
    
    bgColor = {0.12, 0.12, 0.12, 0.75},
    headerColor = {0.0, 0.0, 0.0, 1.0},
    selectedColor = {0.55, 0.0, 0.0, 0.95},
    itemColor = {0.18, 0.18, 0.18, 0.7},
    itemHoverColor = {0.22, 0.22, 0.22, 0.75},
    accentColor = {0.65, 0.0, 0.0, 1.0},
    textColor = {1.0, 1.0, 1.0, 1.0},
    textSecondary = {0.7, 0.7, 0.7, 1.0},
    separatorColor = {0.3, 0.3, 0.3, 0.6},
    footerColor = {0.0, 0.0, 0.0, 1.0},
    scrollbarBg = {0.15, 0.15, 0.15, 0.8},
    scrollbarThumb = {0.65, 0.0, 0.0, 0.95},
    
    titleSize = 18,
    subtitleSize = 15,
    itemSize = 16,
    infoSize = 13,
    footerSize = 13,
    bannerTitleSize = 28,
    bannerSubtitleSize = 16,
    
    headerHeight = 45,
    footerHeight = 32,
    
    headerRounding = 0.0,
    itemRounding = 0.0,
    footerRounding = 8.0,
    bannerRounding = 0.0,
    globalRounding = 8.0,
    
    scrollbarWidth = 6,
    scrollbarPadding = 8
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

        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)
        local players = GetActivePlayers()

        for _, player in ipairs(players) do
            local ped = GetPlayerPed(player)

            -- Ignore si ped invalide
            if ped ~= 0 and DoesEntityExist(ped) then

                -- Ignore soi-même si esp_ignore_self est true
                if ped ~= myPed or esp_ignore_self == false then

                    local coords = GetEntityCoords(ped)
                    local dist = #(coords - myCoords)

                    -- Ignore au-delà de 200m
                    if dist <= 200.0 then

                        -- BOX ESP (blanc)
                        if esp_box then
                            DrawMarker(
                                0,
                                coords.x, coords.y, coords.z + 1.0,
                                0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0,
                                0.3, 0.3, 1.8,
                                255, 255, 255, 150,
                                false, true, 2, false, nil, nil, false
                            )
                        end

                        -- SKELETON ESP (simple, blanc)
                        if esp_skeleton then
                            local head = GetPedBoneCoords(ped, 0x796E)
                            local spine = GetPedBoneCoords(ped, 0x60F1)
                            DrawLine(
                                head.x, head.y, head.z,
                                spine.x, spine.y, spine.z,
                                255, 255, 255, 255
                            )
                        end

                        -- TRACERS (blanc)
                        if esp_tracers then
                            DrawLine(
                                myCoords.x, myCoords.y, myCoords.z,
                                coords.x, coords.y, coords.z,
                                255, 255, 255, 255
                            )
                        end

                        -- NAMETAG (blanc)
                        if esp_nametag then
                            local name = GetPlayerName(player)
                            SetDrawOrigin(coords.x, coords.y, coords.z + 1.0, 0)
                            SetTextFont(0)
                            SetTextScale(0.3, 0.3)
                            SetTextColour(255, 255, 255, 255)
                            SetTextCentre(true)
                            BeginTextCommandDisplayText("STRING")
                            AddTextComponentSubstringPlayerName(name)
                            EndTextCommandDisplayText(0.0, 0.0)
                            ClearDrawOrigin()
                        end

                        -- HEALTH BAR
                        if esp_health_bar then
                            local maxHealth = GetEntityMaxHealth(ped)
                            local currentHealth = GetEntityHealth(ped)
                            local healthPercent = (currentHealth - 100) / (maxHealth - 100)
                            healthPercent = math.max(0, math.min(1, healthPercent))

                            SetDrawOrigin(coords.x, coords.y, coords.z + 1.2, 0)
                            
                            -- Background bar (dark)
                            DrawRect(0.0, 0.0, 0.08, 0.015, 0, 0, 0, 200)
                            
                            -- Health bar (red to green)
                            local r = healthPercent < 0.5 and 255 or (255 - healthPercent * 510)
                            local g = healthPercent > 0.5 and 255 or (healthPercent * 510)
                            DrawRect(-0.04 + (healthPercent * 0.04), 0.0, healthPercent * 0.08, 0.015, r, g, 0, 255)
                            
                            ClearDrawOrigin()
                        end

                        -- ARMOR BAR
                        if esp_armor_bar then
                            local armor = GetPedArmour(ped)
                            local armorPercent = armor / 100.0
                            armorPercent = math.max(0, math.min(1, armorPercent))

                            SetDrawOrigin(coords.x, coords.y, coords.z + 1.05, 0)
                            
                            -- Background bar (dark)
                            DrawRect(0.0, 0.0, 0.08, 0.015, 0, 0, 0, 200)
                            
                            -- Armor bar (blue)
                            DrawRect(-0.04 + (armorPercent * 0.04), 0.0, armorPercent * 0.08, 0.015, 0, 150, 255, 255)
                            
                            ClearDrawOrigin()
                        end

                        -- DISTANCE (blanc, max 200m)
                        if esp_distance then
                            local displayDist = dist
                            if displayDist > 200.0 then displayDist = 200.0 end

                            SetDrawOrigin(coords.x, coords.y, coords.z + 0.8, 0)
                            SetTextFont(0)
                            SetTextScale(0.3, 0.3)
                            SetTextColour(255, 255, 255, 255)
                            SetTextCentre(true)
                            BeginTextCommandDisplayText("STRING")
                            AddTextComponentString(string.format("%.1f m", displayDist))
                            EndTextCommandDisplayText(0.0, 0.0)
                            ClearDrawOrigin()
                        end

                    end
                end
            end
        end
    end
end)

