-- ================================
-- DNB MENU (Susano) - FIXED
-- - Bind: Keyboard/Mouse -> Press key -> Shows selected -> Saves
-- - Centered (manual screen size)
-- - Text centered in buttons (GetTextWidth)
-- - Smooth nav + Delete = Back
-- - Drag header (mouse) optional, does not affect arrows
-- ================================

-- ✅ METS TA RESOLUTION ICI (IMPORTANT POUR LE CENTRE)
local SCREEN_W, SCREEN_H = 1920, 1080   -- ex: 2560,1440 ou 3440,1440

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
}

-- ========== Input cache (1 lecture par frame) ==========
local inputCache = { frame = -1, down = {}, pressed = {} }

local function frameId()
  return GetGameTimer()
end

local function getKeyState(vk)
  local fid = frameId()
  if inputCache.frame ~= fid then
    inputCache.frame = fid
    inputCache.down = {}
    inputCache.pressed = {}
  end
  if inputCache.down[vk] == nil then
    local down, pressed = Susano.GetAsyncKeyState(vk)
    inputCache.down[vk] = (down == true)
    inputCache.pressed[vk] = (pressed == true)
  end
  return inputCache.down[vk], inputCache.pressed[vk]
end

local function keyDown(vk) local d,p = getKeyState(vk); return d end
local function keyPressed(vk) local d,p = getKeyState(vk); return p end

-- Smooth repeat
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

-- ========== Visual helpers ==========
local function lerp(a,b,t) return a+(b-a)*t end

local function drawNeonBorder(x, y, w, h, r, g, b)
  Susano.DrawRect(x - 4, y - 4, w + 8, h + 8, r, g, b, 0.08, 7.0)
  Susano.DrawRect(x - 3, y - 3, w + 6, h + 6, r, g, b, 0.12, 5.0)
  Susano.DrawRect(x - 2, y - 2, w + 4, h + 4, r, g, b, 0.16, 3.5)
  Susano.DrawRect(x - 1, y - 1, w + 2, h + 2, r, g, b, 0.22, 2.5)
  Susano.DrawRect(x, y, w, h, r, g, b, 0.95, 1.5)
end

local function textCenterX(x, w, text, size)
  local tw = Susano.GetTextWidth(text, size)
  return x + (w - tw) / 2
end

local function keyName(vk)
  if not vk then return "None" end
  if vk >= 0x41 and vk <= 0x5A then return string.char(vk) end
  if vk >= 0x30 and vk <= 0x39 then return string.char(vk) end
  if vk >= 0x70 and vk <= 0x7B then return "F" .. tostring(vk - 0x6F) end
  local map = {
    [VK.LBUTTON]="Mouse 1",[VK.RBUTTON]="Mouse 2",[VK.MBUTTON]="Mouse 3",
    [VK.XBUTTON1]="Mouse 4",[VK.XBUTTON2]="Mouse 5",
    [VK.DELETE]="Delete",[VK.ESC]="Esc",[VK.ENTER]="Enter"
  }
  return map[vk] or ("VK 0x%02X"):format(vk)
end

-- ========== SUPER IMPORTANT: scan ALL keys ==========
local function scanAnyKeyPressed(excludeMouse)
  for vk = 0x01, 0xFE do
    if excludeMouse then
      if vk ~= VK.LBUTTON and vk ~= VK.RBUTTON and vk ~= VK.MBUTTON and vk ~= VK.XBUTTON1 and vk ~= VK.XBUTTON2 then
        if keyPressed(vk) then return vk end
      end
    else
      if keyPressed(vk) then return vk end
    end
  end
  return nil
end

-- ========== UI layout ==========
local UI = {
  w = 520,
  h = 560,
  x = math.floor((SCREEN_W - 520)/2),
  y = math.floor((SCREEN_H - 560)/2),
  headerH = 74,
  pad = 18,
  itemH = 40
}

-- Drag header (optionnel)
local drag = { active=false, offX=0, offY=0 }

-- ========== Bind state ==========
local toggleKey = nil
local bind = {
  stage = "device", -- device -> key -> done
  deviceIndex = 1,  -- 1 keyboard, 2 mouse
  device = "keyboard",
  pickedText = nil,
  pickedUntil = 0
}

-- ========== Menu state ==========
local menu = {
  open = false,
  state = "main",
  currentSub = nil,
  selected = 1,
  items = {"Player","Server","Weapon","Combat","Vehicle","Visual","Miscellaneous","Settings","Search"},
  submenus = {
    Player = {"Godmode","Heal","Teleport","Back"},
    Server = {"Restart","Weather","Time","Back"},
    Weapon = {"Give Weapon","Infinite Ammo","Back"},
  }
}

local function getList()
  if menu.state == "main" then return menu.items end
  return menu.submenus[menu.currentSub] or {"Back"}
end

local function clampSelected()
  local list = getList()
  if menu.selected < 1 then menu.selected = #list end
  if menu.selected > #list then menu.selected = 1 end
end

local highlightY = nil
local repUp = { next=0, firstDelay=220, repeatRate=55 }
local repDn = { next=0, firstDelay=220, repeatRate=55 }

-- ========== Draw: bind device ==========
local function drawBindDevice()
  Susano.BeginFrame()

  local w,h = 620, 240
  local x = math.floor((SCREEN_W - w)/2)
  local y = math.floor((SCREEN_H - h)/2)

  Susano.DrawRectFilled(x,y,w,h, 0.03,0.03,0.03, 0.92, 14)
  drawNeonBorder(x,y,w,h, 1.0,0.12,0.12)

  Susano.DrawRectFilled(x,y,w,56, 0.08,0.00,0.00, 1.0, 14)
  Susano.DrawRectFilled(x,y+52,w,4, 0.85,0.05,0.05, 1.0, 0)

  Susano.DrawText(x+20, y+32, "DNB", 28, 1.0,0.12,0.12, 1.0)
  Susano.DrawText(x+20, y+88, "Menu Selection", 18, 1,1,1,1)

  if keyPressed(VK.LEFT) or keyPressed(VK.RIGHT) then
    bind.deviceIndex = (bind.deviceIndex==1) and 2 or 1
  end
  bind.device = (bind.deviceIndex==1) and "keyboard" or "mouse"

  local btnY = y+125
  local gap = 18
  local btnW = (w - 36 - gap)/2
  local btnH = 52
  local kx = x+18
  local mx = kx + btnW + gap

  local kSel = (bind.deviceIndex==1)
  Susano.DrawRectFilled(kx,btnY,btnW,btnH, kSel and 0.16 or 0.08, 0,0, 0.95, 12)
  Susano.DrawRect(kx,btnY,btnW,btnH, 1.0,0.16,0.16, kSel and 0.90 or 0.35, 2.0)
  Susano.DrawText(textCenterX(kx,btnW,"Keyboard",18), btnY+33, "Keyboard", 18, 1,1,1,1)

  local mSel = (bind.deviceIndex==2)
  Susano.DrawRectFilled(mx,btnY,btnW,btnH, mSel and 0.16 or 0.08, 0,0, 0.95, 12)
  Susano.DrawRect(mx,btnY,btnW,btnH, 1.0,0.16,0.16, mSel and 0.90 or 0.35, 2.0)
  Susano.DrawText(textCenterX(mx,btnW,"Mouse",18), btnY+33, "Mouse", 18, 1,1,1,1)

  Susano.DrawText(x+20, y+220, "ENTER: choisir", 16, 0.85,0.85,0.85, 0.95)

  if keyPressed(VK.ENTER) then
    bind.stage = "key"
  end

  Susano.SubmitFrame()
end

-- ========== Draw: bind key (shows selected) ==========
local function drawBindKey()
  Susano.BeginFrame()

  local w,h = 620, 240
  local x = math.floor((SCREEN_W - w)/2)
  local y = math.floor((SCREEN_H - h)/2)

  Susano.DrawRectFilled(x,y,w,h, 0.03,0.03,0.03, 0.92, 14)
  drawNeonBorder(x,y,w,h, 1.0,0.12,0.12)

  Susano.DrawRectFilled(x,y,w,56, 0.08,0.00,0.00, 1.0, 14)
  Susano.DrawRectFilled(x,y+52,w,4, 0.85,0.05,0.05, 1.0, 0)

  Susano.DrawText(x+20, y+32, "DNB", 28, 1.0,0.12,0.12, 1.0)

  local line = ("Appuie sur une touche (%s) ..."):format(bind.device)
  Susano.DrawText(x+20, y+108, line, 18, 1,1,1,1)
  Susano.DrawText(x+20, y+220, "ESC: retour", 16, 0.85,0.85,0.85, 0.95)

  local now = GetGameTimer()

  -- Show what we captured
  if bind.pickedText and now < bind.pickedUntil then
    Susano.DrawText(x+20, y+150, ("Selected: %s"):format(bind.pickedText), 18, 1.0,0.25,0.25, 1.0)
  end

  if keyPressed(VK.ESC) then
    bind.stage = "device"
    Susano.SubmitFrame()
    return nil
  end

  -- Capture ANY pressed key
  local vk = nil
  if bind.device == "keyboard" then
    vk = scanAnyKeyPressed(true)     -- exclude mouse buttons
  else
    vk = scanAnyKeyPressed(false)    -- includes mouse buttons
  end

  if vk then
    bind.pickedText = keyName(vk)
    bind.pickedUntil = now + 600     -- show for 0.6s
  end

  Susano.SubmitFrame()
  return vk
end

-- ========== Draw menu ==========
local function drawMenu()
  Susano.BeginFrame()

  local x,y,w,h = UI.x, UI.y, UI.w, UI.h

  -- Drag header (mouse only, arrows unaffected)
  local cur = Susano.GetCursorPos()
  local mx,my = cur.x, cur.y
  local hoverHeader = (mx>=x and mx<=x+w and my>=y and my<=y+UI.headerH)

  if keyPressed(VK.LBUTTON) and hoverHeader then
    drag.active = true
    drag.offX = mx - UI.x
    drag.offY = my - UI.y
  end
  if not keyDown(VK.LBUTTON) then drag.active = false end
  if drag.active then
    UI.x = math.floor(mx - drag.offX)
    UI.y = math.floor(my - drag.offY)
  end

  Susano.DrawRectFilled(x,y,w,h, 0.03,0.03,0.03, 0.92, 18)
  drawNeonBorder(x,y,w,h, 1.0,0.10,0.10)

  Susano.DrawRectFilled(x,y,w,UI.headerH, 0.08,0.00,0.00, 1.0, 18)
  Susano.DrawRectFilled(x,y+UI.headerH-5,w,5, 0.85,0.05,0.05, 1.0, 0)

  Susano.DrawText(x+22, y+38, "DNB", 30, 1.0,0.12,0.12, 1.0)

  local subtitle = (menu.state=="main") and "Main menu" or ("Menu: "..tostring(menu.currentSub))
  Susano.DrawText(x+22, y+UI.headerH+18, subtitle, 16, 0.85,0.85,0.85, 0.95)
  Susano.DrawText(x+22, y+UI.headerH+42, ("Toggle: %s"):format(keyName(toggleKey)), 14, 0.85,0.85,0.85, 0.75)

  local list = getList()
  local listX = x + UI.pad
  local listY = y + UI.headerH + 78
  local listW = w - UI.pad*2

  local targetY = listY + (menu.selected-1)*UI.itemH
  if not highlightY then highlightY = targetY end
  highlightY = lerp(highlightY, targetY, 0.22)

  Susano.DrawRectFilled(listX, highlightY, listW, UI.itemH, 0.85,0.05,0.05, 1.0, 10)
  Susano.DrawRect(listX, highlightY, listW, UI.itemH, 1.0,0.16,0.16, 0.65, 2.0)

  for i,label in ipairs(list) do
    local iy = listY + (i-1)*UI.itemH
    Susano.DrawRectFilled(listX, iy, listW, UI.itemH, 0.07,0.07,0.07, 0.78, 10)
    Susano.DrawText(listX+16, iy+26, label, 16, 1,1,1, 1)
    if menu.state=="main" then
      Susano.DrawText(listX+listW-18, iy+26, ">", 16, 1.0,0.25,0.25, 1.0)
    end
  end

  Susano.DrawText(x+22, y+h-24, "Delete: Back | Esc: Close | Drag: Header", 14, 0.85,0.85,0.85, 0.70)

  Susano.SubmitFrame()
end

-- ========== MAIN ==========
Citizen.CreateThread(function()
  Citizen.Wait(800)

  Susano.EnableOverlay(true)

  while true do
    Citizen.Wait(0)
    local now = GetGameTimer()

    -- Bind flow
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
          Susano.EnableOverlay(true)
        end
      end
      goto continue
    end

    -- Toggle menu
    if keyPressed(toggleKey) then
      menu.open = not menu.open
      Susano.EnableOverlay(menu.open)
      highlightY = nil
    end

    if not menu.open then goto continue end

    -- Close
    if keyPressed(VK.ESC) then
      menu.open = false
      Susano.EnableOverlay(false)
      goto continue
    end

    -- Nav (smooth repeat)
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
      if menu.state=="main" then
        local name = menu.items[menu.selected]
        if menu.submenus[name] then
          menu.state="submenu"
          menu.currentSub=name
          menu.selected=1
          highlightY=nil
        end
      else
        local list=getList()
        if list[menu.selected]=="Back" then
          menu.state="main"
          menu.currentSub=nil
          menu.selected=1
          highlightY=nil
        end
      end
    end

    -- Back submenu (Delete)
    if keyPressed(VK.DELETE) and menu.state=="submenu" then
      menu.state="main"
      menu.currentSub=nil
      menu.selected=1
      highlightY=nil
    end

    drawMenu()

    ::continue::
  end
end)
