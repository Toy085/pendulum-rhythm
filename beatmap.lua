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
        _G.originalFilename = filename
        return data
    else
        print("Error parsing beatmap JSON: " .. tostring(data))
        love.filesystem.unmount(tempFile)
        return nil
    end
end

function beatmap.saveBeatmap(filename, beatmapData)
    local absSaveDir = love.filesystem.getSaveDirectory()
    local tempDirName = "temp_export"
    local absTempDir = absSaveDir .. "/" .. tempDirName

    nativefs.createDirectory(absTempDir)

    -- Deep-copy beatmapData so we don't mutate the live table
    local exportData = {}
    for k, v in pairs(beatmapData) do exportData[k] = v end

    -- Extract assets BEFORE unmounting (current_map is still mounted here)
    local assets = { "audio", "image" }
    for _, key in ipairs(assets) do
        local sourcePath = exportData[key]
        if sourcePath and sourcePath ~= "" then
            local destName
            if key == "audio" then
                destName = "song" .. (sourcePath:match("^.+(%.[^.]+)$") or ".mp3")
            else
                destName = "cover" .. (sourcePath:match("^.+(%.[^.]+)$") or ".png")
            end

            local fileData = nil
            if love.filesystem.getInfo("current_map/" .. sourcePath) then
                fileData = love.filesystem.read("current_map/" .. sourcePath)
            elseif nativefs.getInfo(sourcePath) then
                fileData = nativefs.read(sourcePath)
            end

            if fileData then
                nativefs.write(absTempDir .. "/" .. destName, fileData)
                exportData[key] = destName
            else
                print("Warning: could not find asset for key '" .. key .. "': " .. sourcePath)
            end
        end
    end

    -- Write manifest
    nativefs.write(absTempDir .. "/manifest.json", json.encode(exportData))

    -- NOW unmount before touching the zip
    love.filesystem.unmount("temp_map.zip")

    -- Resolve absolute save path
    -- Strip any extension then enforce .prbm
    local zipFullPath
    if filename:find("[\\/]") or filename:find(":") then
        zipFullPath = filename
    else
        zipFullPath = absSaveDir .. "/" .. filename
    end
    zipFullPath = zipFullPath:gsub("%.[^./\\]+$", "") .. ".prbm"

    os.remove(zipFullPath)

    -- Use Python script to create the .prbm file
    local cmd = 'python save_beatmap.py "' .. zipFullPath .. '" "' .. absTempDir .. '/manifest.json"'
    if exportData.audio and exportData.audio:find("song") then
        cmd = cmd .. ' --audio "' .. absTempDir .. '/' .. exportData.audio .. '"'
    end
    if exportData.image and exportData.image:find("cover") then
        cmd = cmd .. ' --image "' .. absTempDir .. '/' .. exportData.image .. '"'
    end

    print("Executing Python: " .. cmd)
    local exitCode = os.execute(cmd)
    local success = (exitCode == true) or (exitCode == 0)

    if success then
        -- Read the new zip back and mount it
        local zipData, err = nativefs.read(zipFullPath)
        if zipData then
            love.filesystem.write("temp_map.zip", zipData)
            love.filesystem.mount("temp_map.zip", "current_map")
            _G.currentMountedMap = zipFullPath
        else
            print("Save succeeded but could not re-read zip: " .. tostring(err))
        end
    else
        print("ZIP command failed with exit code: " .. tostring(exitCode))
    end

    return success
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