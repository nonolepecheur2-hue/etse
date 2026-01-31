-- ================================
-- DNB MENU (Susano) - CENTER + DRAG + SMOOTH NAV
-- FIXED: input cache per-frame (bind now works)
-- Flow: Device select -> Press key -> Saved
-- Controls:
--   ↑ ↓ : navigate (smooth repeat)
--   → / Enter : enter submenu
--   Delete : back submenu
--   Esc : close menu
--   Drag header : move menu (does NOT affect arrow nav)
-- ================================

-- ===== VK codes =====
local VK = {
  UP       = 0x26,
  DOWN     = 0x28,
  LEFT     = 0x25,
  RIGHT    = 0x27,
  ENTER    = 0x0D,
  ESC      = 0x1B,
  DELETE   = 0x2E,

  LBUTTON  = 0x01,
  RBUTTON  = 0x02,
  MBUTTON  = 0x04,
  XBUTTON1 = 0x05,
  XBUTTON2 = 0x06,

  INSERT   = 0x2D,
  CAPS     = 0x14,
  LSHIFT   = 0xA0,
  RSHIFT   = 0xA1,
  LCTRL    = 0xA2,
  RCTRL    = 0xA3,
  LALT     = 0xA4,
  RALT     = 0xA5,
  TAB      = 0x09,
}

-- ================================
-- INPUT CACHE (IMPORTANT)
-- Each vk is queried once per frame.
-- ================================
local inputCache = { frame = -1, down = {}, pressed = {} }

local function getFrameId()
  -- GetGameTimer() changes every frame in FiveM/GTA.
  -- If you are not in FiveM, replace with another increasing counter.
  return GetGameTimer()
end

local function getKeyState(vk)
  local fid = getFrameId()
  if inputCache.frame ~= fid then
    inputCache.frame = fid
    inputCache.down = {}
    inputCache.pressed = {}
  end

  if inputCache.down[vk] == nil then
    local down, pressed = Susano.GetAsyncKeyState(vk)
    inputCache.down[vk] = down == true
    inputCache.pressed[vk] = pressed == true
  end

  return inputCache.down[vk], inputCache.pressed[vk]
end

local function keyDown(vk)
  local d, p = getKeyState(vk)
  return d
end

local function keyPressed(vk)
  local d, p = getKeyState(vk)
  return p
end

-- Smooth key-repeat for ↑/↓ (hold)
local function repeatKey(vk, st, nowMs)
  if keyPressed(vk) then
    st.next = nowMs + st.firstDelay
    return true
  end
  if keyDown(vk) and nowMs >= st.next then
    st.next = nowMs + st.repeatRate
    return true
  end
  if not keyDown(vk) then st.next = 0 end
  return false
end

-- ===== Pretty key names =====
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
    [VK.TAB]     = "Tab",
    [VK.ESC]     = "Esc",
    [VK.DELETE]  = "Delete",
  }
  if names[vk] then return names[vk] end
  if vk >= 0x41 and vk <= 0x5A then return string.char(vk) end
  if vk >= 0x30 and vk <= 0x39 then return string.char(vk) end
  if vk >= 0x70 and vk <= 0x7B then return "F" .. tostring(vk - 0x6F) end
  return ("VK 0x%02X"):format(vk)
end

-- ===== Bind detection (now reliable because of cache) =====
local function detectMouseBind()
  local mouse = { VK.LBUTTON, VK.RBUTTON, VK.MBUTTON, VK.XBUTTON1, VK.XBUTTON2 }
  for i=1,#mouse do
    if keyPressed(mouse[i]) then return mouse[i] end
  end
  return nil
end

local function detectKeyboardBind()
  local specials = {
    VK.INSERT, VK.CAPS, VK.TAB, VK.DELETE,
    VK.LSHIFT, VK.RSHIFT, VK.LCTRL, VK.RCTRL, VK.LALT, VK.RALT,
  }
  for i=1,#specials do
    if keyPressed(specials[i]) then return specials[i] end
  end
  for vk=0x41,0x5A do if keyPressed(vk) then return vk end end
  for vk=0x30,0x39 do if keyPressed(vk) then return vk end end
  for vk=0x70,0x7B do if keyPressed(vk) then return vk end end
  return nil
end

-- ===== Visual helpers =====
local function lerp(a, b, t) return a + (b - a) * t end

local function drawNeonBorder(x, y, w, h, r, g, b)
  Susano.DrawRect(x - 4, y - 4, w + 8, h + 8, r, g, b, 0.08, 7.0)
  Susano.DrawRect(x - 3, y - 3, w + 6, h + 6, r, g, b, 0.12, 5.0)
  Susano.DrawRect(x - 2, y - 2, w + 4, h + 4, r, g, b, 0.16, 3.5)
  Susano.DrawRect(x - 1, y - 1, w + 2, h + 2, r, g, b, 0.22, 2.5)
  Susano.DrawRect(x, y, w, h, r, g, b, 0.95, 1.5)
end

-- ================================
-- SCREEN SIZE (robust)
-- ================================
local screenW, screenH = 1920, 1080

local function updateScreenSize()
  if type(GetActiveScreenResolution) == "function" then
    local w, h = GetActiveScreenResolution()
    if w and h and w > 0 and h > 0 then
      screenW, screenH = w, h
      return
    end
  end
  -- fallback stays 1920x1080
end

-- Remember drag position between frames (no saving file, just runtime)
local UI = {
  w = 480,
  h = 560,
  x = 0,
  y = 0,
  headerH = 74,
  pad = 18,
  itemH = 40,
}

local function recenter()
  updateScreenSize()
  UI.x = math.floor((screenW - UI.w) / 2)
  UI.y = math.floor((screenH - UI.h) / 2)
end

-- ================================
-- MENU STATE
-- ================================
local toggleKey = nil

local bind = {
  stage = "device",     -- device -> key
  deviceIndex = 1,      -- 1 keyboard, 2 mouse
  device = "keyboard",
}

local menu = {
  open = false,
  state = "main",
  currentSub = nil,
  selected = 1,
  items = { "Player","Server","Weapon","Combat","Vehicle","Visual","Miscellaneous","Settings","Search" },
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

-- Smooth highlight
local highlightY = nil

-- Key repeat states
local repUp = { next = 0, firstDelay = 240, repeatRate = 55 }
local repDn = { next = 0, firstDelay = 240, repeatRate = 55 }

-- Drag state
local drag = { active = false, offX = 0, offY = 0 }

-- ================================
-- DRAW: bind device screen (centered)
-- ================================
local function drawBindDevice()
  updateScreenSize()
  local w, h = 620, 230
  local x = math.floor((screenW - w) / 2)
  local y = math.floor((screenH - h) / 2)

  Susano.BeginFrame()

  Susano.DrawRectFilled(x, y, w, h, 0.03,0.03,0.03, 0.92, 14)
  drawNeonBorder(x, y, w, h, 1.0, 0.12, 0.12)

  Susano.DrawRectFilled(x, y, w, 56, 0.08,0.00,0.00, 1.0, 14)
  Susano.DrawRectFilled(x, y + 52, w, 4, 0.85,0.05,0.05, 1.0, 0)

  Susano.DrawText(x + 20, y + 32, "DNB", 28, 1.0,0.12,0.12, 1.0)
  Susano.DrawText(x + 20, y + 86, "Menu Selection", 18, 1,1,1, 1)

  if keyPressed(VK.LEFT) or keyPressed(VK.RIGHT) then
    bind.deviceIndex = (bind.deviceIndex == 1) and 2 or 1
  end
  bind.device = (bind.deviceIndex == 1) and "keyboard" or "mouse"

  local btnY = y + 118
  local gap = 18
  local btnW = (w - 36 - gap) / 2
  local btnH = 52
  local kx = x + 18
  local mx = kx + btnW + gap

  local kSel = (bind.deviceIndex == 1)
  Susano.DrawRectFilled(kx, btnY, btnW, btnH, kSel and 0.16 or 0.08, 0.00,0.00, 0.95, 12)
  Susano.DrawRect(kx, btnY, btnW, btnH, 1.0,0.16,0.16, kSel and 0.90 or 0.35, 2.0)
  Susano.DrawText(kx + 18, btnY + 33, "Keyboard", 18, 1,1,1, 1)

  local mSel = (bind.deviceIndex == 2)
  Susano.DrawRectFilled(mx, btnY, btnW, btnH, mSel and 0.16 or 0.08, 0.00,0.00, 0.95, 12)
  Susano.DrawRect(mx, btnY, btnW, btnH, 1.0,0.16,0.16, mSel and 0.90 or 0.35, 2.0)
  Susano.DrawText(mx + 18, btnY + 33, "Mouse", 18, 1,1,1, 1)

  Susano.DrawText(x + 20, y + 210, "ENTER: choisir  |  ESC: quitter", 16, 0.85,0.85,0.85, 0.95)

  if keyPressed(VK.ENTER) then
    bind.stage = "key"
  end

  Susano.SubmitFrame()
end

-- ================================
-- DRAW: key capture screen (centered) - returns chosen vk or nil
-- ================================
local function drawBindKey()
  updateScreenSize()
  local w, h = 620, 230
  local x = math.floor((screenW - w) / 2)
  local y = math.floor((screenH - h) / 2)

  Susano.BeginFrame()

  Susano.DrawRectFilled(x, y, w, h, 0.03,0.03,0.03, 0.92, 14)
  drawNeonBorder(x, y, w, h, 1.0, 0.12, 0.12)

  Susano.DrawRectFilled(x, y, w, 56, 0.08,0.00,0.00, 1.0, 14)
  Susano.DrawRectFilled(x, y + 52, w, 4, 0.85,0.05,0.05, 1.0, 0)

  Susano.DrawText(x + 20, y + 32, "DNB", 28, 1.0,0.12,0.12, 1.0)
  Susano.DrawText(x + 20, y + 98, ("Appuie sur une touche (%s) ..."):format(bind.device), 18, 1,1,1, 1)
  Susano.DrawText(x + 20, y + 210, "ESC: retour", 16, 0.85,0.85,0.85, 0.95)

  local vk = nil

  if keyPressed(VK.ESC) then
    bind.stage = "device"
  else
    if bind.device == "keyboard" then
      vk = detectKeyboardBind()
    else
      vk = detectMouseBind()
    end
  end

  Susano.SubmitFrame()
  return vk
end

-- ================================
-- DRAW: main menu (drag header)
-- ================================
local function drawMenu()
  Susano.BeginFrame()

  local x, y, w, h = UI.x, UI.y, UI.w, UI.h

  -- Drag header only (mouse), does NOT affect arrow navigation
  local cursorPos = Susano.GetCursorPos() -- Vector2 {x,y} in pixels
  local mx, my = cursorPos.x, cursorPos.y

  local hoveringHeader =
    mx >= x and mx <= x + w and
    my >= y and my <= y + UI.headerH

  if keyPressed(VK.LBUTTON) and hoveringHeader then
    drag.active = true
    drag.offX = mx - UI.x
    drag.offY = my - UI.y
  end
  if not keyDown(VK.LBUTTON) then
    drag.active = false
  end
  if drag.active then
    UI.x = math.floor(mx - drag.offX)
    UI.y = math.floor(my - drag.offY)
  end

  -- Panel
  Susano.DrawRectFilled(x, y, w, h, 0.03,0.03,0.03, 0.92, 18)
  drawNeonBorder(x, y, w, h, 1.0, 0.10, 0.10)

  -- Header
  Susano.DrawRectFilled(x, y, w, UI.headerH, 0.08,0.00,0.00, 1.0, 18)
  Susano.DrawRectFilled(x, y + UI.headerH - 5, w, 5, 0.85,0.05,0.05, 1.0, 0)
  Susano.DrawText(x + 22, y + 38, "DNB", 30, 1.0,0.12,0.12, 1.0)

  local subtitle = (menu.state == "main") and "Main menu" or ("Menu: " .. tostring(menu.currentSub))
  Susano.DrawText(x + 22, y + UI.headerH + 18, subtitle, 16, 0.85,0.85,0.85, 0.95)
  Susano.DrawText(x + 22, y + UI.headerH + 42, ("Toggle: %s"):format(keyName(toggleKey)), 14, 0.85,0.85,0.85, 0.75)

  -- List
  local list = getList()
  local listX = x + UI.pad
  local listY = y + UI.headerH + 78
  local listW = w - (UI.pad * 2)

  local targetY = listY + (menu.selected - 1) * UI.itemH
  if highlightY == nil then highlightY = targetY end
  highlightY = lerp(highlightY, targetY, 0.22)

  Susano.DrawRectFilled(listX, highlightY, listW, UI.itemH, 0.85,0.05,0.05, 1.0, 10)
  Susano.DrawRect(listX, highlightY, listW, UI.itemH, 1.0,0.16,0.16, 0.65, 2.0)

  for i, label in ipairs(list) do
    local iy = listY + (i - 1) * UI.itemH
    Susano.DrawRectFilled(listX, iy, listW, UI.itemH, 0.07,0.07,0.07, 0.78, 10)
    Susano.DrawText(listX + 16, iy + 26, label, 16, 1,1,1, 1)

    if menu.state == "main" then
      Susano.DrawText(listX + listW - 18, iy + 26, ">", 16, 1.0,0.25,0.25, 1.0)
    end
  end

  Susano.DrawText(x + 22, y + h - 24, "Delete: Back  |  Esc: Close  |  Drag: Header", 14, 0.85,0.85,0.85, 0.70)

  Susano.SubmitFrame()
end

-- ================================
-- MAIN LOOP
-- ================================
Citizen.CreateThread(function()
  Citizen.Wait(1200)

  updateScreenSize()
  recenter()

  -- Overlay ON for bind/menu
  Susano.EnableOverlay(true)

  while true do
    Citizen.Wait(0)
    local now = GetGameTimer()

    -- ===== Bind flow =====
    if not toggleKey then
      if bind.stage == "device" then
        drawBindDevice()
      else
        local vk = drawBindKey()
        if vk then
          toggleKey = vk
          menu.open = true
          menu.state = "main"
          menu.currentSub = nil
          menu.selected = 1
          highlightY = nil
          recenter()
          Susano.EnableOverlay(true)
        end
      end
      goto continue
    end

    -- ===== Toggle menu =====
    if keyPressed(toggleKey) then
      menu.open = not menu.open
      Susano.EnableOverlay(menu.open)
      highlightY = nil
    end

    if not menu.open then
      goto continue
    end

    -- ===== Close =====
    if keyPressed(VK.ESC) then
      menu.open = false
      Susano.EnableOverlay(false)
      goto continue
    end

    -- ===== Nav =====
    if repeatKey(VK.UP, repUp, now) then
      menu.selected = menu.selected - 1
      clampSelected()
    end
    if repeatKey(VK.DOWN, repDn, now) then
      menu.selected = menu.selected + 1
      clampSelected()
    end

    -- Enter submenu
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

    -- Back submenu
    if keyPressed(VK.DELETE) and menu.state == "submenu" then
      menu.state = "main"
      menu.currentSub = nil
      menu.selected = 1
      highlightY = nil
    end

    -- Draw menu
    drawMenu()

    ::continue::
  end
end)
