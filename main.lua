local game = require("game")
local editor = require("editor")

state = "play" -- Can be "menu", "play", or "edit"

function love.load()
    if state == "play" then
        game.load()
    elseif state == "edit" then
        editor.load()
    end
end

function love.update(dt)
    if state == "play" then
        game.update(dt)
    elseif state == "edit" then
        editor.update(dt)
    end
end

function love.draw()
    if state == "play" then
        game.draw()
    elseif state == "edit" then
        editor.draw()
    end
end

function love.keypressed(key)
    if state == "play" then
        game.keypressed(key)
    elseif state == "edit" then
        editor.keypressed(key)
    end
end