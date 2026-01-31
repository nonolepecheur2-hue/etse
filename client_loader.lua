-- ================================
-- SUSANO MENU (Phaze-like)
-- Keybind prompt + Toggle + Nav clavier + Sous-menus + Retour (←)
-- ================================

-- Virtual-Key codes (Windows)
local VK = {
  UP     = 0x26,
  DOWN   = 0x28,
  LEFT   = 0x25,
  RIGHT  = 0x27,
  ENTER  = 0x0D,
  BACK   = 0x08,
}

local toggleKey = nil

local menu = {
  open = false,
  x = 200, y = 120,
  w = 300, h = 420,
  state = "main",     -- "main" | "submenu"
  currentSub = nil,
  selected = 1,

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
    Player = { "Godmode", "Heal", "Teleport", "Back" },
    Server = { "Restart", "Weather", "Time", "Back" },
    Weapon = { "Give Weapon", "Infinite Ammo", "Back" },
  }
}

local function getDrawList()
  if menu.state == "main" then
    return menu.items
  end
  return menu.submenus[menu.currentSub] or { "Back" }
end

local function clampSelected()
  local list = getDrawList()
  if menu.selected < 1 then menu.selected = #list end
  if menu.selected > #list then menu.selected = 1 end
end

-- Petit delay pour éviter “trop tôt”
Citizen.CreateThread(function()
  Wait(1500)

  -- On active l’overlay juste pour capter la touche
  Susano.EnableOverlay(true)

  while not toggleKey do
    Wait(0)

    Susano.DrawRectFilled(400, 300, 520, 90, 0.05, 0.05, 0.08, 0.95, 8)
    Susano.Text(420, 330, "Appuie sur une touche pour ouvrir / fermer le menu", 1, 1, 1, 1)

    local key = Susano.GetPressedKey()
    if key then
      toggleKey = key
      Susano.Notify("Touche menu bind: " .. tostring(toggleKey))
      menu.open = true
      Susano.EnableOverlay(true)
    end

    Susano.SubmitFrame()
  end

  -- Boucle principale
  while true do
    Wait(0)

    -- Toggle menu
    if toggleKey and Susano.IsKeyJustPressed(toggleKey) then
      menu.open = not menu.open
      Susano.EnableOverlay(menu.open)
    end

    if not menu.open then
      -- overlay off => rien à draw
      goto continue
    end

    -- === NAV CLAVIER (Susano) ===
    if Susano.IsKeyJustPressed(VK.UP) then
      menu.selected = menu.selected - 1
      clampSelected()
    end

    if Susano.IsKeyJustPressed(VK.DOWN) then
      menu.selected = menu.selected + 1
      clampSelected()
    end

    -- Retour sous-menu (←)
    if Susano.IsKeyJustPressed(VK.LEFT) then
      if menu.state == "submenu" then
        menu.state = "main"
        menu.currentSub = nil
        menu.selected = 1
      end
    end

    -- Entrer dans un sous-menu (→) (optionnel)
    if Susano.IsKeyJustPressed(VK.RIGHT) then
      if menu.state == "main" then
        local name = menu.items[menu.selected]
        if menu.submenus[name] then
          menu.state = "submenu"
          menu.currentSub = name
          menu.selected = 1
        end
      end
    end

    -- Valider (ENTER)
    if Susano.IsKeyJustPressed(VK.ENTER) then
      if menu.state == "main" then
        local name = menu.items[menu.selected]
        if menu.submenus[name] then
          menu.state = "submenu"
          menu.currentSub = name
          menu.selected = 1
        else
          Susano.Notify("Selected: " .. tostring(name))
        end
      else
        local list = getDrawList()
        local choice = list[menu.selected]
        if choice == "Back" then
          menu.state = "main"
          menu.currentSub = nil
          menu.selected = 1
        else
          Susano.Notify("Choice: " .. tostring(choice))
        end
      end
    end

    -- Fermer (BACKSPACE)
    if Susano.IsKeyJustPressed(VK.BACK) then
      menu.open = false
      Susano.EnableOverlay(false)
    end

    -- === DRAW ===
    Susano.DrawRectFilled(menu.x, menu.y, menu.w, menu.h, 0.10, 0.12, 0.15, 0.95, 10)
    Susano.DrawRectFilled(menu.x, menu.y, menu.w, 60, 0.05, 0.07, 0.12, 1.0, 10)
    Susano.Text(menu.x + 20, menu.y + 20, "Phaze", 0.2, 0.6, 1.0, 1.0)

    local subtitle = (menu.state == "main") and "Main menu" or ("Menu: " .. tostring(menu.currentSub))
    Susano.Text(menu.x + 20, menu.y + 65, subtitle, 0.8, 0.8, 0.8, 0.8)

    local startY = menu.y + 90
    local itemH = 34
    local list = getDrawList()

    for i, label in ipairs(list) do
      local iy = startY + (i - 1) * itemH

      if menu.selected == i then
        Susano.DrawRectFilled(menu.x, iy, menu.w, itemH, 0.15, 0.45, 0.85, 1.0, 4)
      end

      Susano.Text(menu.x + 20, iy + 8, label, 1, 1, 1, 1)

      if menu.state == "main" then
        Susano.Text(menu.x + menu.w - 20, iy + 8, ">", 0.7, 0.7, 0.7, 1)
      end
    end

    Susano.SubmitFrame()

    ::continue::
  end
end)
