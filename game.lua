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

    playerCircleSize = 20

    songTimeAtLastFlip = 0
    angleAtLastFlip = 0

    clickSound = love.audio.newSource("osu-hit-sound.mp3", "static")

    songName = "Unknown Song"
    artistName = "Unknown Artist"
    backgroundImage = love.graphics.newImage("bg.png")
    beatmap = {}

    if _G.currentMapData then
        beatmap = _G.currentMapData.beatmap or {}
        
        if _G.currentMapData.title then
            songName = _G.currentMapData.title
        end

        if _G.currentMapData.artist then
            artistName = _G.currentMapData.artist
        end
        
        if _G.currentMapData.audio then
            local audioPath = "current_map/" .. _G.currentMapData.audio
            music = love.audio.newSource(audioPath, "stream")
            music:play()
        end
    end

    score = 0
    combo = 0
    hitWindow = 0.1

    feedbackText = "..."
    feedbackScale = 0
    feedbackAlpha = 0

    love.window.setTitle("Pendulum Rhythm - Playing: " .. songName .. " By " .. artistName)
end

function game.update(dt)
    if not music then
        return 
    end
    
    local currentTime = music:tell()
    local timeSinceFlip = currentTime - songTimeAtLastFlip

    for i = #beatmap, 1, -1 do
        if currentTime > beatmap[i].time + hitWindow then
            local missedNote = beatmap[i]
            table.remove(beatmap, i)
            combo = 0
            feedbackText = "Miss!"
            feedbackScale = 2.5
            feedbackAlpha = 1
            if missedNote.type == "n" then
                flipPlayer()
            end
        end
    end
    
    angle = angleAtLastFlip + (timeSinceFlip * playerSpeed * playerDirection)

    px = centerX + math.cos(angle) * radius
    py = centerY + math.sin(angle) * radius

    if playerCircleSize > 20 then
        playerCircleSize = playerCircleSize - dt * 40
        if playerCircleSize < 20 then
            playerCircleSize = 20
        end
    end
    if feedbackAlpha > 0 then
        -- Shrink the scale back toward 1
        if feedbackScale > 1 then
            feedbackScale = feedbackScale - dt * 5
        end
        -- Fade out the alpha
        feedbackAlpha = feedbackAlpha - dt * 2 
    end 
end

function game.keypressed(key)
    if key == "escape" then
        if music then music:stop() end
        state = "menu"
    end
    if key == "space" or key == "z" or key == "x" then
        local currentTime = music:tell()
        local hitSomething = false
        local noteIndex = -1

        for i, note in ipairs(beatmap) do
            local timeDifference = math.abs(currentTime - note.time)
            if timeDifference <= hitWindow then
                hitSomething = true
                noteIndex = i
                break
            end
        end

        if hitSomething then
            local hitNote = beatmap[noteIndex]
            local diff = math.abs(currentTime - beatmap[noteIndex].time)

            table.remove(beatmap, noteIndex)

            if hitNote.type == "n" then
                flipPlayer()
            end

            combo = combo + 1
            
            local accuracyBonus = hitWindow / math.max(diff, 0.01)
            local points = 10 * math.sqrt(combo) * accuracyBonus
            
            score = score + math.floor(points)

            if diff < 0.03 then
                feedbackText = "PERFECT!"
            elseif diff < 0.06 then
                feedbackText = "GREAT!"
            else
                feedbackText = "OK!"
            end

            feedbackScale = 2.5
            feedbackAlpha = 1

            local sound = clickSound:clone()
            sound:play()
            playerCircleSize = 25
        else
            combo = 0
            feedbackText = "Too Early!"
            feedbackScale = 2.5
            feedbackAlpha = 1
        end
    end
end

function game.draw()
    -- Background
    love.graphics.setColor(1, 1, 1, 0.2 * playerCircleSize / 25)
    love.graphics.draw(backgroundImage, 0, 0, 0, love.graphics.getWidth() / backgroundImage:getWidth(), love.graphics.getHeight() / backgroundImage:getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    -- Orbit circle
    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", centerX, centerY, radius)

    -- Player
    love.graphics.setColor(1, 0, 0, 0.85)
    love.graphics.circle("fill", px, py, playerCircleSize)

    -- Pendulum arm
    love.graphics.setLineWidth(5)
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.line(centerX, centerY, px, py)
    -- Reset line width
    love.graphics.setLineWidth(1)

    -- UI
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Combo: " .. combo, 10, 30)
    if feedbackAlpha > 0 then
        love.graphics.setColor(1, 1, 1, feedbackAlpha)
        
        local font = love.graphics.getFont()
        local textWidth = centerX * 2
        local textHeight = font:getHeight()

        -- printf(text, x, y, limit, align, r, sx, sy, ox, oy)
        love.graphics.printf(feedbackText, 0, centerY - 100, textWidth / feedbackScale, "center", 0, feedbackScale, feedbackScale, 0, textHeight / 2)
    end

    -- Notes
    local tempDir = playerDirection
    local tempTime = songTimeAtLastFlip
    local tempAngle = angleAtLastFlip

    for i, note in ipairs(beatmap) do
        local currentTime = music:tell()
        local timeRemaining = note.time - currentTime

        local noteAngle = tempAngle + ((note.time - tempTime) * playerSpeed * tempDir)
    
        -- Draw note if it is coming soon (1.5 seconds)
        if timeRemaining > 0 and timeRemaining < 1.5 then
            local nx = centerX + math.cos(noteAngle) * radius
            local ny = centerY + math.sin(noteAngle) * radius

            local alpha = 1 - (timeRemaining / 1.5)

            love.graphics.setColor(1, 1, 1 * (i - 1), alpha - 0.2)
            love.graphics.circle("fill", nx, ny, 20)

            love.graphics.setColor(0, 0, 0, alpha) -- Black text
            love.graphics.printf(tostring(i), nx - 20, ny - 10, 30, "center", 0, 1.5, 1.5)
            
            love.graphics.setColor(1, 1, 1)
        end
        tempAngle = noteAngle
        tempTime = note.time
        if note.type == "n" then
            tempDir = -tempDir
        end
    end
end

function flipPlayer()
    angleAtLastFlip = angle
    songTimeAtLastFlip = music:tell()

    playerDirection = -playerDirection
end

return game