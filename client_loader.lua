--============================================================
--  Susano Draw Menu (overlay)
--  Touches: INS toggle | UP/DOWN nav | ENTER select | BACK close
--============================================================

local VK = {
  INSERT = 0x2D,
  UP     = 0x26,
  DOWN   = 0x28,
  ENTER  = 0x0D,
  BACK   = 0x08,
}

local menu = {
  open = false,
  title = "Menu Susano",
  selected = 1,
  items = {
    { label = "Godmode",          action = function() print("toggle godmode") end },
    { label = "TP waypoint",      action = function() print("tp") end },
    { label = "Give money",       action = function() print("money") end },
    { label = "Settings >",       action = function() print("open settings") end },
    { label = "Quitter",          action = function() menu.open = false end },
  }
}

-- UI layout (pixels)
local UI = {
  x = 60,
  y = 120,
  w = 320,       -- recalculé dynamiquement
  headerH = 34,
  rowH = 28,
  pad = 12,
  rounding = 8,
  titleSize = 18,
  itemSize = 16,
}

local function clamp(n, a, b)
  if n < a then return a end
  if n > b then return b end
  return n
end

local function keyPressed(vk)
  local down, pressed = Susano.GetAsyncKeyState(vk)
  return pressed == true
end

local function computeMenuWidth()
  -- largeur = max(titre, items) + padding
  local maxW = Susano.GetTextWidth(menu.title, UI.titleSize) -- px :contentReference[oaicite:1]{index=1}
  for _, it in ipairs(menu.items) do
    local w = Susano.GetTextWidth(it.label, UI.itemSize)
    if w > maxW then maxW = w end
  end
  -- + marges gauche/droite
  local target = math.floor(maxW + UI.pad * 2)
  -- borne pour éviter trop petit/trop grand
  UI.w = clamp(target, 240, 520)
end

local function drawMenu()
  computeMenuWidth()

  local x, y, w = UI.x, UI.y, UI.w
  local h = UI.headerH + (#menu.items * UI.rowH) + UI.pad

  -- background panel
  Susano.DrawRectFilled(x, y, w, h, 0, 0, 0, 0.55, UI.rounding) -- RGBA [0..1] :contentReference[oaicite:2]{index=2}

  -- header
  Susano.DrawRectFilled(x, y, w, UI.headerH, 0.08, 0.08, 0.08, 0.85, UI.rounding)

  -- title text (baseline)
  Susano.DrawText(x + UI.pad, y + 24, menu.title, UI.titleSize, 1, 1, 1, 1) -- :contentReference[oaicite:3]{index=3}

  -- items
  local startY = y + UI.headerH + 6
  for i, it in ipairs(menu.items) do
    local rowY = startY + (i - 1) * UI.rowH

    if i == menu.selected then
      -- highlight
      Susano.DrawRectFilled(x + 6, rowY - 18, w - 12, UI.rowH, 0.20, 0.45, 0.95, 0.35, 6)
      Susano.DrawText(x + UI.pad, rowY, it.label, UI.itemSize, 1, 1, 1, 1)
    else
      Susano.DrawText(x + UI.pad, rowY, it.label, UI.itemSize, 0.9, 0.9, 0.9, 0.9)
    end
  end

  -- footer hint
  local hint = "INS: toggle | ↑↓: nav | ENTER: select | BACK: close"
  Susano.DrawText(x + UI.pad, y + h - 10, hint, 12, 1, 1, 1, 0.55)
end

-- Main loop (FiveM-style; adapte si besoin)
Citizen.CreateThread(function()
  while true do
    -- Toggle menu
    if keyPressed(VK.INSERT) then
      menu.open = not menu.open
    end

    -- Navigation
    if menu.open then
      if keyPressed(VK.UP) then
        menu.selected = menu.selected - 1
        if menu.selected < 1 then menu.selected = #menu.items end
      elseif keyPressed(VK.DOWN) then
        menu.selected = menu.selected + 1
        if menu.selected > #menu.items then menu.selected = 1 end
      elseif keyPressed(VK.ENTER) then
        local it = menu.items[menu.selected]
        if it and it.action then it.action() end
      elseif keyPressed(VK.BACK) then
        menu.open = false
      end
    end

    -- Render overlay frame
    Susano.BeginFrame()          -- démarre un nouveau frame :contentReference[oaicite:4]{index=4}
    if menu.open then
      drawMenu()
    end
    Susano.SubmitFrame()         -- publie le frame :contentReference[oaicite:5]{index=5}

    Citizen.Wait(0)
  end
end)
