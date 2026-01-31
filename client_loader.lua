--============================================================
--  Menu "liste" style screenshot (Susano draw)
--  INS toggle | UP/DOWN nav | ENTER select | BACK close
--============================================================

local VK = {
  INSERT = 0x2D,
  UP     = 0x26,
  DOWN   = 0x28,
  ENTER  = 0x0D,
  BACK   = 0x08,
}

local function keyPressed(vk)
  local down, pressed = Susano.GetAsyncKeyState(vk)
  return pressed == true
end

local menu = {
  open = true,
  title = "Main menu",
  selected = 1,
  items = {
    { label = "Player",        action = function() print("Player") end },
    { label = "Server",        action = function() print("Server") end },
    { label = "Weapon",        action = function() print("Weapon") end },
    { label = "Combat",        action = function() print("Combat") end },
    { label = "Vehicle",       action = function() print("Vehicle") end },
    { label = "Visual",        action = function() print("Visual") end },
    { label = "Miscellaneous", action = function() print("Misc") end },
    { label = "Settings",      action = function() print("Settings") end },
    { label = "Search",        action = function() print("Search") end, isSearch = true },
  }
}

-- Layout proche de l'image
local UI = {
  x = 50,
  y = 40,
  w = 310,
  titleH = 26,
  rowH = 24,
  padX = 10,

  -- typographie
  titleSize = 14,
  itemSize  = 14,

  -- couleurs (RGBA 0..1)
  bg   = {0.18, 0.20, 0.23, 0.92}, -- gris bleu
  top  = {0.05, 0.05, 0.05, 0.95}, -- barre top noire
  sel  = {0.14, 0.45, 0.80, 0.90}, -- bleu sélection
  text = {0.92, 0.92, 0.92, 0.95},
  dim  = {0.80, 0.80, 0.80, 0.90},
}

local function clamp(n, a, b)
  if n < a then return a end
  if n > b then return b end
  return n
end

local function drawMainMenu()
  local x, y, w = UI.x, UI.y, UI.w
  local rows = #menu.items
  local h = UI.titleH + rows * UI.rowH

  -- Panel fond
  Susano.DrawRectFilled(x, y, w, h, UI.bg[1], UI.bg[2], UI.bg[3], UI.bg[4], 0)

  -- Barre top
  Susano.DrawRectFilled(x, y, w, UI.titleH, UI.top[1], UI.top[2], UI.top[3], UI.top[4], 0)

  -- Titre
  Susano.DrawText(x + UI.padX, y + 18, menu.title, UI.titleSize, UI.text[1], UI.text[2], UI.text[3], UI.text[4])

  -- Items
  local listY = y + UI.titleH
  for i, it in ipairs(menu.items) do
    local ry = listY + (i - 1) * UI.rowH

    -- surbrillance
    if i == menu.selected then
      Susano.DrawRectFilled(x, ry, w, UI.rowH, UI.sel[1], UI.sel[2], UI.sel[3], UI.sel[4], 0)
    end

    -- texte item (align “milieu” visuel)
    local tx = x + UI.padX
    local ty = ry + 17
    local col = (i == menu.selected) and UI.text or UI.dim
    Susano.DrawText(tx, ty, it.label, UI.itemSize, col[1], col[2], col[3], col[4])

    -- chevron à droite (comme sur l'image)
    -- (Pour Search, on met plutôt une loupe)
    if it.isSearch then
      -- Icône simple (unicode) : si ta font ne la supporte pas, remplace par "(?)" ou "O"
      local icon = "🔍"
      local iconW = Susano.GetTextWidth(icon, UI.itemSize)
      Susano.DrawText(x + w - UI.padX - iconW, ty, icon, UI.itemSize, col[1], col[2], col[3], col[4])
    else
      local chevron = ">"
      local cw = Susano.GetTextWidth(chevron, UI.itemSize)
      Susano.DrawText(x + w - UI.padX - cw, ty, chevron, UI.itemSize, col[1], col[2], col[3], col[4])
    end
  end
end

Citizen.CreateThread(function()
  while true do
    -- toggle
    if keyPressed(VK.INSERT) then
      menu.open = not menu.open
    end

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

    -- render
    Susano.BeginFrame()
    if menu.open then
      drawMainMenu()
    end
    Susano.SubmitFrame()

    Citizen.Wait(0)
  end
end)
