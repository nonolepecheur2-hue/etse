-- ============================
--   KEYBIND MANAGER
-- ============================

local Keybinds = {
    openMenu = "TAB",
    back = "DELETE",
    up = "UP",
    down = "DOWN",
}

local waitingForBind = nil

susano.on_key_any(function(key)
    if waitingForBind then
        Keybinds[waitingForBind] = key
        print("Bind changé :", waitingForBind, "→", key)
        waitingForBind = nil
    end
end)

-- ============================
--   MENU SYSTEM
-- ============================

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
        "Keybinds"
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

-- ============================
--   INPUT HANDLING
-- ============================

susano.on_key(Keybinds.openMenu, function()
    if not waitingForBind then
        menu.open = not menu.open
    end
end)

susano.on_key(Keybinds.up, function()
    if menu.open and not waitingForBind then
        menu.index = menu.index - 1
        if menu.index < 1 then menu.index = #menu.items end
    end
end)

susano.on_key(Keybinds.down, function()
    if menu.open and not waitingForBind then
        menu.index = menu.index + 1
        if menu.index > #menu.items then menu.index = 1 end
    end
end)

susano.on_key(Keybinds.back, function()
    if menu.open and not waitingForBind then
        print("Retour")
    end
end)

-- ============================
--   DRAW
-- ============================

susano.on_draw(function()
    if not menu.open then return end

    local sw, sh = susano.get_screen_size()
    local x = (sw - cfg.width) / 2
    local y = (sh - (#menu.items * cfg.itemHeight + 90)) / 2

    susano.draw_rect_filled(x, y, cfg.width, (#menu.items * cfg.itemHeight) + 90, cfg.bgColor)
    susano.draw_rect(x, y, cfg.width, (#menu.items * cfg.itemHeight) + 90, cfg.borderColor)

    susano.draw_text_centered(cfg.title, x + cfg.width/2, y + 30, cfg.accent, 22, true)
    susano.draw_rect_filled(x + 40, y + 55, cfg.width - 80, 2, cfg.accent)

    local startY = y + 80
    for i, item in ipairs(menu.items) do
        local iy = startY + (i-1) * cfg.itemHeight

        if i == menu.index then
            susano.draw_rect_filled(x + 10, iy, cfg.width - 20, cfg.itemHeight, cfg.hoverColor)
            susano.draw_text(item, x + 30, iy + 8, cfg.accent, 18, false)
        else
            susano.draw_text(item, x + 30, iy + 8, cfg.textColor, 18, false)
        end

        if item == "Keybinds" then
            susano.draw_text(">", x + cfg.width - 40, iy + 8, cfg.textColor, 18, false)
        end
    end

    -- ============================
    --   KEYBIND CONFIG SCREEN
    -- ============================

    if menu.items[menu.index] == "Keybinds" then
        local bx = x + cfg.width + 20
        local by = y

        susano.draw_rect_filled(bx, by, 300, 200, cfg.bgColor)
        susano.draw_rect(bx, by, 300, 200, cfg.borderColor)

        susano.draw_text("Changer un bind :", bx + 20, by + 20, cfg.accent, 20, false)

        local offset = 60
        for name, key in pairs(Keybinds) do
            local text = name .. " : " .. key
            susano.draw_text(text, bx + 20, by + offset, cfg.textColor, 18, false)
            offset = offset + 30
        end

        if waitingForBind then
            susano.draw_text("Appuyez sur une touche...", bx + 20, by + 160, cfg.accent, 18, false)
        end
    end
end)
