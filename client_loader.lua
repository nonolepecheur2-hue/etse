-- ============================================================
--   ATTENTE DE L'API SUSANO (ÉVITE LE NIL)
-- ============================================================

while not Susano do
    print("[Menu] En attente de Susano...")
    os.sleep(0.1)
end

print("[Menu] Susano chargé.")


-- ============================================================
--   KEYBIND MANAGER
-- ============================================================

local Keybinds = {
    openMenu = "TAB",
    back = "DELETE",
    up = "UP",
    down = "DOWN",
}

local waitingForBind = nil

Susano.OnKeyAny(function(key)
    if waitingForBind then
        Keybinds[waitingForBind] = key
        print("[Bind] Changement :", waitingForBind, "→", key)
        waitingForBind = nil
    end
end)


-- ============================================================
--   MENU SYSTEM
-- ============================================================

local menu = {
    open = false,
    index = 1,
    items = {
        "Player",
        "Server",
        "Weapon",
        "Combat",
        "Vehicle",
        "Visual",
        "Miscellaneous",
        "Settings",
        "Search",
        "Keybinds",
        "Load Client"
    }
}

local cfg = {
    width = 420,
    itemHeight = 32,
    padding = 18,
    bgColor = Color(18,18,22,230),
    accent = Color(0,140,255,255),
    textColor = Color(230,230,230,255),
    hoverColor = Color(0,140,255,40),
    borderColor = Color(0,140,255,180),
    title = "Phaze",
}


-- ============================================================
--   INPUT HANDLING
-- ============================================================

Susano.OnKey(function()
    return Keybinds.openMenu
end, function()
    if not waitingForBind then
        menu.open = not menu.open
    end
end)

Susano.OnKey(function()
    return Keybinds.up
end, function()
    if menu.open and not waitingForBind then
        menu.index = menu.index - 1
        if menu.index < 1 then menu.index = #menu.items end
    end
end)

Susano.OnKey(function()
    return Keybinds.down
end, function()
    if menu.open and not waitingForBind then
        menu.index = menu.index + 1
        if menu.index > #menu.items then menu.index = 1 end
    end
end)

Susano.OnKey(function()
    return Keybinds.back
end, function()
    if menu.open and not waitingForBind then
        print("[Menu] Retour")
    end
end)


-- ============================================================
--   LOADER GITHUB
-- ============================================================

local function LoadClient()
    local url = "https://raw.githubusercontent.com/nonolepecheur2-hue/etse/refs/heads/main/client_loader.lua"
    local status, code = Susano.HttpGet(url)

    if status ~= 200 or not code or #code < 5 then
        print("[Loader] Erreur HTTP :", status)
        return
    end

    local ok, err = pcall(function()
        load(code)()
    end)

    if not ok then
        print("[Loader] Erreur d'exécution :", err)
    else
        print("[Loader] Client chargé ✓")
    end
end


-- ============================================================
--   DRAW
-- ============================================================

Susano.OnDraw(function()
    if not menu.open then return end

    local sw, sh = Susano.GetScreenSize()
    local x = (sw - cfg.width) / 2
    local y = (sh - (#menu.items * cfg.itemHeight + 90)) / 2

    -- Fond
    Susano.DrawRectFilled(x, y, cfg.width, (#menu.items * cfg.itemHeight) + 90, cfg.bgColor)
    Susano.DrawRect(x, y, cfg.width, (#menu.items * cfg.itemHeight) + 90, cfg.borderColor)

    -- Titre
    Susano.DrawTextCentered(cfg.title, x + cfg.width/2, y + 30, cfg.accent, 22, true)
    Susano.DrawRectFilled(x + 40, y + 55, cfg.width - 80, 2, cfg.accent)

    -- Items
    local startY = y + 80
    for i, item in ipairs(menu.items) do
        local iy = startY + (i-1) * cfg.itemHeight

        if i == menu.index then
            Susano.DrawRectFilled(x + 10, iy, cfg.width - 20, cfg.itemHeight, cfg.hoverColor)
            Susano.DrawText(item, x + 30, iy + 8, cfg.accent, 18, false)
        else
            Susano.DrawText(item, x + 30, iy + 8, cfg.textColor, 18, false)
        end

        Susano.DrawText(">", x + cfg.width - 40, iy + 8, cfg.textColor, 18, false)
    end


    -- ============================================================
    --   KEYBIND CONFIG SCREEN
    -- ============================================================

    if menu.items[menu.index] == "Keybinds" then
        local bx = x + cfg.width + 20
        local by = y

        Susano.DrawRectFilled(bx, by, 300, 200, cfg.bgColor)
        Susano.DrawRect(bx, by, 300, 200, cfg.borderColor)

        Susano.DrawText("Changer un bind :", bx + 20, by + 20, cfg.accent, 20, false)

        local offset = 60
        for name, key in pairs(Keybinds) do
            local text = name .. " : " .. key
            Susano.DrawText(text, bx + 20, by + offset, cfg.textColor, 18, false)
            offset = offset + 30
        end

        if waitingForBind then
            Susano.DrawText("Appuyez sur une touche...", bx + 20, by + 160, cfg.accent, 18, false)
        end
    end


    -- ============================================================
    --   LOAD CLIENT ACTION
    -- ============================================================

    if menu.items[menu.index] == "Load Client" then
        LoadClient()
    end
end)
