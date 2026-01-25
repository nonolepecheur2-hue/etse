local Menu = require("menu")
local Config = require("config")

function love.load()
  love.window.setTitle("Phaze Menu")
  love.window.setMode(Config.width, Config.height)
  love.graphics.setBackgroundColor(0.11, 0.13, 0.16)

  Menu:init()
end

function love.update(dt)
  Menu:update(dt)
end

function love.draw()
  Menu:draw()
end

function love.mousepressed(x, y, button)
  Menu:mousepressed(x, y, button)
end

function love.mousemoved(x, y)
  Menu:mousemoved(x, y)
end

function love.textinput(text)
  Menu:textinput(text)
end

function love.keypressed(key)
  Menu:keypressed(key)
end