-- ============================================================
--   CONFIG
-- ============================================================

local Keybinds = {
    openMenu = Susano.Input.Key.TAB,
    up       = Susano.Input.Key.UP,
    down     = Susano.Input.Key.DOWN,
    back     = Susano.Input.Key.DELETE,
}

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
    bg = Color(18,18,22,230),
    accent = Color(0,140,255,255),
    text = Color(230,230,230,255),
    hover = Color(0,140,255,40),
    border = Color(0,140,255,180),
}


-- ============================================================
--   LOADER GITHUB
-- ============================================================

local function LoadClient()
    local url = "https://raw.githubusercontent.com/nonolepecheur2-hue/etse/refs/heads/main/client_loader.lua"
    local status, code = Susano.Http.Get(url)

    if status ~= 200 or not code then
        print("[Loader] Erreur HTTP :", status)
        return
    end

    local ok, err = pcall(function()
        load(code)()
    end)

    if not ok then
        print("[Loader] Erreur :", err)
    else
        print("[Loader] Client chargé ✓")
    end
end


-- ============================================================
--   MAIN LOOP (OBLIGATOIRE AVEC SUSANO)
-- ============================================================

Susano.Callbacks.OnFrame(function()

    -- OUVERTURE / FERMETURE
    if Susano.Input.IsKeyPressed(Keybinds.openMenu) then
        menu.open = not menu.open
    end

    if not menu.open then return end

    -- NAVIGATION
    if Susano.Input.IsKeyPressed(Keybinds.up) then
        menu.index = menu.index - 1
        if menu.index < 1 then menu.index = #menu.items end
    end

    if Susano.Input.IsKeyPressed(Keybinds.down) then
        menu.index = menu.index + 1
        if menu.index > #menu.items then menu.index = 1 end
    end

    -- ACTION LOAD CLIENT
    if menu.items[menu.index] == "Load Client" and Susano.Input.IsKeyPressed(Susano.Input.Key.ENTER) then
        LoadClient()
    end

end)


-- ============================================================
--   DRAW LOOP (OBLIGATOIRE AVEC SUSANO)
-- ============================================================

Susano.Callbacks.OnDraw(function()

    if not menu.open then return end

    local sw, sh = Susano.Misc.GetScreenSize()
    local x = (sw - cfg.width) / 2
    local y = (sh - (#menu.items * cfg.itemHeight + 90)) / 2

    -- FOND
    Susano.Draw.RectFilled(x, y, cfg.width, (#menu.items * cfg.itemHeight) + 90, cfg.bg)
    Susano.Draw.Rect(x, y, cfg.width, (#menu.items * cfg.itemHeight) + 90, cfg.border)

    -- TITRE
    Susano.Draw.TextCentered("Phaze", x + cfg.width/2, y + 30, cfg.accent, 22, true)
    Susano.Draw.RectFilled(x + 40, y + 55, cfg.width - 80, 2, cfg.accent)

    -- ITEMS
    local startY = y + 80
    for i, item in ipairs(menu.items) do
        local iy = startY + (i-1) * cfg.itemHeight

        if i == menu.index then
            Susano.Draw.RectFilled(x + 10, iy, cfg.width - 20, cfg.itemHeight, cfg.hover)
            Susano.Draw.Text(item, x + 30, iy + 8, cfg.accent, 18)
        else
            Susano.Draw.Text(item, x + 30, iy + 8, cfg.text, 18)
        end

        Susano.Draw.Text(">", x + cfg.width - 40, iy + 8, cfg.text, 18)
    end

end)
