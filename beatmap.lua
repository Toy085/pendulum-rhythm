local beatmap = {}

function beatmap.loadBeatmap(filename)
    local file = io.open(filename, "rb")
    if not file then
        print("Could not open beatmap file from OS: " .. filename)
        return nil
    end
    local rawZipData = file:read("*a")
    file:close()

    local tempFile = "temp_map.zip"
    love.filesystem.write(tempFile, rawZipData)

    if not love.filesystem.mount(tempFile, "current_map") then
        print("Could not mount beatmap archive.")
        return nil
    end

    local contents, err = love.filesystem.read("current_map/manifest.json")
    if not contents then
        print("Could not read manifest.json inside the beatmap: " .. tostring(err))
        love.filesystem.unmount(tempFile)
        return nil
    end

    local success, data = pcall(json.decode, contents)

    if success then
        _G.currentMountedMap = tempFile 
        return data
    else
        print("Error parsing beatmap JSON: " .. tostring(data))
        love.filesystem.unmount(tempFile)
        return nil
    end
end

function beatmap.saveBeatmap(filename, beatmapData)
    local file = io.open(filename, "w")

    if not file then
        print("Could not open beatmap file for writing: " .. filename)
        return false
    end

    local content = json.encode(beatmapData)

    file:write(content)
    file:close()

    return true
end

function beatmap.createBeatmap(filename)
    local newData = {
        title = "New Song",
        artist = "Unknown Artist",
        mapper = "Unknown Mapper",
        bpm = 120,
        difficulty = "Easy",
        audio = "",
        image = "",
        previewStart = 0,
        previewDuration = 10,
        beatmapVersion = 1,
        beatmap = {}
    }

    if filename and filename ~= "" then
        beatmap.saveBeatmap(filename, newData)
    end

    return newData
end

return beatmap