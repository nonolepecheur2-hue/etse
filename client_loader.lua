-- ================================
-- DNB MENU (Susano) - Clean UI (Phaze-like) + Neon + Smooth nav
-- Flow: Select Keyboard/Mouse -> Press key -> Saved
-- Controls:
--   ↑ ↓ : navigate (smooth + key repeat)
--   →   : enter submenu
--   Delete (Suppr): back submenu
--   Enter : select (also enters submenu)
--   Esc : close menu
--   ToggleKey : open/close menu
-- ================================

-- Virtual-Key codes (Windows)
local VK = {
  UP       = 0x26,
  DOWN     = 0x28,
  LEFT     = 0x25,
  RIGHT    = 0x27,
  ENTER    = 0x0D,
  ESC      = 0x1B,
  DELETE   = 0x2E,  -- SUPPR (Back submenu)
  BACK     = 0x08,  -- Backspace (optionnel)
  TAB      = 0x09,

  -- Mouse buttons
  LBUTTON  = 0x01,
  RBUTTON  = 0x02,
  MBUTTON  = 0x04,
  XBUTTON1 = 0x05,
  XBUTTON2 = 0x06,

  -- Common keys
  INSERT   = 0x2D,
  CAPS     = 0x14,
  LSHIFT   = 0xA0,
  RSHIFT   = 0xA1,
  LCTRL    = 0xA2,
  RCTRL    = 0xA3,
  LALT     = 0xA4,
  RALT     = 0xA5,
}

-- ================================
-- Susano input helpers (GetAsyncKeyState)
-- ================================
local function keyDown(vk)
  local down, pressed = Susano.GetAsyncKeyState(vk)
  return down == true
end

local function keyPressed(vk)
  local down, pressed = Susano.GetAsyncKeyState(vk)
  return pressed == true
end

-- Repeat (smooth navigation when holding ↑/↓)
local function repeatKey(vk, state, now)
  -- state: { next = 0, firstDelay = 240, repeatRate = 55 }
  if keyPressed(vk) then
    state.next = now + state.firstDelay
    return true
  end
  if keyDown(vk) and now >= state.next then
    state.next = now + state.repeatRate
    return true
  end
  if not keyDown(vk) then
    state.next = 0
  end
  return false
end

-- ================================
-- Pretty key names
-- ================================
local function keyName(vk)
  if not vk then return "None" end
  local names = {
    [VK.LBUTTON] = "Mouse 1",
    [VK.RBUTTON] = "Mouse 2",
    [VK.MBUTTON] = "Mouse 3",
    [VK.XBUTTON1]= "Mouse 4",
    [VK.XBUTTON2]= "Mouse 5",
    [VK.INSERT]  = "Insert",
    [VK.CAPS]    = "Caps Lock",
    [VK.LSHIFT]  = "LShift",
    [VK.RSHIFT]  = "RShift",
    [VK.LCTRL]   = "LCtrl",
    [VK.RCTRL]   = "RCtrl",
    [VK.LALT]    = "LAlt",
    [VK.RALT]    = "RAlt",
    [VK.ESC]     = "Esc",
    [VK.TAB]     = "Tab",
    [VK.DELETE]  = "Delete",
  }
  if names[vk] then return names[vk] end

  if vk >= 0x41 and vk <= 0x5A then return string.char(vk) end -- A-Z
  if vk >= 0x30 and vk <= 0x39 then return string.char(vk) end -- 0-9
  if vk >= 0x70 and vk <= 0x7B then return "F" .. tostring(vk - 0x6F) end -- F1-F12

  return ("VK 0x%02X"):format(vk)
end

-- ================================
-- Key capture (device-specific)
-- ================================
local function detectMouseBind()
  local mouse = { VK.LBUTTON, VK.RBUTTON, VK.MBUTTON, VK.XBUTTON1, VK.XBUTTON2 }
  for i=1,#mouse do
    if keyPressed(mouse[i]) then return mouse[i] end
  end
  return nil
end

local function detectKeyboardBind()
  -- Scan a wide set incl. Caps/Insert/Shift/Ctrl/Alt + A-Z + 0-9 + F1-F12
  local specials = {
    VK.INSERT, VK.CAPS, VK.TAB, VK.ESC, VK.DELETE,
    VK.LSHIFT, VK.RSHIFT, VK.LCTRL, VK.RCTRL, VK.LALT, VK.RALT,
  }
  for i=1,#specials do
    if keyPressed(specials[i]) then return specials[i] end
  end

  for vk=0x41,0x5A do if keyPressed(vk) then return vk end end
  for vk=0x30,0x39 do if keyPressed(vk) then return vk end end
  for vk=0x70,0x7B do if keyPressed(vk) then return vk end end

  -- If you REALLY want “any key”: uncomment (heavier)
  -- for vk=0x01,0xFE do
  --   if vk ~= VK.LBUTTON and vk ~= VK.RBUTTON and vk ~= VK.MBUTTON and vk ~= VK.XBUTTON1 and vk ~= VK.XBUTTON2 then
  --     if keyPressed(vk) then return vk end
  --   end
  -- end

  return nil
end

-- ================================
-- Visual helpers (Neon border + smooth highlight)
-- ================================
local function drawNeonBorder(x, y, w, h, r, g, b)
  Susano.DrawRect(x - 4, y - 4, w + 8, h + 8, r, g, b, 0.08, 7.0)
  Susano.DrawRect(x - 3, y - 3, w + 6, h + 6, r, g, b, 0.12, 5.0)
  Susano.DrawRect(x - 2, y - 2, w + 4, h + 4, r, g, b, 0.16, 3.5)
  Susano.DrawRect(x - 1, y - 1, w + 2, h + 2, r, g, b, 0.22, 2.5)
  Susano.DrawRect(x, y, w, h, r, g, b, 0.95, 1.5)
end

local function lerp(a, b, t)
  return a + (b - a) * t
end

-- ================================
-- Menu data
-- ================================
local toggleKey = nil

local bind = {
  stage = "device",      -- device -> key -> done
  deviceIndex = 1,       -- 1 keyboard, 2 mouse
  device = "keyboard"
}

local menu = {
  open = false,
  state = "main",
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

-- ================================
-- Layout (centered)
-- NOTE: Susano draw uses absolute pixels. If your resolution differs, adjust these.
-- ================================
local SCREEN_W, SCREEN_H = 1920, 1080
local UI = {
  w = 460,
  h = 560,
  x = math.floor((SCREEN_W - 460) / 2),
  y = math.floor((SCREEN_H - 560) / 2),

  headerH = 74,
  pad = 18,

  itemH = 40,
  listTopPad = 16
}

-- Smooth highlight position
local highlightY = nil

-- Key repeat states
local repUp = { next = 0, firstDelay = 240, repeatRate = 55 }
local repDn = { next = 0, firstDelay = 240, repeatRate = 55 }

-- ================================
-- DRAW: Device select + key capture
-- ================================
local function drawBindScreen(now)
  Susano.BeginFrame()

  local x, y, w, h = UI.x, UI.y + 120, UI.w, 220

  -- panel
  Susano.DrawRectFilled(x, y, w, h, 0.03, 0.03, 0.03, 0.92, 14)
  drawNeonBorder(x, y, w, h, 1.0, 0.12, 0.12)

  -- header
  Susano.DrawRectFilled(x, y, w, 56, 0.08, 0.00, 0.00, 1.0, 14)
  Susano.DrawRectFilled(x, y + 52, w, 4, 0.85, 0.05, 0.05, 1.0, 0)

  Susano.DrawText(x + 20, y + 32, "DNB", 28, 1.0, 0.12, 0.12, 1.0)
  Susano.DrawText(x + 20, y + 86, "Menu Selection", 18, 1, 1, 1, 1)

  local btnY = y + 118
  local gap = 18
  local btnW = (w - (UI.pad * 2) - gap) / 2
  local btnH = 52

  -- device switch
  if keyPressed(VK.LEFT) or keyPressed(VK.RIGHT) then
    bind.deviceIndex = (bind.deviceIndex == 1) and 2 or 1
  end
  bind.device = (bind.deviceIndex == 1) and "keyboard" or "mouse"

  -- keyboard button
  local kx = x + UI.pad
  local mx = kx + btnW + gap

  local kSel = (bind.deviceIndex == 1)
  Susano.DrawRectFilled(kx, btnY, btnW, btnH, kSel and 0.16 or 0.08, 0.00, 0.00, 0.95, 12)
  Susano.DrawRect(kx, btnY, btnW, btnH, 1.0, 0.16, 0.16, kSel and 0.90 or 0.35, 2.0)
  Susano.DrawText(kx + 18, btnY + 33, "Keyboard", 18, 1, 1, 1, 1)

  -- mouse button
  local mSel = (bind.deviceIndex == 2)
  Susano.DrawRectFilled(mx, btnY, btnW, btnH, mSel and 0.16 or 0.08, 0.00, 0.00, 0.95, 12)
  Susano.DrawRect(mx, btnY, btnW, btnH, 1.0, 0.16, 0.16, mSel and 0.90 or 0.35, 2.0)
  Susano.DrawText(mx + 18, btnY + 33, "Mouse", 18, 1, 1, 1, 1)

  Susano.DrawText(x + 20, y + 198, "ENTER: choisir  |  ESC: annuler", 16, 0.85, 0.85, 0.85, 0.95)

  -- next stage
  if keyPressed(VK.ESC) then
    -- leave overlay on, still waiting
    -- (you can also disable overlay here if you want)
  end

  if keyPressed(VK.ENTER) then
    bind.stage = "key"
  end

  Susano.SubmitFrame()
end

local function drawKeyCapture(now)
  Susano.BeginFrame()

  local x, y, w, h = UI.x, UI.y + 120, UI.w, 220

  Susano.DrawRectFilled(x, y, w, h, 0.03, 0.03, 0.03, 0.92, 14)
  drawNeonBorder(x, y, w, h, 1.0, 0.12, 0.12)

  Susano.DrawRectFilled(x, y, w, 56, 0.08, 0.00, 0.00, 1.0, 14)
  Susano.DrawRectFilled(x, y + 52, w, 4, 0.85, 0.05, 0.05, 1.0, 0)

  Susano.DrawText(x + 20, y + 32, "DNB", 28, 1.0, 0.12, 0.12, 1.0)
  Susano.DrawText(x + 20, y + 92, ("Appuie sur une touche (%s) ..."):format(bind.device), 18, 1, 1, 1, 1)
  Susano.DrawText(x + 20, y + 128, "La touche choisie servira a ouvrir/fermer le menu.", 16, 0.85, 0.85, 0.85, 0.95)
  Susano.DrawText(x + 20, y + 198, "ESC: retour", 16, 0.85, 0.85, 0.85, 0.95)

  if keyPressed(VK.ESC) then
    bind.stage = "device"
    Susano.SubmitFrame()
    return nil
  end

  local vk = nil
  if bind.device == "keyboard" then
    vk = detectKeyboardBind()
  else
    vk = detectMouseBind()
  end

  Susano.SubmitFrame()
  return vk
end

-- ================================
-- DRAW: Main menu (Phaze-like layout)
-- ================================
local function drawMenu(now)
  Susano.BeginFrame()

  local x, y, w, h = UI.x, UI.y, UI.w, UI.h

  -- background + neon
  Susano.DrawRectFilled(x, y, w, h, 0.03, 0.03, 0.03, 0.92, 18)
  drawNeonBorder(x, y, w, h, 1.0, 0.10, 0.10)

  -- header
  Susano.DrawRectFilled(x, y, w, UI.headerH, 0.08, 0.00, 0.00, 1.0, 18)
  Susano.DrawRectFilled(x, y + UI.headerH - 5, w, 5, 0.85, 0.05, 0.05, 1.0, 0)

  Susano.DrawText(x + 22, y + 38, "DNB", 30, 1.0, 0.12, 0.12, 1.0)

  local subtitle = (menu.state == "main") and "Main menu" or ("Menu: " .. tostring(menu.currentSub))
  Susano.DrawText(x + 22, y + UI.headerH + 18, subtitle, 16, 0.85, 0.85, 0.85, 0.95)
  Susano.DrawText(x + 22, y + UI.headerH + 42, ("Toggle: %s"):format(keyName(toggleKey)), 14, 0.85, 0.85, 0.85, 0.75)

  -- list area
  local list = getList()
  local listX = x + UI.pad
  local listY = y + UI.headerH + 78
  local listW = w - (UI.pad * 2)

  -- compute highlight target
  local targetY = listY + (menu.selected - 1) * UI.itemH
  if highlightY == nil then highlightY = targetY end
  highlightY = lerp(highlightY, targetY, 0.22) -- smooth

  -- draw highlight (smooth)
  Susano.DrawRectFilled(listX, highlightY, listW, UI.itemH, 0.85, 0.05, 0.05, 1.0, 10)
  Susano.DrawRect(listX, highlightY, listW, UI.itemH, 1.0, 0.16, 0.16, 0.65, 2.0)

  -- draw items
  for i, label in ipairs(list) do
    local iy = listY + (i - 1) * UI.itemH

    -- subtle item background
    Susano.DrawRectFilled(listX, iy, listW, UI.itemH, 0.07, 0.07, 0.07, 0.78, 10)

    -- text
    Susano.DrawText(listX + 16, iy + 26, label, 16, 1, 1, 1, 1)

    -- arrow only for main categories
    if menu.state == "main" then
      Susano.DrawText(listX + listW - 18, iy + 26, ">", 16, 1.0, 0.25, 0.25, 1.0)
    end
  end

  -- footer hint
  Susano.DrawText(x + 22, y + h - 24, "Delete: Back  |  Esc: Close  |  Arrows: Navigate", 14, 0.85, 0.85, 0.85, 0.70)

  Susano.SubmitFrame()
end

-- ================================
-- MAIN THREAD
-- ================================
Citizen.CreateThread(function()
  Citizen.Wait(1200)

  -- overlay on for bind + menu
  Susano.EnableOverlay(true)

  while true do
    Citizen.Wait(0)

    local now = GetGameTimer()

    -- ====== BIND FLOW ======
    if not toggleKey then
      if bind.stage == "device" then
        drawBindScreen(now)
      else
        local vk = drawKeyCapture(now)
        if vk then
          toggleKey = vk
          menu.open = true
          menu.state = "main"
          menu.currentSub = nil
          menu.selected = 1
          highlightY = nil
          Susano.EnableOverlay(true)
        end
      end

      goto continue
    end

    -- ====== TOGGLE MENU ======
    if keyPressed(toggleKey) then
      menu.open = not menu.open
      Susano.EnableOverlay(menu.open)
      highlightY = nil
    end

    if not menu.open then
      goto continue
    end

    -- ====== CLOSE ======
    if keyPressed(VK.ESC) then
      menu.open = false
      Susano.EnableOverlay(false)
      goto continue
    end

    -- ====== NAV (smooth repeat) ======
    if repeatKey(VK.UP, repUp, now) then
      menu.selected = menu.selected - 1
      clampSelected()
    end

    if repeatKey(VK.DOWN, repDn, now) then
      menu.selected = menu.selected + 1
      clampSelected()
    end

    -- Enter submenu (→) or Enter
    if keyPressed(VK.RIGHT) or keyPressed(VK.ENTER) then
      if menu.state == "main" then
        local name = menu.items[menu.selected]
        if menu.submenus[name] then
          menu.state = "submenu"
          menu.currentSub = name
          menu.selected = 1
          highlightY = nil
        end
      else
        -- submenu: select item (example behavior)
        local list = getList()
        local choice = list[menu.selected]
        if choice == "Back" then
          menu.state = "main"
          menu.currentSub = nil
          menu.selected = 1
          highlightY = nil
        end
      end
    end

    -- Back submenu with DELETE (Suppr)
    if keyPressed(VK.DELETE) and menu.state == "submenu" then
      menu.state = "main"
      menu.currentSub = nil
      menu.selected = 1
      highlightY = nil
    end

    -- also allow selecting Back item with Enter
    if keyPressed(VK.ENTER) and menu.state == "submenu" then
      local list = getList()
      local choice = list[menu.selected]
      if choice == "Back" then
        menu.state = "main"
        menu.currentSub = nil
        menu.selected = 1
        highlightY = nil
      end
    end

    -- draw
    drawMenu(now)

    ::continue::
  end
end)
