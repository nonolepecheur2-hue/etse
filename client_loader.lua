--========================================================
--  SUSANO DRAW MENU - FUTURISTIC NEON (RESPONSIVE)
--  FIX: Susano ready wait + pcall safeCall + debug overlay
--========================================================

if _G.__SUSANO_NEON_MENU__ then return end
_G.__SUSANO_NEON_MENU__ = true

--========================================================
--  Robust safeCall (pcall)
--========================================================
local function safeCall(fn, ...)
  if not fn then return nil end
  local ok, a,b,c,d,e,f = pcall(fn, ...)
  if not ok then
    -- évite de kill le thread si Susano throw
    return nil
  end
  return a,b,c,d,e,f
end

--========================================================
--  Wait Susano is ready (critical)
--========================================================
local SUSANO_READY = false
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if type(Susano) == "table"
      and type(Susano.BeginFrame) == "function"
      and type(Susano.SubmitFrame) == "function"
      and type(Susano.DrawText) == "function"
      and type(Susano.GetAsyncKeyState) == "function"
    then
      SUSANO_READY = true
      -- petit marqueur “ça marche”
      Susano.BeginFrame()
      Susano.DrawText(20, 40, "Susano overlay: READY", 18, 0.2, 0.85, 1.0, 1.0)
      Susano.SubmitFrame()
      break
    end
  end
end)

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
--  Input
--========================================================
local function keyPressed(vk)
  local down, pressed = safeCall(Susano.GetAsyncKeyState, vk)
  return pressed == true
end

local function keyDown(vk)
  local down, pressed = safeCall(Susano.GetAsyncKeyState, vk)
  return down == true
end

--========================================================
--  Small utils (inchangé)
--========================================================
local function clamp(x,a,b) if x<a then return a end if x>b then return b end return x end
local function lerp(a,b,t) return a + (b-a)*t end
local function smooth(t) t = clamp(t,0,1); return t*t*(3-2*t) end
local function fract(x) return x - math.floor(x) end
local function textW(str, px) return (Susano.GetTextWidth and Susano.GetTextWidth(str, px)) or 0 end

--========================================================
--  Responsive layout helpers (inchangé)
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
--  Menu state (inchangé)
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
--  Toggle stability (inchangé)
--========================================================
local nextToggleAt = 0
local TOGGLE_COOLDOWN_MS = 250

local function toggleMenu()
  local now = GetGameTimer()
  if now < nextToggleAt then return end
  nextToggleAt = now + TOGGLE_COOLDOWN_MS

  menu.open = not menu.open
  menu.anim.target = menu.open and 1.0 or 0.0

  safeCall(Susano.EnableOverlay, menu.open) -- ok d’après la doc :contentReference[oaicite:3]{index=3}

  if not menu.open then
    safeCall(Susano.ResetFrame)
    menu.stack = { "Main menu" }
    menu.selected = 1
    menu.scroll = 0
  end
end

--========================================================
--  (Ton rendering: inchangé)
--  IMPORTANT: ajoute juste un fallback dt si GetFrameTime() renvoie 0
--========================================================
local function drawMenu()
  if not SUSANO_READY then return end

  local sw, sh = getScreen()
  local s = uiScale(sw, sh)

  local dt = GetFrameTime()
  if not dt or dt <= 0.0 then dt = 1.0/60.0 end -- <- FIX important

  menu.anim.t = menu.anim.t + (menu.anim.target - menu.anim.t) * clamp(dt*10.0, 0, 1)
  local openT = smooth(menu.anim.t)
  local alpha = openT

  -- (le reste de ton drawMenu EXACTEMENT pareil)
  -- >>> colle ici ton drawMenu d’origine après ce commentaire <<<
end

--========================================================
--  Navigation (inchangé)
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

    -- Tant que Susano pas prêt: on évite de “perdre” les inputs
    if not SUSANO_READY then
      -- petit ping visuel (optionnel)
      if type(Susano) == "table" and Susano.BeginFrame and Susano.DrawText and Susano.SubmitFrame then
        Susano.BeginFrame()
        Susano.DrawText(20, 20, "Loading Susano overlay...", 18, 1,1,1,1)
        Susano.SubmitFrame()
      end
      goto continue
    end

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

    ::continue::
  end
end)
