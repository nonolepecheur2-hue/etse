-- ================================
-- REMOTE LOADER SUSANO
-- ================================
-- Ce fichier peut être très léger et charger le menu depuis un hébergement distant
-- Exemple d'utilisation de Susano.HttpGet (docs.susano.re)
--
-- local ClientLoaderURL = "https://ton-site/menu.lua"
-- local status, code = Susano.HttpGet(ClientLoaderURL)
-- if status == 200 and code then
--     local fn, err = load(code)
--     if fn then fn() else print(err) end
-- end
-- ================================

-- Menu vertical style Phaze avec Susano Draw API

-- === KEYBIND SETUP ===
local toggleKey = nil

Susano.EnableOverlay(true)

-- Attend que l'utilisateur appuie sur une touche
Citizen.CreateThread(function()
    while not toggleKey do
        Wait(0)
        Susano.DrawRectFilled(400, 300, 420, 90, 0.05, 0.05, 0.08, 0.95, 8)
        Susano.Text(420, 330, "Appuie sur une touche pour ouvrir / fermer le menu", 1,1,1,1)
        
        local key = Susano.GetPressedKey() -- API input Susano
        if key then
            toggleKey = key
        end
        Susano.SubmitFrame()
        ::continue::
    end
end)


local menu = {
    open = true,
    x = 200,
    y = 120,
    w = 300,
    h = 420,
    selected = 1,
    state = "main", -- main / submenu
    currentSub = nil,
    items = {
        "Player",
        "Server",
        "Weapon",
        "Combat",
        "Vehicle",
        "Visual",
        "Miscellaneous",
        "Settings",
        "Search"
    },
    submenus = {
        Player = {"Godmode", "Heal", "Teleport", "Back"},
        Server = {"Restart", "Weather", "Time", "Back"},
        Weapon = {"Give Weapon", "Infinite Ammo", "Back"}
    }
}
}

Citizen.CreateThread(function()
    while true do
        Wait(0)

        -- Toggle menu
        if toggleKey and Susano.IsKeyJustPressed(toggleKey) then
            menu.open = not menu.open
            Susano.EnableOverlay(menu.open)
        end

        if not menu.open then goto continue end
        Wait(0)

        -- === INPUT CLAVIER ===
        if IsControlJustPressed(0, 172) then -- ↑
            menu.selected = menu.selected - 1
            if menu.selected < 1 then
                local list = (menu.state == "main") and menu.items or menu.submenus[menu.currentSub]
                menu.selected = #list
            end
        end

        if IsControlJustPressed(0, 173) then -- ↓
            menu.selected = menu.selected + 1
            local list = (menu.state == "main") and menu.items or menu.submenus[menu.currentSub]
            if menu.selected > #list then menu.selected = 1 end
        end

        if IsControlJustPressed(0, 191) then -- ENTER
            if menu.state == "main" then
                local name = menu.items[menu.selected]
                if menu.submenus[name] then
                    menu.state = "submenu"
                    menu.currentSub = name
                    menu.selected = 1
                end
            else
                local choice = menu.submenus[menu.currentSub][menu.selected]
                if choice == "Back" then
                    menu.state = "main"
                    menu.currentSub = nil
                    menu.selected = 1
                end
            end
        end

        if IsControlJustPressed(0, 174) then -- ←
            if menu.state == "submenu" then
                menu.state = "main"
                menu.currentSub = nil
                menu.selected = 1
            end
        end

        if IsControlJustPressed(0, 177) then -- BACKSPACE
            menu.open = false
            Susano.EnableOverlay(false)
        end
        end

        if IsControlJustPressed(0, 173) then -- ↓
            menu.selected = menu.selected + 1
            if menu.selected > #menu.items then menu.selected = 1 end
        end

        if IsControlJustPressed(0, 191) then -- ENTER
            print("Selected menu: " .. menu.items[menu.selected])
        end

        if IsControlJustPressed(0, 177) then -- ← BACKSPACE
            menu.open = false
            Susano.EnableOverlay(false)
        end

        -- === DRAW MENU ===
        Susano.DrawRectFilled(menu.x, menu.y, menu.w, menu.h, 0.10, 0.12, 0.15, 0.95, 10)

        -- Header
        Susano.DrawRectFilled(menu.x, menu.y, menu.w, 60, 0.05, 0.07, 0.12, 1.0, 10)
        Susano.Text(menu.x + 20, menu.y + 20, "Phaze", 0.2, 0.6, 1.0, 1.0)

        -- Sous-titre
        Susano.Text(menu.x + 20, menu.y + 65, "Main menu", 0.8, 0.8, 0.8, 0.8)

        local startY = menu.y + 90
        local itemH = 34

        local drawList = (menu.state == "main") and menu.items or menu.submenus[menu.currentSub]

        for i, label in ipairs(drawList) do
            local iy = startY + (i - 1) * itemH

            if menu.selected == i then
                Susano.DrawRectFilled(menu.x, iy, menu.w, itemH, 0.15, 0.45, 0.85, 1.0, 4)
            end

            Susano.Text(menu.x + 20, iy + 8, label, 1, 1, 1, 1)

            if menu.state == "main" then
                Susano.Text(menu.x + menu.w - 20, iy + 8, ">", 0.7, 0.7, 0.7, 1)
            end
        end

            Susano.Text(menu.x + 20, iy + 8, label, 1, 1, 1, 1)
            Susano.Text(menu.x + menu.w - 20, iy + 8, ">", 0.7, 0.7, 0.7, 1)
        end

        Susano.SubmitFrame()
    end
end)
