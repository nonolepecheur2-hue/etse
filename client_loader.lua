-- DNB MENU - NO BIND SCREEN (FORCED INSERT)
-- Version tag: DNB_NO_BIND_V1

local VK = {
  UP     = 0x26,
  DOWN   = 0x28,
  RIGHT  = 0x27,
  ENTER  = 0x0D,
  ESC    = 0x1B,
  DELETE = 0x2E,
  INSERT = 0x2D,
  LBUTTON= 0x01,
}

-- input bool cast (handles 1/0)
local frame = 0
local cache = { down={}, pressed={} }

local function beginFrame()
  frame = frame + 1
  cache.down = {}
  cache.pressed = {}
end

local function keyState(vk)
  if cache.down[vk] == nil then
    local down, pressed = Susano.GetAsyncKeyState(vk)
    cache.down[vk] = not not down
    cache.pressed[vk] = not not pressed
  end
  return cache.down[vk], cache.pressed[vk]
end

local function keyDown(vk) local d,p = keyState(vk); return d end
local function keyPressed(vk) local d,p = keyState(vk); return p end

local function lerp(a,b,t) return a + (b-a)*t end

-- Resolution (best effort)
local screenW, screenH = 1920, 1080
local function updateRes()
  if type(GetActiveScreenResolution)=="function" then
    local w,h = GetActiveScreenResolution()
    if w and h and w>0 and h>0 then screenW,screenH=w,h return end
  end
  if type(GetScreenResolution)=="function" then
    local w,h = GetScreenResolution()
    if w and h and w>0 and h>0 then screenW,screenH=w,h return end
  end
end

local BASE_H = 1080
local function scale() return screenH/BASE_H end
local function clamp(v,a,b) if v<a then return a elseif v>b then return b else return v end end

local function cursorPixels()
  local p = Susano.GetCursorPos()
  if not p then return 0,0 end
  local x,y = p.x, p.y
  if x<=1.0 and y<=1.0 then return x*screenW, y*screenH end
  return x,y
end

local function neon(x,y,w,h)
  Susano.DrawRect(x-4,y-4,w+8,h+8, 1.0,0.12,0.12, 0.08, 7.0)
  Susano.DrawRect(x-2,y-2,w+4,h+4, 1.0,0.12,0.12, 0.16, 3.5)
  Susano.DrawRect(x,y,w,h,         1.0,0.12,0.12, 0.95, 1.5)
end

-- UI + menu
local UI = { x=0,y=0,w=0,h=0, headerH=0,pad=0,itemH=0, fTitle=0,fSmall=0 }
local userMoved=false
local drag={active=false, offX=0, offY=0}

local function layout()
  updateRes()
  local s = scale()
  UI.w = math.floor(520*s)
  UI.h = math.floor(560*s)
  UI.headerH = math.floor(74*s)
  UI.pad = math.floor(18*s)
  UI.itemH = math.floor(40*s)
  UI.fTitle = clamp(math.floor(30*s), 18, 40)
  UI.fSmall = clamp(math.floor(14*s), 12, 22)
  if not userMoved then
    UI.x = math.floor((screenW-UI.w)/2)
    UI.y = math.floor((screenH-UI.h)/2)
  end
end

local menu = {
  open=false,
  state="main",
  currentSub=nil,
  selected=1,
  items={"Player","Server","Weapon","Combat","Vehicle","Visual","Miscellaneous","Settings","Search"},
  submenus={
    Player={"Godmode","Heal","Teleport","Back"},
    Server={"Restart","Weather","Time","Back"},
    Weapon={"Give Weapon","Infinite Ammo","Back"},
  }
}

local function getList()
  if menu.state=="main" then return menu.items end
  return menu.submenus[menu.currentSub] or {"Back"}
end

local function clampSel()
  local l = getList()
  if menu.selected<1 then menu.selected=#l end
  if menu.selected>#l then menu.selected=1 end
end

local repUp={next=0, firstDelay=240, repeatRate=55}
local repDn={next=0, firstDelay=240, repeatRate=55}
local function repeatKey(vk, st, now)
  if keyPressed(vk) then st.next=now+st.firstDelay return true end
  if keyDown(vk) and now>=st.next then st.next=now+st.repeatRate return true end
  if not keyDown(vk) then st.next=0 end
  return false
end

local hiY=nil

local function draw()
  Susano.BeginFrame()

  local s=scale()
  local x,y,w,h=UI.x,UI.y,UI.w,UI.h

  -- drag header
  local mx,my=cursorPixels()
  local hover = (mx>=x and mx<=x+w and my>=y and my<=y+UI.headerH)
  if keyPressed(VK.LBUTTON) and hover then
    drag.active=true
    drag.offX=mx-UI.x
    drag.offY=my-UI.y
    userMoved=true
  end
  if not keyDown(VK.LBUTTON) then drag.active=false end
  if drag.active then
    UI.x=math.floor(mx-drag.offX)
    UI.y=math.floor(my-drag.offY)
  end

  Susano.DrawRectFilled(x,y,w,h, 0.03,0.03,0.03, 0.92, 18)
  neon(x,y,w,h)

  Susano.DrawRectFilled(x,y,w,UI.headerH, 0.08,0.00,0.00, 1.0, 18)
  Susano.DrawRectFilled(x,y+UI.headerH-math.floor(5*s),w,math.floor(5*s), 0.85,0.05,0.05, 1.0, 0)

  Susano.DrawText(x+UI.pad, y+math.floor(UI.headerH*0.60), "DNB", UI.fTitle, 1.0,0.12,0.12, 1.0)

  local subtitle = (menu.state=="main") and "Main menu" or ("Menu: "..tostring(menu.currentSub))
  Susano.DrawText(x+UI.pad, y+UI.headerH+math.floor(18*s), subtitle, UI.fSmall+2, 0.85,0.85,0.85, 0.95)
  Susano.DrawText(x+UI.pad, y+UI.headerH+math.floor(42*s), "Toggle: INSERT", UI.fSmall, 0.85,0.85,0.85, 0.75)

  local list=getList()
  local lx=x+UI.pad
  local ly=y+UI.headerH+math.floor(78*s)
  local lw=w-UI.pad*2

  local target=ly+(menu.selected-1)*UI.itemH
  if not hiY then hiY=target end
  hiY=lerp(hiY,target,0.22)

  Susano.DrawRectFilled(lx,hiY,lw,UI.itemH, 0.85,0.05,0.05, 1.0, 10)

  for i,label in ipairs(list) do
    local iy=ly+(i-1)*UI.itemH
    Susano.DrawRectFilled(lx,iy,lw,UI.itemH, 0.07,0.07,0.07, 0.78, 10)
    Susano.DrawText(lx+math.floor(16*s), iy+math.floor(UI.itemH*0.65), label, UI.fSmall+2, 1,1,1,1)
    if menu.state=="main" then
      Susano.DrawText(lx+lw-math.floor(18*s), iy+math.floor(UI.itemH*0.65), ">", UI.fSmall+2, 1.0,0.25,0.25,1.0)
    end
  end

  Susano.SubmitFrame()
end

Citizen.CreateThread(function()
  Citizen.Wait(400)
  Susano.Notify("Loaded: DNB_NO_BIND_V1")
  layout()
  Susano.EnableOverlay(false)

  while true do
    Citizen.Wait(0)
    beginFrame()
    layout()
    local now=GetGameTimer()

    -- Toggle INSERT
    if keyPressed(VK.INSERT) then
      menu.open = not menu.open
      Susano.EnableOverlay(menu.open)
      hiY=nil
    end

    if not menu.open then goto continue end

    -- Close ESC
    if keyPressed(VK.ESC) then
      menu.open=false
      Susano.EnableOverlay(false)
      goto continue
    end

    -- Nav
    if repeatKey(VK.UP, repUp, now) then menu.selected=menu.selected-1 clampSel() end
    if repeatKey(VK.DOWN, repDn, now) then menu.selected=menu.selected+1 clampSel() end

    -- Enter / submenu
    if keyPressed(VK.RIGHT) or keyPressed(VK.ENTER) then
      if menu.state=="main" then
        local name=menu.items[menu.selected]
        if menu.submenus[name] then
          menu.state="submenu"
          menu.currentSub=name
          menu.selected=1
          hiY=nil
        end
      else
        local list=getList()
        if list[menu.selected]=="Back" then
          menu.state="main"
          menu.currentSub=nil
          menu.selected=1
          hiY=nil
        end
      end
    end

    -- Back DELETE
    if keyPressed(VK.DELETE) and menu.state=="submenu" then
      menu.state="main"
      menu.currentSub=nil
      menu.selected=1
      hiY=nil
    end

    draw()
    ::continue::
  end
end)
