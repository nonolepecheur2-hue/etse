-- ================================
-- DNB MENU (Susano) - INSERT TOGGLE (NO KEYBIND MENU)
-- Toggle: INSERT (0x2D)
-- Controls:
--   ↑ ↓ : navigate (smooth repeat)
--   → / Enter : enter submenu
--   Delete : back submenu
--   Esc : close menu
--   Drag header : move menu (mouse) - doesn't affect arrows
-- Responsive + centered
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
  INSERT   = 0x2D,

  LBUTTON  = 0x01,
  RBUTTON  = 0x02,
  MBUTTON  = 0x04,
  XBUTTON1 = 0x05,
  XBUTTON2 = 0x06,
}

-- ================================
-- INPUT CACHE PER FRAME
-- NOTE: Susano.GetAsyncKeyState may return 1/0, not true/false -> cast with not not
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
    inputCache.down[vk] = not not down
    inputCache.pressed[vk] = not not pressed
  end
  return inputCache.down[vk], inputCache.pressed[vk]
end

local function keyDown(vk) local d,p = getKeyState(vk); return d end
local function keyPressed(vk) local d,p = getKeyState(vk); return p end

-- Smooth repeat for ↑/↓
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

-- ================================
-- RESOLUTION + SCALE (responsive)
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

-- cursor pos: some Susano builds return normalized 0..1
local function cursorPixels()
  local p = Susano.GetCursorPos()
  if not p then return 0, 0 end
  local x, y = p.x, p.y
  if x <= 1.0 and y <= 1.0 then
    return x * screenW, y * screenH
  end
  return x, y
end

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

-- ================================
-- UI LAYOUT
-- ================================
local UI = { x=0,y=0,w=0,h=0, headerH=0,pad=0,itemH=0, fontTitle=0,fontSmall=0 }
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
  UI.fontSmall = clamp(math.floor(14*s), 12, 22)

  if not userMoved then
    UI.x = math.floor((screenW - UI.w)/2)
    UI.y = math.floor((screenH - UI.h)/2)
  end
end

-- Drag
local drag = { active=false, offX=0, offY=0 }

-- ================================
-- MENU STATE
-- ================================
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
-- DRAW MENU
-- ================================
local function drawMenu()
  Susano.BeginFrame()

  local s = scale()
  local x,y,w,h = UI.x, UI.y, UI.w, UI.h

  -- Drag header only
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

  -- panel + neon
  Susano.DrawRectFilled(x,y,w,h, 0.03,0.03,0.03, 0.92, 18)
  drawNeonBorder(x,y,w,h, 1.0,0.10,0.10)

  -- header
  Susano.DrawRectFilled(x,y,w,UI.headerH, 0.08,0.00,0.00, 1.0, 18)
  Susano.DrawRectFilled(x,y+UI.headerH-math.floor(5*s),w,math.floor(5*s), 0.85,0.05,0.05, 1.0, 0)

  Susano.DrawText(x+UI.pad, y+math.floor(UI.headerH*0.60), "DNB", UI.fontTitle, 1.0,0.12,0.12, 1.0)

  local subtitle = (menu.state=="main") and "Main menu" or ("Menu: "..tostring(menu.currentSub))
  Susano.DrawText(x+UI.pad, y+UI.headerH+math.floor(18*s), subtitle, UI.fontSmall+2, 0.85,0.85,0.85, 0.95)
  Susano.DrawText(x+UI.pad, y+UI.headerH+math.floor(42*s), "Toggle: INSERT", UI.fontSmall, 0.85,0.85,0.85, 0.75)

  -- list
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

  -- Start closed: only open on INSERT
  menu.open = false
  Susano.EnableOverlay(false)

  while true do
    Citizen.Wait(0)

    beginInputFrame()
    computeUILayout()
    local now = GetGameTimer()

    -- Toggle (INSERT)
    if keyPressed(VK.INSERT) then
      menu.open = not menu.open
      Susano.EnableOverlay(menu.open)
      highlightY = nil
    end

    if not menu.open then
      goto continue
    end

    -- Close (Esc)
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

    -- Enter submenu / select
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
        if list[menu.selected] == "Back" then
          menu.state="main"
          menu.currentSub=nil
          menu.selected=1
          highlightY=nil
        end
      end
    end

    -- Back (Delete)
    if keyPressed(VK.DELETE) and menu.state=="submenu" then
      menu.state="main"
      menu.currentSub=nil
      menu.selected=1
      highlightY=nil
    end

    -- Draw
    drawMenu()

    ::continue::
  end
end)
