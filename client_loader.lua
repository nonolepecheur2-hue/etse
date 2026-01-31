-- ================================
-- DNB MENU (Susano) - Rouge/Noir + Bordure néon
-- Bind au démarrage (Keyboard/Mouse) + Toggle + Nav ↑↓→← + Enter + Backspace
-- ================================

-- Virtual-Key codes (Windows)
local VK = {
  UP       = 0x26,
  DOWN     = 0x28,
  LEFT     = 0x25,
  RIGHT    = 0x27,
  ENTER    = 0x0D,
  BACK     = 0x08,  -- Backspace
  TAB      = 0x09,
  ESC      = 0x1B,

  -- mouse buttons
  LBUTTON  = 0x01,
  RBUTTON  = 0x02,
  MBUTTON  = 0x04,
  XBUTTON1 = 0x05,
  XBUTTON2 = 0x06,

  CAPS     = 0x14,
  SHIFT    = 0x10,
  LSHIFT   = 0xA0,
  RSHIFT   = 0xA1,
  CTRL     = 0x11,
  LCTRL    = 0xA2,
  RCTRL    = 0xA3,
  ALT      = 0x12,
  LALT     = 0xA4,
  RALT     = 0xA5,
  INSERT   = 0x2D,
}

-- ===== Susano input helper (doc: GetAsyncKeyState) =====
local function keyPressed(vk)
  local down, pressed = Susano.GetAsyncKeyState(vk) -- -> down, pressed
  return pressed == true
end

-- ===== Pretty key name (minimal mapping) =====
local function keyName(vk)
  if vk == nil then return "None" end
  local names = {
    [VK.LBUTTON] = "Mouse 1",
    [VK.RBUTTON] = "Mouse 2",
    [VK.MBUTTON] = "Mouse 3",
    [VK.XBUTTON1]= "Mouse 4",
    [VK.XBUTTON2]= "Mouse 5",
    [VK.INSERT]  = "Insert",
    [VK.CAPS]    = "Caps Lock",
    [VK.SHIFT]   = "Shift",
    [VK.LSHIFT]  = "LShift",
    [VK.RSHIFT]  = "RShift",
    [VK.CTRL]    = "Ctrl",
    [VK.LCTRL]   = "LCtrl",
    [VK.RCTRL]   = "RCtrl",
    [VK.ALT]     = "Alt",
    [VK.LALT]    = "LAlt",
    [VK.RALT]    = "RAlt",
    [VK.ESC]     = "Esc",
    [VK.TAB]     = "Tab",
  }
  if names[vk] then return names[vk] end

  -- A-Z
  if vk >= 0x41 and vk <= 0x5A then
    return string.char(vk)
  end
  -- 0-9
  if vk >= 0x30 and vk <= 0x39 then
    return string.char(vk)
  end
  -- F1-F12
  if vk >= 0x70 and vk <= 0x7B then
    return "F" .. tostring(vk - 0x6F)
  end

  return ("VK 0x%02X"):format(vk)
end

-- ===== Detect any key (Keyboard mode) =====
-- Scan “safe” range; ignore mouse keys if keyboard mode.
local function detectKeyboardKey()
  -- 1) try common special keys first
  local specials = {
    VK.INSERT, VK.CAPS, VK.TAB, VK.ESC,
    VK.LSHIFT, VK.RSHIFT, VK.LCTRL, VK.RCTRL, VK.LALT, VK.RALT,
  }
  for i=1,#specials do
    if keyPressed(specials[i]) then return specials[i] end
  end

  -- 2) then scan A-Z, 0-9, F1-F12
  for vk=0x41,0x5A do if keyPressed(vk) then return vk end end
  for vk=0x30,0x39 do if keyPressed(vk) then return vk end end
  for vk=0x70,0x7B do if keyPressed(vk) then return vk end end

  -- 3) optional: scan rest (light)
  -- If you want truly “any key”, uncomment:
  -- for vk=0x01,0xFE do
  --   -- ignore mouse buttons here
  --   if vk ~= VK.LBUTTON and vk ~= VK.RBUTTON and vk ~= VK.MBUTTON and vk ~= VK.XBUTTON1 and vk ~= VK.XBUTTON2 then
  --     if keyPressed(vk) then return vk end
  --   end
  -- end

  return nil
end

-- ===== Detect mouse button (Mouse mode) =====
local function detectMouseKey()
  local mouse = { VK.LBUTTON, VK.RBUTTON, VK.MBUTTON, VK.XBUTTON1, VK.XBUTTON2 }
  for i=1,#mouse do
    if keyPressed(mouse[i]) then return mouse[i] end
  end
  return nil
end

-- ===== Menu state =====
local toggleKey = nil
local bindMode = "select"   -- select | listen
local bindDevice = "keyboard" -- keyboard | mouse
local selectIndex = 1       -- 1=Keyboard, 2=Mouse

local menu = {
  open = false,
  x = 200, y = 120,
  w = 340, h = 460,

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

-- ===== Neon border helper (multi-rect glow) =====
local function drawNeonBorder(x, y, w, h, r, g, b)
  Susano.DrawRect(x - 4, y - 4, w + 8, h + 8, r, g, b, 0.10, 7.0)
  Susano.DrawRect(x - 3, y - 3, w + 6, h + 6, r, g, b, 0.14, 5.0)
  Susano.DrawRect(x - 2, y - 2, w + 4, h + 4, r, g, b, 0.18, 3.5)
  Susano.DrawRect(x - 1, y - 1, w + 2, h + 2, r, g, b, 0.24, 2.5)
  Susano.DrawRect(x, y, w, h, r, g, b, 0.95, 1.5)
end

-- ================================
-- MAIN LOOP
-- ================================
Citizen.CreateThread(function()
  Citizen.Wait(1200)

  -- On active overlay pour pouvoir binder (sinon le jeu capte tout)
  Susano.EnableOverlay(true)

  while true do
    Citizen.Wait(0)

    -- =========================
    -- BIND UI (Keyboard/Mouse)
    -- =========================
    if not toggleKey then
      Susano.BeginFrame()

      local bx, by, bw, bh = 340, 220, 620, 220
      Susano.DrawRectFilled(bx, by, bw, bh, 0.03, 0.03, 0.03, 0.95, 12)
      drawNeonBorder(bx, by, bw, bh, 1.0, 0.10, 0.10)

      -- header
      Susano.DrawRectFilled(bx, by, bw, 52, 0.08, 0.00, 0.00, 1.0, 12)
      Susano.DrawRectFilled(bx, by + 48, bw, 4, 0.85, 0.05, 0.05, 1.0, 0)
      Susano.DrawText(bx + 18, by + 30, "DNB", 28, 1.0, 0.10, 0.10, 1.0)
      Susano.DrawText(bx + 18, by + 78, "Menu Selection", 18, 1, 1, 1, 1)

      -- two buttons
      local btnY = by + 108
      local btnW = (bw - 60) / 2
      local btnH = 48

      local kx = bx + 20
      local mx = bx + 40 + btnW

      -- selection by arrows
      if keyPressed(VK.LEFT) or keyPressed(VK.RIGHT) then
        selectIndex = (selectIndex == 1) and 2 or 1
      end
      bindDevice = (selectIndex == 1) and "keyboard" or "mouse"

      -- draw keyboard button
      local kSel = (selectIndex == 1)
      Susano.DrawRectFilled(kx, btnY, btnW, btnH, kSel and 0.18 or 0.08, 0.00, 0.00, 0.95, 10)
      Susano.DrawRect(kx, btnY, btnW, btnH, 1.0, 0.15, 0.15, kSel and 0.90 or 0.35, 2.0)
      Susano.DrawText(kx + 18, btnY + 30, "Keyboard", 18, 1, 1, 1, 1)

      -- draw mouse button
      local mSel = (selectIndex == 2)
      Susano.DrawRectFilled(mx, btnY, btnW, btnH, mSel and 0.18 or 0.08, 0.00, 0.00, 0.95, 10)
      Susano.DrawRect(mx, btnY, btnW, btnH, 1.0, 0.15, 0.15, mSel and 0.90 or 0.35, 2.0)
      Susano.DrawText(mx + 18, btnY + 30, "Mouse", 18, 1, 1, 1, 1)

      Susano.DrawText(bx + 18, by + 180, "ENTER: choisir | ESC: annuler", 16, 0.85, 0.85, 0.85, 0.95)

      if keyPressed(VK.ESC) then
        Susano.SubmitFrame()
        -- si tu veux, tu peux fermer overlay ici
        -- Susano.EnableOverlay(false)
        -- break
      end

      if keyPressed(VK.ENTER) then
        bindMode = "listen"
      end

      -- listen mode: capture actual key
      if bindMode == "listen" then
        Susano.DrawText(bx + 18, by + 210, ("Appuie sur une touche (%s) ..."):format(bindDevice), 16, 1, 1, 1, 1)

        local vk = nil
        if bindDevice == "keyboard" then
          vk = detectKeyboardKey()
        else
          vk = detectMouseKey()
        end

        if vk then
          toggleKey = vk
          menu.open = true
          menu.state = "main"
          menu.selected = 1
          bindMode = "select"
          -- overlay reste ON car menu ouvert
        end
      end

      Susano.SubmitFrame()
      goto continue
    end

    -- =========================
    -- TOGGLE MENU
    -- =========================
    if toggleKey and keyPressed(toggleKey) then
      menu.open = not menu.open
      Susano.EnableOverlay(menu.open) -- overlay visible seulement menu ouvert
    end

    if not menu.open then
      goto continue
    end

    -- =========================
    -- NAV MENU
    -- =========================
    if keyPressed(VK.UP) then
      menu.selected = menu.selected - 1
      clampSelected()
    end

    if keyPressed(VK.DOWN) then
      menu.selected = menu.selected + 1
      clampSelected()
    end

    if keyPressed(VK.LEFT) and menu.state == "submenu" then
      menu.state = "main"
      menu.currentSub = nil
      menu.selected = 1
    end

    if keyPressed(VK.RIGHT) and menu.state == "main" then
      local name = menu.items[menu.selected]
      if menu.submenus[name] then
        menu.state = "submenu"
        menu.currentSub = name
        menu.selected = 1
      end
    end

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

    if keyPressed(VK.BACK) then
      menu.open = false
      Susano.EnableOverlay(false)
      goto continue
    end

    -- =========================
    -- DRAW MENU (DNB + NEON)
    -- =========================
    Susano.BeginFrame()

    Susano.DrawRectFilled(menu.x, menu.y, menu.w, menu.h, 0.03, 0.03, 0.03, 0.97, 12)
    drawNeonBorder(menu.x, menu.y, menu.w, menu.h, 1.0, 0.10, 0.10)

    -- header
    Susano.DrawRectFilled(menu.x, menu.y, menu.w, 62, 0.08, 0.00, 0.00, 1.0, 12)
    Susano.DrawRectFilled(menu.x, menu.y + 58, menu.w, 4, 0.85, 0.05, 0.05, 1.0, 0)

    Susano.DrawText(menu.x + 18, menu.y + 30, "DNB", 28, 1.0, 0.10, 0.10, 1.0)

    local subtitle = (menu.state == "main") and "Main menu" or ("Menu: " .. tostring(menu.currentSub))
    Susano.DrawText(menu.x + 18, menu.y + 78, subtitle, 16, 0.85, 0.85, 0.85, 0.95)

    -- hint bind
    Susano.DrawText(menu.x + 18, menu.y + 100, ("Toggle: %s"):format(keyName(toggleKey)), 14, 0.9, 0.9, 0.9, 0.8)

    -- list
    local list = getList()
    local startY = menu.y + 126
    local itemH = 34

    for i, label in ipairs(list) do
      local iy = startY + (i - 1) * itemH

      if menu.selected == i then
        Susano.DrawRectFilled(menu.x + 10, iy, menu.w - 20, itemH, 0.85, 0.05, 0.05, 1.0, 8)
        Susano.DrawRect(menu.x + 10, iy, menu.w - 20, itemH, 1.0, 0.15, 0.15, 0.75, 2.0)
      else
        Susano.DrawRectFilled(menu.x + 10, iy, menu.w - 20, itemH, 0.08, 0.08, 0.08, 0.90, 8)
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
