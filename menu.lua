local Config = require("config")

local Menu = {}
Menu.items = {}
Menu.hoveredIndex = nil
Menu.searchText = ""
Menu.searchActive = false

function Menu:init()
  self.items = {
    {name = "Player", icon = ">", hasSubmenu = true},
    {name = "Server", icon = ">", hasSubmenu = true},
    {name = "Weapon", icon = ">", hasSubmenu = true},
    {name = "Combat", icon = ">", hasSubmenu = true},
    {name = "Vehicle", icon = ">", hasSubmenu = true},
    {name = "Visual", icon = ">", hasSubmenu = true},
    {name = "Miscellaneous", icon = ">", hasSubmenu = true},
    {name = "Settings", icon = ">", hasSubmenu = true}
  }

  self.font = love.graphics.newFont(14)
  self.titleFont = love.graphics.newFont(12)
  self.logoFont = love.graphics.newFont(24)
end

function Menu:update(dt)
end

function Menu:draw()
  self:drawDiagonalPattern()
  self:drawHeader()
  self:drawMainMenu()
  self:drawSearch()
end

function Menu:drawDiagonalPattern()
  love.graphics.setColor(Config.colors.diagonal1)
  for i = -1, 10 do
    love.graphics.polygon("fill", 
      i * 100, 0,
      i * 100 + 50, 0,
      i * 100, Config.header.height,
      i * 100 - 50, Config.header.height
    )
  end
end

function Menu:drawHeader()
  love.graphics.setColor(Config.colors.headerBg)
  love.graphics.rectangle("fill", 0, 0, Config.width, Config.header.height)

  love.graphics.setColor(Config.colors.accent)
  local logoX = Config.header.padding
  local logoY = Config.header.height / 2 - 15
  love.graphics.polygon("fill",
    logoX, logoY,
    logoX + 15, logoY + 10,
    logoX + 30, logoY,
    logoX + 25, logoY + 15,
    logoX + 35, logoY + 30,
    logoX + 15, logoY + 25,
    logoX + 5, logoY + 30
  )

  love.graphics.setColor(Config.colors.text)
  love.graphics.setFont(self.logoFont)
  love.graphics.print("Phaze", logoX + 50, logoY + 5)
end

function Menu:drawMainMenu()
  local startY = Config.header.height

  love.graphics.setColor(Config.colors.menuBg)
  love.graphics.rectangle("fill", 0, startY, Config.width, Config.menu.titleHeight)

  love.graphics.setColor(Config.colors.textDim)
  love.graphics.setFont(self.titleFont)
  love.graphics.print("Main menu", Config.menu.padding, startY + 10)

  startY = startY + Config.menu.titleHeight

  love.graphics.setFont(self.font)
  for i, item in ipairs(self.items) do
    local y = startY + (i - 1) * Config.menu.itemHeight

    if i == self.hoveredIndex then
      love.graphics.setColor(Config.colors.itemHover)
    else
      love.graphics.setColor(Config.colors.itemBg)
    end
    love.graphics.rectangle("fill", 0, y, Config.width, Config.menu.itemHeight)

    love.graphics.setColor(Config.colors.text)
    love.graphics.print(item.name, Config.menu.padding, y + 12)

    if item.hasSubmenu then
      love.graphics.print(item.icon, Config.width - 25, y + 12)
    end

    if i < #self.items then
      love.graphics.setColor(0.1, 0.12, 0.15)
      love.graphics.line(0, y + Config.menu.itemHeight, Config.width, y + Config.menu.itemHeight)
    end
  end
end

function Menu:drawSearch()
  local y = Config.height - Config.search.height

  love.graphics.setColor(Config.colors.searchBg)
  love.graphics.rectangle("fill", 0, y, Config.width, Config.search.height)

  love.graphics.setColor(Config.colors.text)
  love.graphics.setFont(self.font)

  local searchIconX = Config.width - 35
  local searchIconY = y + 18
  love.graphics.circle("line", searchIconX, searchIconY, 8, 20)
  love.graphics.line(searchIconX + 6, searchIconY + 6, searchIconX + 10, searchIconY + 10)

  if self.searchActive or self.searchText ~= "" then
    love.graphics.print(self.searchText, Config.search.padding, y + 15)

    if self.searchActive and math.floor(love.timer.getTime() * 2) % 2 == 0 then
      local textWidth = self.font:getWidth(self.searchText)
      love.graphics.line(
        Config.search.padding + textWidth + 2, y + 15,
        Config.search.padding + textWidth + 2, y + 30
      )
    end
  else
    love.graphics.setColor(Config.colors.textDim)
    love.graphics.print("Search", Config.search.padding, y + 15)
  end
end

function Menu:mousepressed(x, y, button)
  local searchY = Config.height - Config.search.height
  if y >= searchY then
    self.searchActive = true
  else
    self.searchActive = false
  end

  local menuStartY = Config.header.height + Config.menu.titleHeight
  if y >= menuStartY and y < menuStartY + (#self.items * Config.menu.itemHeight) then
    local index = math.floor((y - menuStartY) / Config.menu.itemHeight) + 1
    if index >= 1 and index <= #self.items then
      print("Clicked: " .. self.items[index].name)
    end
  end
end

function Menu:mousemoved(x, y)
  local menuStartY = Config.header.height + Config.menu.titleHeight
  if y >= menuStartY and y < menuStartY + (#self.items * Config.menu.itemHeight) then
    self.hoveredIndex = math.floor((y - menuStartY) / Config.menu.itemHeight) + 1
  else
    self.hoveredIndex = nil
  end
end

function Menu:textinput(text)
  if self.searchActive then
    self.searchText = self.searchText .. text
  end
end

function Menu:keypressed(key)
  if key == "backspace" and self.searchActive then
    self.searchText = self.searchText:sub(1, -2)
  end
end

return Menu