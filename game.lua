local game = {}
function game.load()
    centerX = love.graphics.getWidth() / 2
    centerY = love.graphics.getHeight() / 2
end

function game.update(dt)
    -- Update game logic here
end

function game.keypressed(key)
    -- Handle game-specific key presses here
end

function game.draw()
    love.graphics.circle("fill", centerX, centerY, 50)
    -- Draw game-specific UI and elements here
end
return game