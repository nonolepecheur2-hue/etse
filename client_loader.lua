--========================================================
--  SUSANO DRAW MENU - FUTURISTIC NEON (RESPONSIVE)
--  FIXED OPEN/CLOSE (anti-rebond + singleton guard)
--
--  INSERT  : open/close
--  UP/DOWN : navigate
--  RIGHT   : enter
--  LEFT/BACKSPACE/DELETE : back
--========================================================

-- ===== Singleton guard (évite double load via HttpGet/load) =====
if _G.__SUSANO_NEON_MENU__ then return end
_G.__SUSANO_NEON_MENU__ = true

--========================================================
--  Keys
--========================================================
local VK = {
  INSERT = 0x2D,
  UP     = 0x26,
  DOWN   = 0x28,
  LEFT   = 0x25,
  RIGHT  = 0x27,
  BACK   = 0x08,
  DELETE = 0x2E,
}

--========================================================
--  Small utils
--========================================================
local function clamp(x,a,b) if x<a then return a end if x>b then return b end return x end
local function lerp(a,b,t) return a + (b-a)*t end
local function smooth(t) t = clamp(t,0,1); return t*t*(3-2*t) end
local function fract(x) return x - math.floor(x) end
local function textW(str, px) return (Susano.GetTextWidth and Susano.GetTextWidth(str, px)) or 0 end

local function safeCall(fn, ...)
  if fn then return fn(...) end
  return nil
end

--========================================================
--  Input
--========================================================
local function keyPressed(vk)
  local _, pressed = safeCall(Susano.GetAsyncKeyState, vk)
  return pressed == true
end

local function keyDown(vk)
  local down, _ = safeCall(Susano.GetAsyncKeyState, vk)
  return down == true
end

--========================================================
--  Responsive layout helpers
--========================================================
local function getScreen()
  local sw, sh = GetActiveScreenResolution()
  return sw, sh
end

local function uiScale(sw, sh)
  local s = math.min(sw/1920.0, sh/1080.0)
  return clamp(s, 0.70, 1.40)
end

local function centeredRect(sw, sh, w, h)
  return (sw - w) * 0.5, (sh - h) * 0.5
end

--========================================================
--  Menu state
--========================================================
local menu = {
  open = false,
  stack = { "Main menu" },
  selected = 1,
  scroll = 0,

  lastNavMs = 0,
  repeatDelayMs = 120,

  anim = { t = 0.0, target = 0.0 },

  categories = {
    { name = "Player" },
    { name = "Server" },
    { name = "Weapon" },
    { name = "Combat" },
    { name = "Vehicle" },
    { name = "Visual" },
    { name = "Miscellaneous" },
    { name = "Settings" },
    { name = "Search" },
  },
}

local function pushPage(name) menu.stack[#menu.stack+1] = name end
local function popPage() if #menu.stack > 1 then menu.stack[#menu.stack] = nil end end
local function currentPage() return menu.stack[#menu.stack] end

--========================================================
--  Toggle stability (anti double toggle)
--========================================================
local nextToggleAt = 0
local TOGGLE_COOLDOWN_MS = 250

local function toggleMenu()
  local now = GetGameTimer()
  if now < nextToggleAt then return end
  nextToggleAt = now + TOGGLE_COOLDOWN_MS

  menu.open = not menu.open
  menu.anim.target = menu.open and 1.0 or 0.0

  safeCall(Susano.EnableOverlay, menu.open)

  if not menu.open then
    safeCall(Susano.ResetFrame)
    menu.stack = { "Main menu" }
    menu.selected = 1
    menu.scroll = 0
  end
end

--========================================================
--  Neon visuals
--========================================================
local function shadowRect(x,y,w,h,rounding,alpha)
  if not Susano.DrawRectFilled then return end
  for i=1,12 do
    local a = (0.13 - i*0.009) * alpha
    if a <= 0 then break end
    Susano.DrawRectFilled(x-i, y-i, w+i*2, h+i*2, 0,0,0, a, rounding + i*0.95)
  end
end

local function drawCenteredText(x,y,w,h,txt,size,r,g,b,a)
  if not Susano.DrawText then return end
  local tw = textW(txt, size)
  local tx = x + (w - tw) * 0.5
  local ty = y + h * 0.68
  Susano.DrawText(tx, ty, txt, size, r,g,b,a)
end

local function neonStrokeRect(x,y,w,h,rounding,alpha,thick)
  if not Susano.DrawRectFilled then return end
  -- pseudo-stroke via 4 rectangles (cheap + clean)
  Susano.DrawRectFilled(x, y, w, thick, 0.20,0.85,1.0, 0.25*alpha, rounding)
  Susano.DrawRectFilled(x, y+h-thick, w, thick, 0.95,0.20,1.0, 0.18*alpha, rounding)
  Susano.DrawRectFilled(x, y, thick, h, 0.20,1.0,0.65, 0.18*alpha, rounding)
  Susano.DrawRectFilled(x+w-thick, y, thick, h, 1.0,0.35,0.75, 0.16*alpha, rounding)
end

local function drawScanlines(sw, sh, alpha, s)
  if not Susano.DrawRectFilled then return end
  local now = GetGameTimer() / 1000.0
  local speed = 0.35
  local yOff = fract(now * speed) * 6.0*s
  local step = 6.0*s
  for y = -step, sh + step, step do
    local yy = y + yOff
    Susano.DrawRectFilled(0, yy, sw, 1.0*s, 1,1,1, 0.02*alpha, 0.0)
  end
end

local function drawParticles(x,y,w,h,alpha,s)
  if not Susano.DrawCircle then return end
  local t = GetGameTimer()/1000.0
  for i=1,18 do
    local p = fract(math.sin(i*91.17) * 43758.5453)
    local q = fract(math.sin(i*37.77) * 24634.6345)
    local sp = fract(t * (0.06 + p*0.22) + i*0.13)
    local px = x + (p * w)
    local py = y + (sp * h)
    local r  = (1.2 + q*1.8) * s
    local a  = (0.08 + q*0.10) * alpha
    -- alternate neon hues
    if i % 3 == 0 then
      Susano.DrawCircle(px, py, r, 0.20,0.85,1.0, a, 2.0*s, false)
    elseif i % 3 == 1 then
      Susano.DrawCircle(px, py, r, 1.0,0.25,0.85, a, 2.0*s, false)
    else
      Susano.DrawCircle(px, py, r, 0.25,1.0,0.70, a, 2.0*s, false)
    end
  end
end

local function drawTriLogo(x,y,size,alpha,glow)
  if not Susano.DrawLine then return end
  local cx, cy = x + size*0.5, y + size*0.5
  local r = size*0.42

  if Susano.DrawCircle then
    for i=1,4 do
      Susano.DrawCircle(cx, cy, r+i*1.2, 0.20,0.85,1.0, (0.14 - i*0.025)*alpha*(0.7+glow*0.6), 2.0, false)
    end
  end

  local function L(ax,ay,bx,by, rr,gg,bb, a, th)
    Susano.DrawLine(ax,ay,bx,by, rr,gg,bb, a*alpha, th)
  end

  local a1 = 0.95*(0.75+glow*0.55)
  local th = 2.6

  L(cx, cy-r, cx+r*0.85, cy+r*0.20, 0.20,0.85,1.0, a1, th)
  L(cx+r*0.85, cy+r*0.20, cx-r*0.15, cy+r*0.95, 1.0,0.25,0.85, a1, th)
  L(cx-r*0.15, cy+r*0.95, cx-r*0.85, cy+r*0.20, 0.25,1.0,0.70, a1, th)
  L(cx-r*0.85, cy+r*0.20, cx, cy-r, 0.20,0.85,1.0, a1, th)
end

--========================================================
--  Rendering
--========================================================
local function drawMenu()
  if not (Susano.BeginFrame and Susano.SubmitFrame and Susano.DrawRectFilled and Susano.DrawText) then
    return
  end

  local sw, sh = getScreen()
  local s = uiScale(sw, sh)

  local dt = GetFrameTime()
  menu.anim.t = menu.anim.t + (menu.anim.target - menu.anim.t) * clamp(dt*10.0, 0, 1)
  local openT = smooth(menu.anim.t)
  local alpha = openT

  -- neon pulse
  local t = GetGameTimer()/1000.0
  local pulse = (math.sin(t*2.2) + 1.0) * 0.5
  local glow = lerp(0.25, 0.85, pulse)

  -- responsive panel
  local panelW = clamp(sw * 0.46, 620*s, 980*s)
  local panelH = clamp(sh * 0.58, 460*s, 780*s)
  local scale = lerp(0.92, 1.0, openT)

  panelW = panelW * scale
  panelH = panelH * scale

  local mx, my = centeredRect(sw, sh, panelW, panelH)
  local pad = 18*s
  local rounding = 18*s

  Susano.BeginFrame()

  -- background dim
  Susano.DrawRectFilled(0,0,sw,sh, 0,0,0, 0.38*alpha, 0.0)

  -- scanlines + subtle particles behind panel
  drawScanlines(sw, sh, alpha, s)

  -- shadow + glass panel
  shadowRect(mx,my,panelW,panelH, rounding, alpha)
  Susano.DrawRectFilled(mx,my,panelW,panelH, 0.05,0.06,0.08, 0.90*alpha, rounding)

  -- neon strokes
  neonStrokeRect(mx, my, panelW, panelH, rounding, alpha*(0.85+glow*0.25), 2.0*s)

  -- header
  local headerH = 74*s
  if Susano.DrawRectGradient then
    Susano.DrawRectGradient(mx,my,panelW,headerH,
      0.08,0.10,0.16, 0.92*alpha,
      0.06,0.08,0.12, 0.92*alpha,
      0.04,0.05,0.07, 0.85*alpha,
      0.05,0.06,0.09, 0.85*alpha,
      rounding
    )
  else
    Susano.DrawRectFilled(mx,my,panelW,headerH, 0.07,0.09,0.14, 0.92*alpha, rounding)
  end

  -- header neon underline
  if Susano.DrawLine then
    Susano.DrawLine(mx+pad, my+headerH, mx+panelW-pad, my+headerH, 0.20,0.85,1.0, (0.30+glow*0.35)*alpha, 2.0*s)
  end

  -- logo + title
  drawTriLogo(mx+pad, my+pad*0.65, 46*s, alpha, glow)
  Susano.DrawText(mx+80*s, my+38*s, "NEONPHASE", 28*s, 0.95,0.98,1.0, 0.95*alpha)

  local crumb = table.concat(menu.stack, "  ▸  ")
  Susano.DrawText(mx+80*s, my+58*s, crumb, 13*s, 0.60,0.72,0.85, 0.92*alpha)

  -- body
  local bodyY = my + headerH + pad*0.70
  local bodyH = panelH - (bodyY - my) - pad
  local gap = 14*s

  local leftW = panelW * 0.34
  local rightW = panelW - leftW - gap - pad*2

  local leftX = mx + pad
  local rightX = leftX + leftW + gap

  -- glass blocks
  Susano.DrawRectFilled(leftX,  bodyY, leftW,  bodyH,  0.05,0.06,0.09, 0.78*alpha, 14*s)
  Susano.DrawRectFilled(rightX, bodyY, rightW, bodyH, 0.05,0.06,0.09, 0.56*alpha, 14*s)

  -- particles inside panel
  drawParticles(mx, my, panelW, panelH, alpha*(0.7+glow*0.3), s)

  -- list calculations
  local total = #menu.categories
  local rowH = 38*s
  local listPad = 10*s
  local innerH = bodyH - listPad*2
  local visible = math.max(1, math.floor(innerH / rowH))

  local minScroll = 0
  local maxScroll = math.max(0, total - visible)
  menu.scroll = clamp(menu.scroll, minScroll, maxScroll)

  if menu.selected < menu.scroll + 1 then
    menu.scroll = menu.selected - 1
  elseif menu.selected > menu.scroll + visible then
    menu.scroll = menu.selected - visible
  end
  menu.scroll = clamp(menu.scroll, minScroll, maxScroll)

  -- draw list
  for i=1, visible do
    local idx = i + menu.scroll
    if idx > total then break end

    local item = menu.categories[idx]
    local iy = bodyY + listPad + (i-1)*rowH
    local ix = leftX + listPad
    local iw = leftW - listPad*2
    local ih = rowH - 6*s

    local sel = (idx == menu.selected)

    if sel then
      if Susano.DrawRectGradient then
        Susano.DrawRectGradient(ix, iy, iw, ih,
          0.12,0.95,1.0, (0.88*alpha),
          1.00,0.25,0.85, (0.78*alpha),
          0.20,1.00,0.70, (0.72*alpha),
          0.12,0.95,1.0, (0.82*alpha),
          12*s
        )
      else
        Susano.DrawRectFilled(ix, iy, iw, ih, 0.20,0.85,1.0, 0.55*alpha, 12*s)
      end

      -- glow overlay
      Susano.DrawRectFilled(ix, iy, iw, ih, 0.20,0.85,1.0, (0.10 + glow*0.16)*alpha, 12*s)

      -- moving neon line inside selection
      local u = fract(t*0.55)
      local lx1 = ix + 10*s
      local lx2 = ix + iw - 10*s
      local ly = iy + ih * (0.20 + u*0.60)
      if Susano.DrawLine then
        Susano.DrawLine(lx1, ly, lx2, ly, 1.0,0.25,0.85, (0.20+glow*0.30)*alpha, 2.0*s)
      end
    else
      Susano.DrawRectFilled(ix, iy, iw, ih, 0.10,0.11,0.14, 0.34*alpha, 12*s)
    end

    -- centered text in each box
    drawCenteredText(ix, iy, iw, ih, item.name, 16*s, 0.95,0.98,1.0, (sel and 1.0 or 0.72)*alpha)
  end

  -- right side title
  Susano.DrawText(rightX + 16*s, bodyY + 30*s, currentPage(), 18*s, 0.95,0.98,1.0, 0.95*alpha)

  -- right side neon cards
  local cardX = rightX + 16*s
  local cardW = rightW - 32*s
  local cardY = bodyY + 54*s
  local cardH = 82*s
  local cardGap = 12*s

  for c=1,4 do
    local cy = cardY + (c-1)*(cardH + cardGap)
    if cy + cardH > bodyY + bodyH - 16*s then break end

    Susano.DrawRectFilled(cardX, cy, cardW, cardH, 0.10,0.11,0.14, 0.42*alpha, 14*s)
    Susano.DrawRectFilled(cardX, cy, cardW, 2*s, 0.20,0.85,1.0, (0.12+glow*0.10)*alpha, 14*s)

    local main = ("Slot %d"):format(c)
    local sub  = "UI placeholder (branche ta logique ici)"
    drawCenteredText(cardX, cy + 6*s,          cardW, cardH*0.55, main, 16*s, 0.95,0.98,1.0, 0.92*alpha)
    drawCenteredText(cardX, cy + cardH*0.45,   cardW, cardH*0.55, sub,  13*s, 0.62,0.78,0.92, 0.90*alpha)
  end

  -- footer hint centered
  local hint = "INSERT: fermer   ↑↓: naviguer   →: entrer   ←/BACK/DEL: retour"
  local hintSize = 13*s
  local hw = textW(hint, hintSize)
  Susano.DrawText(mx + (panelW - hw)*0.5, my + panelH - 14*s, hint, hintSize, 0.60,0.72,0.85, 0.88*alpha)

  Susano.SubmitFrame()
end

--========================================================
--  Navigation
--========================================================
local function nav(delta)
  local total = #menu.categories
  menu.selected = ((menu.selected - 1 + delta) % total) + 1
end

local function enter()
  local item = menu.categories[menu.selected]
  pushPage(item.name)
end

--========================================================
--  Main loop (stable)
--========================================================
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    if keyPressed(VK.INSERT) then
      toggleMenu()
    end

    if menu.open then
      local now = GetGameTimer()
      local canRepeat = (now - menu.lastNavMs) >= menu.repeatDelayMs

      if keyPressed(VK.UP) or (canRepeat and keyDown(VK.UP)) then
        nav(-1); menu.lastNavMs = now
      elseif keyPressed(VK.DOWN) or (canRepeat and keyDown(VK.DOWN)) then
        nav(1); menu.lastNavMs = now
      end

      if keyPressed(VK.RIGHT) then
        enter()
      end

      if keyPressed(VK.LEFT) or keyPressed(VK.BACK) or keyPressed(VK.DELETE) then
        popPage()
      end

      drawMenu()
    end
  end
end)
