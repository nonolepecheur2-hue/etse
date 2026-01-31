-- ================================
-- DNB MENU (Susano) - FULL RESPONSIVE (FIX FINAL)
-- - Fix keybind: GetAsyncKeyState may return 1/0 (not true/false)
-- - Responsive + centered
-- - Text centered in buttons
-- - Bind shows Selected: <key> and SAVES
-- - Delete=Back, Esc=Close
-- - Drag header (cursor pos is normalized -> converted to pixels)
-- ================================

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

-- ================================
-- INPUT CACHE PER FRAME (and FIX bool cast)
-- ================================
local frameCounter = 0
local inputCache = { down = {}, pressed = {} }

local function beginInputFrame()
  frameCounter = frameCounter + 1
  inputCache.down = {}
  inputCache.pressed = {}
end

local function getKeyState(vk)
  if inputCache.down[vk] == nil then
    local down, pressed = Susano.GetAsyncKeyState(vk)
    -- IMPORTANT: build may return 1/0 -> convert to boolean properly
    inputCache.down[vk] = not not down
    inputCache.pressed[vk] = not not pressed
  end
  return inputCache.down[vk], inputCache.pressed[vk]
end

local function keyDown(vk) local d,p = getKeyState(vk); return d end
local function keyPressed(vk) local d,p = getKeyState(vk); return p end

-- ================================
-- RESOLUTION + SCALE
-- ================================
local screenW, screenH = 1920, 1080

local function tryGetRes()
  if type(GetActiveScreenResolution) == "function" then
    local w, h = GetActiveScreenResolution()
    if w and h and w > 0 and h > 0 then return w, h end
  end
  if type(GetScreenResolution) == "function" then
    local w, h = GetScreenResolution()
    if w and h and w > 0 and h > 0 then return w, h end
  end
  if type(GetScreenActiveResolution) == "function" then
    local w, h = GetScreenActiveResolution()
    if w and h and w > 0 and h > 0 then return w, h end
  end
  return nil, nil
end

local function updateResolution()
  local w, h = tryGetRes()
  if w and h then
    screenW, screenH = w, h
  end
end

local BASE_H = 1080
local function scale() return screenH / BASE_H end
local function clamp(v,a,b) if v<a then return a elseif v>b then return b else return v end end
local function lerp(a,b,t) return a + (b-a)*t end

-- ================================
-- VISUAL
-- ================================
local function drawNeonBorder(x, y, w, h, r, g, b)
  Susano.DrawRect(x - 4, y - 4, w + 8, h + 8, r, g, b, 0.08, 7.0)
  Susano.DrawRect(x - 3, y - 3, w + 6, h + 6, r, g, b, 0.12, 5.0)
  Susano.DrawRect(x - 2, y - 2, w + 4, h + 4, r, g, b, 0.16, 3.5)
  Susano.DrawRect(x - 1, y - 1, w + 2, h + 2, r, g, b, 0.22, 2.5)
  Susano.DrawRect(x, y, w, h, r, g, b, 0.95, 1.5)
end

local function getTextWidthSafe(text, size)
  if Susano.GetTextWidth then
    return Susano.GetTextWidth(text, size)
  end
  return #text * (size * 0.55)
end

local function centeredTextX(x, w, text, size)
  local tw = getTextWidthSafe(text, size)
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

-- ================================
-- KEY SCAN: DOWN + DEBOUNCE
-- ================================
local lastDown = {}
local function scanAnyKeyDownOnce(excludeMouse)
  for vk = 0x01, 0xFE do
    if excludeMouse then
      if vk == VK.LBUTTON or vk == VK.RBUTTON or vk == VK.MBUTTON or vk == VK.XBUTTON1 or vk == VK.XBUTTON2 then
        goto continue
      end
    end

    local d = keyDown(vk)
    if d and not lastDown[vk] then
      lastDown[vk] = true
      return vk
    end
    if not d then
      lastDown[vk] = false
    end

    ::continue::
  end
  return nil
end

-- ================================
-- UI LAYOUT (responsive + centered)
-- ================================
local UI = { x=0,y=0,w=0,h=0, headerH=0,pad=0,itemH=0, fontTitle=0,fontText=0,fontSmall=0 }
local userMoved = false

local function computeUILayout()
  updateResolution()
  local s = scale()

  UI.w = math.floor(520*s)
  UI.h = math.floor(560*s)
  UI.headerH = math.floor(74*s)
  UI.pad = math.floor(18*s)
  UI.itemH = math.floor(40*s)

  UI.fontTitle = clamp(math.floor(30*s), 18, 40)
  UI.fontText  = clamp(math.floor(18*s), 14, 28)
  UI.fontSmall = clamp(math.floor(14*s), 12, 22)

  if not userMoved then
    UI.x = math.floor((screenW - UI.w)/2)
    UI.y = math.floor((screenH - UI.h)/2)
  end
end

-- Cursor pos in Susano is normalized (0..1). Convert to pixels:
local function cursorPixels()
  local p = Susano.GetCursorPos()
  return p.x * screenW, p.y * screenH
end

-- Repeat ↑/↓
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

-- Drag
local drag = { active=false, offX=0, offY=0 }

-- ================================
-- STATES
-- ================================
local toggleKey = nil

local bind = {
  stage = "device",      -- device -> key
  deviceIndex = 1,
  device = "keyboard",
  lastPick = nil,
  lastPickUntil = 0
}

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
  if menu.state=="main" then return menu.items end
  return menu.submenus[menu.currentSub] or {"Back"}
end

local function clampSelected()
  local list = getList()
  if menu.selected < 1 then menu.selected = #list end
  if menu.selected > #list then menu.selected = 1 end
end

local highlightY = nil
local repUp = { next=0, firstDelay=240, repeatRate=55 }
local repDn = { next=0, firstDelay=240, repeatRate=55 }

-- ================================
-- DRAW: DEVICE SELECT
-- ================================
local function drawBindDevice()
  local s = scale()
  local w = math.floor(620*s)
  local h = math.floor(240*s)
  local x = math.floor((screenW - w)/2)
  local y = math.floor((screenH - h)/2)

  local pad = math.floor(18*s)
  local gap = math.floor(18*s)
  local btnH = math.floor(52*s)
  local btnW = math.floor((w - pad*2 - gap)/2)
  local headerH = math.floor(56*s)
  local underlineH = math.floor(4*s)

  Susano.BeginFrame()

  Susano.DrawRectFilled(x,y,w,h, 0.03,0.03,0.03, 0.92, 14)
  drawNeonBorder(x,y,w,h, 1.0,0.12,0.12)

  Susano.DrawRectFilled(x,y,w,headerH, 0.08,0.00,0.00, 1.0, 14)
  Susano.DrawRectFilled(x,y+headerH-underlineH,w,underlineH, 0.85,0.05,0.05, 1.0, 0)

  Susano.DrawText(x+pad, y+math.floor(headerH*0.62), "DNB", UI.fontTitle, 1.0,0.12,0.12, 1.0)
  Susano.DrawText(x+pad, y+math.floor(92*s), "Menu Selection", UI.fontText, 1,1,1, 1)

  if keyPressed(VK.LEFT) or keyPressed(VK.RIGHT) then
    bind.deviceIndex = (bind.deviceIndex==1) and 2 or 1
  end
  bind.device = (bind.deviceIndex==1) and "keyboard" or "mouse"

  local btnY = y + math.floor(125*s)
  local kx = x + pad
  local mx = kx + btnW + gap

  local function drawButton(bx, label, selected)
    Susano.DrawRectFilled(bx,btnY,btnW,btnH, selected and 0.16 or 0.08, 0.00,0.00, 0.95, 12)
    Susano.DrawRect(bx,btnY,btnW,btnH, 1.0,0.16,0.16, selected and 0.90 or 0.35, 2.0)
    local tx = centeredTextX(bx,btnW,label,UI.fontText)
    Susano.DrawText(tx, btnY + math.floor(btnH*0.62), label, UI.fontText, 1,1,1, 1)
  end

  drawButton(kx, "Keyboard", bind.deviceIndex==1)
  drawButton(mx, "Mouse", bind.deviceIndex==2)

  Susano.DrawText(x+pad, y+h-math.floor(18*s), "ENTER: choisir  |  ESC: quitter", UI.fontSmall, 0.85,0.85,0.85, 0.95)

  if keyPressed(VK.ENTER) then bind.stage = "key" end

  Susano.SubmitFrame()
end

-- ================================
-- DRAW: KEY CAPTURE
-- ================================
local function drawBindKey()
  local s = scale()
  local w = math.floor(620*s)
  local h = math.floor(240*s)
  local x = math.floor((screenW - w)/2)
  local y = math.floor((screenH - h)/2)
  local pad = math.floor(18*s)
  local headerH = math.floor(56*s)
  local underlineH = math.floor(4*s)

  Susano.BeginFrame()

  Susano.DrawRectFilled(x,y,w,h, 0.03,0.03,0.03, 0.92, 14)
  drawNeonBorder(x,y,w,h, 1.0,0.12,0.12)

  Susano.DrawRectFilled(x,y,w,headerH, 0.08,0.00,0.00, 1.0, 14)
  Susano.DrawRectFilled(x,y+headerH-underlineH,w,underlineH, 0.85,0.05,0.05, 1.0, 0)

  Susano.DrawText(x+pad, y+math.floor(headerH*0.62), "DNB", UI.fontTitle, 1.0,0.12,0.12, 1.0)

  local line = ("Appuie sur une touche (%s) ..."):format(bind.device)
  Susano.DrawText(x+pad, y+math.floor(110*s), line, UI.fontText, 1,1,1, 1)
  Susano.DrawText(x+pad, y+h-math.floor(18*s), "ESC: retour", UI.fontSmall, 0.85,0.85,0.85, 0.95)

  local now = GetGameTimer()
  if bind.lastPick and now < bind.lastPickUntil then
    Susano.DrawText(x+pad, y+math.floor(155*s), ("Selected: %s"):format(bind.lastPick), UI.fontText, 1.0,0.25,0.25, 1.0)
  end

  if keyPressed(VK.ESC) then
    bind.stage = "device"
    Susano.SubmitFrame()
    return nil
  end

  local vk
  if bind.device == "keyboard" then
    vk = scanAnyKeyDownOnce(true)
  else
    vk = scanAnyKeyDownOnce(false)
  end

  if vk then
    bind.lastPick = keyName(vk)
    bind.lastPickUntil = now + 650
  end

  Susano.SubmitFrame()
  return vk
end

-- ================================
-- DRAW: MAIN MENU
-- ================================
local function drawMenu()
  Susano.BeginFrame()

  local s = scale()
  local x,y,w,h = UI.x, UI.y, UI.w, UI.h

  -- Drag header (cursor normalized -> pixels)
  local mx,my = cursorPixels()
  local hoverHeader = (mx>=x and mx<=x+w and my>=y and my<=y+UI.headerH)

  if keyPressed(VK.LBUTTON) and hoverHeader then
    drag.active = true
    drag.offX = mx - UI.x
    drag.offY = my - UI.y
    userMoved = true
  end
  if not keyDown(VK.LBUTTON) then drag.active = false end
  if drag.active then
    UI.x = math.floor(mx - drag.offX)
    UI.y = math.floor(my - drag.offY)
  end

  Susano.DrawRectFilled(x,y,w,h, 0.03,0.03,0.03, 0.92, 18)
  drawNeonBorder(x,y,w,h, 1.0,0.10,0.10)

  Susano.DrawRectFilled(x,y,w,UI.headerH, 0.08,0.00,0.00, 1.0, 18)
  Susano.DrawRectFilled(x,y+UI.headerH-math.floor(5*s),w,math.floor(5*s), 0.85,0.05,0.05, 1.0, 0)

  Susano.DrawText(x+UI.pad, y+math.floor(UI.headerH*0.60), "DNB", UI.fontTitle, 1.0,0.12,0.12, 1.0)

  local subtitle = (menu.state=="main") and "Main menu" or ("Menu: "..tostring(menu.currentSub))
  Susano.DrawText(x+UI.pad, y+UI.headerH+math.floor(18*s), subtitle, UI.fontSmall+2, 0.85,0.85,0.85, 0.95)
  Susano.DrawText(x+UI.pad, y+UI.headerH+math.floor(42*s), ("Toggle: %s"):format(keyName(toggleKey)), UI.fontSmall, 0.85,0.85,0.85, 0.75)

  local list = getList()
  local listX = x + UI.pad
  local listY = y + UI.headerH + math.floor(78*s)
  local listW = w - UI.pad*2

  local targetY = listY + (menu.selected-1)*UI.itemH
  if not highlightY then highlightY = targetY end
  highlightY = lerp(highlightY, targetY, 0.22)

  Susano.DrawRectFilled(listX, highlightY, listW, UI.itemH, 0.85,0.05,0.05, 1.0, 10)
  Susano.DrawRect(listX, highlightY, listW, UI.itemH, 1.0,0.16,0.16, 0.65, 2.0)

  for i,label in ipairs(list) do
    local iy = listY + (i-1)*UI.itemH
    Susano.DrawRectFilled(listX, iy, listW, UI.itemH, 0.07,0.07,0.07, 0.78, 10)
    Susano.DrawText(listX+math.floor(16*s), iy+math.floor(UI.itemH*0.65), label, UI.fontSmall+2, 1,1,1, 1)
    if menu.state=="main" then
      Susano.DrawText(listX+listW-math.floor(18*s), iy+math.floor(UI.itemH*0.65), ">", UI.fontSmall+2, 1.0,0.25,0.25, 1.0)
    end
  end

  Susano.DrawText(x+UI.pad, y+h-math.floor(18*s), "Delete: Back | Esc: Close | Drag: Header", UI.fontSmall, 0.85,0.85,0.85, 0.70)

  Susano.SubmitFrame()
end

-- ================================
-- MAIN LOOP
-- ================================
Citizen.CreateThread(function()
  Citizen.Wait(600)
  computeUILayout()
  Susano.EnableOverlay(true)

  while true do
    Citizen.Wait(0)

    beginInputFrame()
    computeUILayout()
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

    -- Nav
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
        local list = getList()
        if list[menu.selected]=="Back" then
          menu.state="main"
          menu.currentSub=nil
          menu.selected=1
          highlightY=nil
        end
      end
    end

    -- Back
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
