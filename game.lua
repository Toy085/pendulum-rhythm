local game = {}
function game.load()
    centerX = love.graphics.getWidth() / 2
    centerY = love.graphics.getHeight() / 2

    px = 0
    py = 0

    radius = 200
    angle = 0
    playerSpeed = 1.5
    
    playerDirection = 1

    clickSound = love.audio.newSource("osu-hit-sound.mp3", "static")
    music = love.audio.newSource("song.mp3", "stream")
    music:play()

    beatmap = {
        {time = 5.0},
        {time = 7.5},
    }

    score = 0
    combo = 0
    hitWindow = 0.3
end

function game.update(dt)
    angle = angle + playerSpeed * dt * playerDirection
    
    angle = angle % (math.pi * 2)

    px = centerX + math.cos(angle) * radius
    py = centerY + math.sin(angle) * radius
end

function game.keypressed(key)
    if key == "escape" then
        state = "menu"
    end
    if key == "space" then
        playerDirection = -playerDirection
        local sound = clickSound:clone()
        sound:play()
    end
end

function game.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", centerX, centerY, radius)

    love.graphics.setColor(1, 0, 0, 0.85)
    love.graphics.circle("fill", px, py, 20)
end
return game