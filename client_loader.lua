-- ================================
-- DNB MENU (Susano) - Rouge/Noir + Bordure néon
-- Bind touche au démarrage + Toggle + Nav clavier + Sous-menus + Retour (←)
-- ================================

-- Virtual-Key codes (Windows)
local VK = {
  UP     = 0x26,
  DOWN   = 0x28,
  LEFT   = 0x25,
  RIGHT  = 0x27,
  ENTER  = 0x0D,
  BACK   = 0x08,   -- Backspace
  ESC    = 0x1B,
}

-- Liste de touches scannées pour le bind (évite de scanner 0x00..0xFF)
local BIND_KEYS = {}
do
  -- A-Z
  for vk = 0x41, 0x5A do BIND_KEYS[#BIND_KEYS+1] = vk end
  -- 0-9
  for vk = 0x30, 0x39 do BIND_KEYS[#BIND_KEYS+1] = vk end
  -- F1-F12
  for vk = 0x70, 0x7B do BIND_KEYS[#BIND_KEYS+1] = vk end
  -- Insert / Delete / Home / End / PgUp / PgDn / ESC
  local extra = { 0x2D, 0x2E, 0x24, 0x23, 0x21, 0x22, VK.ESC }
  for i = 1, #extra do BIND_KEYS[#BIND_KEYS+1] = extra[i] end
end

-- Helpers input (Susano.GetAsyncKeyState)
local function keyPressed(vk)
  local down, pressed = Susano.GetAsyncKeyState(vk) -- -> down, pressed
  return pressed == true
end

local function detectAnyBindKey()
  for i = 1, #BIND_KEYS do
    if keyPressed(BIND_KEYS[i]) then
      return BIND_KEYS[i]
    end
  end
  return nil
end

-- Menu state
local toggleKey = nil

local menu = {
  open = false,
  x = 200, y = 120,
  w = 320, h = 440,

  state = "main",      -- "main" | "submenu"
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

local function getList()
  if menu.state == "main" then return menu.items end
  return menu.submenus[menu.currentSub] or { "Back" }
end

local function clampSelected()
  local list = getList()
  if menu.selected < 1 then menu.selected = #list end
  if menu.selected > #list then menu.selected = 1 end
end

-- Neon border helper (multi-rect glow)
local function drawNeonBorder(x, y, w, h, r, g, b)
  -- Couche glow externe (plus large, plus transparent)
  Susano.DrawRect(x - 3, y - 3, w + 6, h + 6, r, g, b, 0.10, 6.0)
  Susano.DrawRect(x - 2, y - 2, w + 4, h + 4, r, g, b, 0.16, 4.0)
  Susano.DrawRect(x - 1, y - 1, w + 2, h + 2, r, g, b, 0.22, 2.5)
  -- Bordure nette
  Susano.DrawRect(x, y, w, h, r, g, b, 0.90, 1.5)
end

Citizen.CreateThread(function()
  -- Petit delay pour éviter que ça parte trop tôt
  Citizen.Wait(1500)

  -- Overlay ON pour capter la touche au début
  Susano.EnableOverlay(true)

  -- ===== PHASE BIND =====
  while not toggleKey do
    Citizen.Wait(0)

    Susano.BeginFrame()

    -- Panel bind (rouge/noir)
    local bx, by, bw, bh = 380, 280, 560, 120
    Susano.DrawRectFilled(bx, by, bw, bh, 0.03, 0.03, 0.03, 0.95, 10)
    drawNeonBorder(bx, by, bw, bh, 1.0, 0.10, 0.10)

    Susano.DrawRectFilled(bx, by, bw, 42, 0.08, 0.00, 0.00, 1.0, 10)
    Susano.DrawRectFilled(bx, by + 40, bw, 3, 0.85, 0.05, 0.05, 1.0, 0)

    Susano.DrawText(bx + 18, by + 28, "DNB", 26, 1.0, 0.10, 0.10, 1.0)
    Susano.DrawText(bx + 18, by + 70, "Appuie sur une touche pour ouvrir / fermer le menu", 18, 1, 1, 1, 1)

    local vk = detectAnyBindKey()
    if vk then
      toggleKey = vk
      menu.open = true
      Susano.EnableOverlay(true)
    end

    Susano.SubmitFrame()
  end

  -- ===== LOOP MAIN =====
  while true do
    Citizen.Wait(0)

    -- Toggle menu via touche bind
    if toggleKey and keyPressed(toggleKey) then
      menu.open = not menu.open
      Susano.EnableOverlay(menu.open)
    end

    if not menu.open then
      -- overlay OFF => rien à dessiner (et souris disparaît)
      goto continue
    end

    -- NAV
    if keyPressed(VK.UP) then
      menu.selected = menu.selected - 1
      clampSelected()
    end

    if keyPressed(VK.DOWN) then
      menu.selected = menu.selected + 1
      clampSelected()
    end

    -- Retour sous-menu (←)
    if keyPressed(VK.LEFT) and menu.state == "submenu" then
      menu.state = "main"
      menu.currentSub = nil
      menu.selected = 1
    end

    -- Entrer sous-menu (→)
    if keyPressed(VK.RIGHT) and menu.state == "main" then
      local name = menu.items[menu.selected]
      if menu.submenus[name] then
        menu.state = "submenu"
        menu.currentSub = name
        menu.selected = 1
      end
    end

    -- Valider (ENTER)
    if keyPressed(VK.ENTER) then
      if menu.state == "main" then
        local name = menu.items[menu.selected]
        if menu.submenus[name] then
          menu.state = "submenu"
          menu.currentSub = name
          menu.selected = 1
        end
      else
        local list = getList()
        local choice = list[menu.selected]
        if choice == "Back" then
          menu.state = "main"
          menu.currentSub = nil
          menu.selected = 1
        end
      end
    end

    -- Fermer (BACKSPACE)
    if keyPressed(VK.BACK) then
      menu.open = false
      Susano.EnableOverlay(false)
      -- Optionnel: wipe immédiat du dernier frame de cette coroutine
      -- Susano.ResetFrame()
      goto continue
    end

    -- ===== DRAW (DNB) =====
    Susano.BeginFrame()

    -- Fond principal
    Susano.DrawRectFilled(menu.x, menu.y, menu.w, menu.h, 0.03, 0.03, 0.03, 0.97, 10)

    -- Bordure néon rouge
    drawNeonBorder(menu.x, menu.y, menu.w, menu.h, 1.0, 0.10, 0.10)

    -- Header
    Susano.DrawRectFilled(menu.x, menu.y, menu.w, 62, 0.08, 0.00, 0.00, 1.0, 10)
    Susano.DrawRectFilled(menu.x, menu.y + 58, menu.w, 4, 0.85, 0.05, 0.05, 1.0, 0)

    -- Branding
    Susano.DrawText(menu.x + 18, menu.y + 28, "DNB", 28, 1.0, 0.10, 0.10, 1.0)

    local subtitle = (menu.state == "main") and "Main menu" or ("Menu: " .. tostring(menu.currentSub))
    Susano.DrawText(menu.x + 18, menu.y + 78, subtitle, 16, 0.85, 0.85, 0.85, 0.95)

    -- Items
    local list = getList()
    local startY = menu.y + 108
    local itemH = 34

    for i, label in ipairs(list) do
      local iy = startY + (i - 1) * itemH

      if menu.selected == i then
        -- sélection rouge vif + petit glow
        Susano.DrawRectFilled(menu.x + 10, iy, menu.w - 20, itemH, 0.85, 0.05, 0.05, 1.0, 6)
        Susano.DrawRect(menu.x + 10, iy, menu.w - 20, itemH, 1.0, 0.15, 0.15, 0.60, 2.0)
      else
        -- item normal
        Susano.DrawRectFilled(menu.x + 10, iy, menu.w - 20, itemH, 0.08, 0.08, 0.08, 0.90, 6)
      end

      Susano.DrawText(menu.x + 22, iy + 23, label, 16, 1, 1, 1, 1)

      if menu.state == "main" then
        Susano.DrawText(menu.x + menu.w - 28, iy + 23, ">", 16, 1.0, 0.25, 0.25, 1)
      end
    end

    Susano.SubmitFrame()

    ::continue::
  end
end)
