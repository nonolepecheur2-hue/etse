--============================================================
--  Safe Susano Menu (no Citizen required)
--============================================================

local function log(msg)
  print("[susano-menu] " .. tostring(msg))
end

-- Vérifs minimales
if Susano == nil then
  log("ERROR: Susano is nil. Le script se lance avant l'API, ou tu n'es pas dans le bon loader.")
  return
end

local required = {
  "BeginFrame", "SubmitFrame",
  "DrawRectFilled", "DrawText",
  "GetTextWidth", "GetAsyncKeyState"
}

for _, fn in ipairs(required) do
  if type(Susano[fn]) ~= "function" then
    log("ERROR: Susano." .. fn .. " manquant (nil ou pas une fonction). Check la doc / version API.")
    return
  end
end

log("OK: Susano API détectée. Menu init...")

-- Key codes
local VK = { INSERT=0x2D, UP=0x26, DOWN=0x28, ENTER=0x0D, BACK=0x08 }

local function keyPressed(vk)
  local down, pressed = Susano.GetAsyncKeyState(vk)
  return pressed == true
end

local menu = {
  open = true,
  title = "Main menu",
  selected = 1,
  items = {
    { label = "Player",        action = function() log("Player") end },
    { label = "Server",        action = function() log("Server") end },
    { label = "Weapon",        action = function() log("Weapon") end },
    { label = "Combat",        action = function() log("Combat") end },
    { label = "Vehicle",       action = function() log("Vehicle") end },
    { label = "Visual",        action = function() log("Visual") end },
    { label = "Miscellaneous", action = function() log("Misc") end },
    { label = "Settings",      action = function() log("Settings") end },
    { label = "Search",        action = function() log("Search") end, isSearch = true },
  }
}

local UI = {
  x = 50, y = 40, w = 310,
  titleH = 26, rowH = 24, padX = 10,
  titleSize = 14, itemSize = 14,
  bg   = {0.18, 0.20, 0.23, 0.92},
  top  = {0.05, 0.05, 0.05, 0.95},
  sel  = {0.14, 0.45, 0.80, 0.90},
  text = {0.92, 0.92, 0.92, 0.95},
  dim  = {0.80, 0.80, 0.80, 0.90},
}

local function drawMenu()
  local x, y, w = UI.x, UI.y, UI.w
  local rows = #menu.items
  local h = UI.titleH + rows * UI.rowH

  Susano.DrawRectFilled(x, y, w, h, UI.bg[1], UI.bg[2], UI.bg[3], UI.bg[4], 0)
  Susano.DrawRectFilled(x, y, w, UI.titleH, UI.top[1], UI.top[2], UI.top[3], UI.top[4], 0)
  Susano.DrawText(x + UI.padX, y + 18, menu.title, UI.titleSize, UI.text[1], UI.text[2], UI.text[3], UI.text[4])

  local listY = y + UI.titleH
  for i, it in ipairs(menu.items) do
    local ry = listY + (i - 1) * UI.rowH

    if i == menu.selected then
      Susano.DrawRectFilled(x, ry, w, UI.rowH, UI.sel[1], UI.sel[2], UI.sel[3], UI.sel[4], 0)
    end

    local col = (i == menu.selected) and UI.text or UI.dim
    local ty = ry + 17
    Susano.DrawText(x + UI.padX, ty, it.label, UI.itemSize, col[1], col[2], col[3], col[4])

    if it.isSearch then
      -- si 🔍 ne s'affiche pas, remplace par "o"
      local icon = "🔍"
      local iconW = Susano.GetTextWidth(icon, UI.itemSize)
      if iconW == nil then iconW = 10 end
      Susano.DrawText(x + w - UI.padX - iconW, ty, icon, UI.itemSize, col[1], col[2], col[3], col[4])
    else
      local chevron = ">"
      local cw = Susano.GetTextWidth(chevron, UI.itemSize)
      if cw == nil then cw = 8 end
      Susano.DrawText(x + w - UI.padX - cw, ty, chevron, UI.itemSize, col[1], col[2], col[3], col[4])
    end
  end
end

-- Wait helper (FiveM -> Citizen.Wait, sinon no-op CPU-friendly)
local function wait0()
  if Citizen and Citizen.Wait then
    Citizen.Wait(0)
  elseif Wait then
    Wait(0)
  else
    -- mini sleep "soft" si aucune fonction de wait n'existe
    -- (sinon boucle 100% CPU)
    local t = os.clock()
    while (os.clock() - t) < 0.001 do end
  end
end

-- Loop principal protégé
local function mainLoop()
  while true do
    if keyPressed(VK.INSERT) then menu.open = not menu.open end

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

    -- draw frame
    Susano.BeginFrame()
    if menu.open then
      drawMenu()
    end
    Susano.SubmitFrame()

    wait0()
  end
end

local ok, err = pcall(mainLoop)
if not ok then
  log("CRASH: " .. tostring(err))
end
