--========================================================
--  Susano Draw Menu (Phaze-like) - UI ONLY
--  INSERT  : open/close
--  UP/DOWN : navigate
--  RIGHT   : enter
--  LEFT / BACKSPACE / DELETE : back
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

local function keyPressed(vk)
  local _, pressed = Susano.GetAsyncKeyState(vk) -- down, pressed :contentReference[oaicite:1]{index=1}
  return pressed
end

local function clamp(x, a, b)
  if x < a then return a end
  if x > b then return b end
  return x
end

local function lerp(a, b, t) return a + (b - a) * t end

-- simple smoothstep-ish (nice for animations)
local function smooth(t) t = clamp(t, 0.0, 1.0); return t * t * (3.0 - 2.0 * t) end

--========================================================
--  Menu state
--========================================================
local menu = {
  open = false,

  stack = { "Main menu" },      -- breadcrumb stack
  selected = 1,
  scroll = 0,

  -- visual sizing
  w = 620,
  h = 420,

  categories = {
    { name = "Player",         icon = "👤" },
    { name = "Server",         icon = "🌐" },
    { name = "Weapon",         icon = "🔫" },
    { name = "Combat",         icon = "⚔️" },
    { name = "Vehicle",        icon = "🚗" },
    { name = "Visual",         icon = "👁️" },
    { name = "Miscellaneous",  icon = "🧩" },
    { name = "Settings",       icon = "⚙️" },
    { name = "Search",         icon = "🔎" },
  },

  -- timings
  lastNavMs = 0,
  repeatDelayMs = 130,

  anim = {
    openT = 0.0,     -- 0..1
    target = 0.0,
  }
}

local function pushPage(name)
  menu.stack[#menu.stack + 1] = name
end

local function popPage()
  if #menu.stack > 1 then
    menu.stack[#menu.stack] = nil
  end
end

local function currentPage()
  return menu.stack[#menu.stack]
end

--========================================================
--  Layout helpers
--========================================================
local function getCenterRect()
  local sw, sh = GetActiveScreenResolution() -- native ok to use for centering
  local x = (sw - menu.w) * 0.5
  local y = (sh - menu.h) * 0.5
  return x, y, sw, sh
end

local function textWidth(txt, sizePx)
  return Susano.GetTextWidth(txt, sizePx) or 0 -- :contentReference[oaicite:2]{index=2}
end

local function drawShadowRect(x, y, w, h, rounding)
  -- soft shadow layers (subtle, classy)
  for i = 1, 10 do
    local a = (0.10 - (i * 0.007))
    if a < 0 then break end
    Susano.DrawRectFilled(x - i, y - i, w + i*2, h + i*2, 0, 0, 0, a, rounding + i*0.8) -- :contentReference[oaicite:3]{index=3}
  end
end

local function drawLogo(x, y, s, glowA)
  -- tiny "tri-blade" logo made from lines
  -- (keeps it pure draw, no texture required)
  local cx, cy = x + s*0.5, y + s*0.5
  local r = s * 0.42

  local function L(ax, ay, bx, by, a)
    Susano.DrawLine(ax, ay, bx, by, 0.20, 0.75, 1.0, a, 2.5) -- :contentReference[oaicite:4]{index=4}
  end

  -- glow ring
  for i=1,4 do
    Susano.DrawCircle(cx, cy, r + i*1.2, 0.20, 0.75, 1.0, glowA*(0.18 - i*0.03), 2.0, false)
  end

  -- blades
  local a = 0.95
  L(cx, cy - r, cx + r*0.85, cy + r*0.20, a)
  L(cx + r*0.85, cy + r*0.20, cx - r*0.15, cy + r*0.95, a)
  L(cx - r*0.15, cy + r*0.95, cx - r*0.85, cy + r*0.20, a)
  L(cx - r*0.85, cy + r*0.20, cx, cy - r, a)

  -- inner accents
  L(cx, cy - r*0.55, cx + r*0.48, cy + r*0.12, 0.55)
  L(cx + r*0.48, cy + r*0.12, cx - r*0.08, cy + r*0.55, 0.55)
  L(cx - r*0.08, cy + r*0.55, cx - r*0.48, cy + r*0.12, 0.55)
end

--========================================================
--  Rendering
--========================================================
local function drawMenu()
  local x, y, sw, sh = getCenterRect()

  local t = GetGameTimer() / 1000.0
  local pulse = (math.sin(t * 2.2) + 1.0) * 0.5 -- 0..1
  local glow = lerp(0.20, 0.55, pulse)

  -- open animation (scale + alpha)
  local dt = GetFrameTime()
  local speed = 9.0
  menu.anim.openT = menu.anim.openT + (menu.anim.target - menu.anim.openT) * clamp(dt * speed, 0.0, 1.0)
  local openT = smooth(menu.anim.openT)

  local alpha = lerp(0.0, 1.0, openT)
  local scale = lerp(0.92, 1.0, openT)

  local mw = menu.w * scale
  local mh = menu.h * scale
  local mx = (sw - mw) * 0.5
  local my = (sh - mh) * 0.5

  -- frame begin
  Susano.BeginFrame() -- :contentReference[oaicite:5]{index=5}

  -- dim background
  Susano.DrawRectFilled(0, 0, sw, sh, 0, 0, 0, 0.35 * alpha, 0.0) -- :contentReference[oaicite:6]{index=6}

  -- shadow + main panel
  drawShadowRect(mx, my, mw, mh, 18.0)
  Susano.DrawRectFilled(mx, my, mw, mh, 0.07, 0.08, 0.10, 0.92 * alpha, 18.0)

  -- subtle top gradient bar
  Susano.DrawRectGradient(mx, my, mw, 64*scale,
    0.10, 0.12, 0.17, 0.95*alpha,
    0.08, 0.10, 0.14, 0.95*alpha,
    0.05, 0.06, 0.08, 0.80*alpha,
    0.06, 0.07, 0.10, 0.80*alpha,
    18.0
  ) -- :contentReference[oaicite:7]{index=7}

  -- accent glow line
  local gx1, gy1 = mx + 18*scale, my + 64*scale
  local gx2, gy2 = mx + mw - 18*scale, my + 64*scale
  Susano.DrawLine(gx1, gy1, gx2, gy2, 0.20, 0.75, 1.0, (0.28 + glow*0.25) * alpha, 2.0)

  -- logo + title
  local pad = 18 * scale
  drawLogo(mx + pad, my + pad*0.8, 44*scale, alpha)

  local title = "Phaze"
  local titleSize = 30 * scale
  local tw = textWidth(title, titleSize)
  Susano.DrawText(mx + 74*scale, my + 36*scale, title, titleSize, 0.94, 0.96, 1.0, 0.95 * alpha) -- :contentReference[oaicite:8]{index=8}
  -- mini subtitle (breadcrumb)
  local crumb = table.concat(menu.stack, "  >  ")
  Susano.DrawText(mx + 74*scale, my + 56*scale, crumb, 14*scale, 0.65, 0.70, 0.78, 0.90 * alpha)

  -- left menu area
  local leftW = 210 * scale
  local leftX = mx + pad
  local leftY = my + 86 * scale
  local leftH = mh - (leftY - my) - pad

  -- left background
  Susano.DrawRectFilled(leftX, leftY, leftW, leftH, 0.06, 0.07, 0.09, 0.75*alpha, 14.0)

  -- right content area
  local rightX = leftX + leftW + 14*scale
  local rightY = leftY
  local rightW = mw - (rightX - mx) - pad
  local rightH = leftH
  Susano.DrawRectFilled(rightX, rightY, rightW, rightH, 0.06, 0.07, 0.09, 0.55*alpha, 14.0)

  -- list items
  local rowH = 34 * scale
  local visibleRows = math.floor((leftH - 14*scale) / rowH)
  local total = #menu.categories

  -- scrolling so selected stays visible
  local minScroll = 0
  local maxScroll = math.max(0, total - visibleRows)
  menu.scroll = clamp(menu.scroll, minScroll, maxScroll)

  if menu.selected < menu.scroll + 1 then
    menu.scroll = menu.selected - 1
  elseif menu.selected > menu.scroll + visibleRows then
    menu.scroll = menu.selected - visibleRows
  end
  menu.scroll = clamp(menu.scroll, minScroll, maxScroll)

  local listPad = 10 * scale
  for i = 1, visibleRows do
    local idx = i + menu.scroll
    if idx > total then break end

    local item = menu.categories[idx]
    local iy = leftY + listPad + (i-1) * rowH
    local ix = leftX + listPad
    local iw = leftW - listPad*2
    local ih = rowH - 6*scale

    local isSel = (idx == menu.selected)
    if isSel then
      -- selected highlight (blue gradient + glow)
      Susano.DrawRectGradient(ix, iy, iw, ih,
        0.10, 0.50, 0.85, (0.85*alpha),
        0.08, 0.35, 0.70, (0.85*alpha),
        0.06, 0.22, 0.42, (0.75*alpha),
        0.08, 0.30, 0.60, (0.75*alpha),
        10.0
      )
      Susano.DrawRectFilled(ix, iy, iw, ih, 0.20, 0.75, 1.0, (0.09 + glow*0.10) * alpha, 10.0)
      Susano.DrawLine(ix+10*scale, iy+ih, ix+iw-10*scale, iy+ih, 0.20, 0.75, 1.0, (0.35+glow*0.25)*alpha, 2.0)
    else
      Susano.DrawRectFilled(ix, iy, iw, ih, 0.10, 0.11, 0.14, 0.35*alpha, 10.0)
    end

    -- icon + label + chevron
    local tx = ix + 10*scale
    Susano.DrawText(tx, iy + ih*0.78, item.icon, 16*scale, 0.95, 0.97, 1.0, (isSel and 1.0 or 0.75) * alpha)
    Susano.DrawText(tx + 26*scale, iy + ih*0.78, item.name, 16*scale, 0.95, 0.97, 1.0, (isSel and 1.0 or 0.72) * alpha)
    Susano.DrawText(ix + iw - 18*scale, iy + ih*0.78, "›", 18*scale, 0.70, 0.78, 0.88, (isSel and 0.95 or 0.50) * alpha)
  end

  -- right panel content (pretty placeholders)
  local hdr = currentPage()
  local hdrSize = 18 * scale
  Susano.DrawText(rightX + 16*scale, rightY + 30*scale, hdr, hdrSize, 0.94, 0.96, 1.0, 0.95 * alpha)

  -- cards
  local cardX = rightX + 16*scale
  local cardY = rightY + 54*scale
  local cardW = rightW - 32*scale
  local cardH = 74*scale
  local gap = 12*scale

  for c = 1, 4 do
    local cy = cardY + (c-1) * (cardH + gap)
    if cy + cardH > rightY + rightH - 16*scale then break end

    Susano.DrawRectFilled(cardX, cy, cardW, cardH, 0.10, 0.11, 0.14, 0.42*alpha, 14.0)
    Susano.DrawRectGradient(cardX, cy, cardW, cardH,
      0.20, 0.75, 1.0, (0.06 + glow*0.03)*alpha,
      0.20, 0.75, 1.0, (0.00)*alpha,
      0.20, 0.75, 1.0, (0.00)*alpha,
      0.20, 0.75, 1.0, (0.04 + glow*0.02)*alpha,
      14.0
    )

    local label = ("Option slot %d"):format(c)
    Susano.DrawText(cardX + 14*scale, cy + 34*scale, label, 16*scale, 0.92, 0.95, 1.0, 0.92*alpha)
    Susano.DrawText(cardX + 14*scale, cy + 56*scale, "UI placeholder (à toi de brancher ta logique ici)", 13*scale, 0.62, 0.68, 0.78, 0.90*alpha)
  end

  -- footer hints
  local hint = "INSERT: fermer   ↑↓: naviguer   →: entrer   ←/BACK/DEL: retour"
  local hintSize = 13 * scale
  local hw = textWidth(hint, hintSize)
  Susano.DrawText(mx + (mw - hw)*0.5, my + mh - 14*scale, hint, hintSize, 0.65, 0.70, 0.78, 0.85*alpha)

  Susano.SubmitFrame() -- :contentReference[oaicite:9]{index=9}
end

--========================================================
--  Input / navigation
--========================================================
local function toggleMenu()
  menu.open = not menu.open
  menu.anim.target = menu.open and 1.0 or 0.0

  -- block game input when menu open, allow overlay cursor/interaction
  Susano.EnableOverlay(menu.open) -- :contentReference[oaicite:10]{index=10}

  if not menu.open then
    Susano.ResetFrame() -- clears drawings :contentReference[oaicite:11]{index=11}
    menu.stack = { "Main menu" }
    menu.selected = 1
    menu.scroll = 0
  end
end

local function nav(delta)
  local total = #menu.categories
  menu.selected = ((menu.selected - 1 + delta) % total) + 1
end

local function enter()
  local item = menu.categories[menu.selected]
  pushPage(item.name)
end

local function back()
  popPage()
end

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    if keyPressed(VK.INSERT) then
      toggleMenu()
    end

    if menu.open then
      -- navigation with repeat
      local now = GetGameTimer()
      local canRepeat = (now - menu.lastNavMs) >= menu.repeatDelayMs

      if (keyPressed(VK.UP) or (canRepeat and select(1, Susano.GetAsyncKeyState(VK.UP)))) then
        nav(-1); menu.lastNavMs = now
      elseif (keyPressed(VK.DOWN) or (canRepeat and select(1, Susano.GetAsyncKeyState(VK.DOWN)))) then
        nav(1); menu.lastNavMs = now
      end

      if keyPressed(VK.RIGHT) then
        enter()
      end

      if keyPressed(VK.LEFT) or keyPressed(VK.BACK) or keyPressed(VK.DELETE) then
        back()
      end

      drawMenu()
    end
  end
end)
