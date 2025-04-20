-------------
-- HELPERS --
-------------
function copyTable(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then copy[k] = copyTable(v) else copy[k] = v end
    end
    return copy
end
-- PRO
function debugPrintColor(color)
    local r = color & 0xFF
    local g = (color >> 8) & 0xFF
    local b = (color >> 16) & 0xFF
    local a = (color >> 24) & 0xFF
    print(r .. ", " .. g .. ", " .. b .. ", " .. a)
    print(" ")
end
-- PRO
function IntToBool(integer)
    return integer ~= 0
end

--------------------
-- DEFAULT VALUES --
--------------------
local script_path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]]
local settings_file = script_path .. "Duplicate Selection (Pro)_settings.txt"

local default_settings = {
    ["repeat"] = 1,
    ["x_offset"] = 0,
    ["y_offset"] = 0,

    ["dlg_x"] = 100,
    ["dlg_y"] = 100,
    ["dlg_w"] = 183,
    ["dlg_h"] = 162,
-- PRO
    ["preset_1_x"] = 16,
    ["preset_1_y"] = 0,
    ["preset_2_x"] = 0,
    ["preset_2_y"] = 16,
    ["preset_3_x"] = 4,
    ["preset_3_y"] = -2,
    ["preset_1_repeat"] = 1,
    ["preset_2_repeat"] = 1,
    ["preset_3_repeat"] = 1,
-- PRO
    ["deselect"] = 0,
    ["show_presets"] = 1,
    ["show_repeat_slider"] = 1,
    ["show_offset_slider"] = 1,
    ["repeat_slider_limit_min"] = 1,
    ["repeat_slider_limit"] = 30,
    ["offset_slider_limit"] = 50
}

local settings = copyTable(default_settings)
local dlg = Dialog{ title="Duplicate Selection (Pro)" }

---------------
-- FUNCTIONS --
---------------
local function updateFields()
    -- Synchronizes input fields and sliders
    dlg:modify{ id="x_input",
                text=tostring(settings["x_offset"]) }
    dlg:modify{ id="y_input",
                text=tostring(settings["y_offset"]) }
    dlg:modify{ id="edit_repeat",
                text=tostring(settings["repeat"]) }
    dlg:modify{ id="x_slider",
                value=settings["x_offset"] }
    dlg:modify{ id="y_slider",
                value=settings["y_offset"] }
    dlg:modify{ id="slider_repeat",
                value=settings["repeat"] }
end

local function loadSettings()
    -- Reads settings from file
    local file = io.open(settings_file, "r")
    if file then
        for line in file:lines() do
            local key, value = line:match("([^=]+)=([^=]+)")
            if key and value then
                settings[key] = tonumber(value)
            end
        end
        file:close()
    end
-- PRO
    local dlg_height = default_settings["dlg_h"]
    if not IntToBool(settings["deselect"]) then
        dlg_height = dlg_height + 21
    end
    if IntToBool(settings["show_presets"]) then
        dlg_height = dlg_height + 42
    end
    if IntToBool(settings["show_repeat_slider"]) then
        dlg_height = dlg_height + 21
    end 
    if IntToBool(settings["show_offset_slider"]) then
        dlg_height = dlg_height + 21
    end
    settings.dlg_h = dlg_height
-- PRO
    dlg_bounds = Rectangle(settings.dlg_x, settings.dlg_y, settings.dlg_w, settings.dlg_h)
end

local function saveSettings(save_default)
    -- Writes settings to file
    local file = io.open(settings_file, "w")
    if file then
        file:write("-- Last used duplication offsets --\n")
        file:write(string.format("x_offset=%d\n", settings["x_offset"]))
        file:write(string.format("y_offset=%d\n", settings["y_offset"]))
        file:write("\n-- Last used repeat duplication count --\n")
        file:write(string.format("repeat=%d\n", settings["repeat"]))
        file:write("\n-- Position and dimensions of the dialog box --\n")
        if save_default then
            file:write(string.format("dlg_x=%d\n", settings["dlg_x"]))
            file:write(string.format("dlg_y=%d\n", settings["dlg_y"]))
            file:write(string.format("dlg_w=%d\n", settings["dlg_w"]))
            file:write(string.format("dlg_h=%d\n", settings["dlg_h"]))
        else
            dlg_bounds = dlg.bounds
            file:write(string.format("dlg_x=%d\n", dlg_bounds.x))
            file:write(string.format("dlg_y=%d\n", dlg_bounds.y))
            file:write(string.format("dlg_w=%d\n", dlg_bounds.width))
            file:write(string.format("dlg_h=%d\n", dlg_bounds.height))
        end

        file:write("\n-- Presets --\n")
        for i = 1, 3 do
            file:write(string.format("preset_" .. i .. "_x=%d\n", settings["preset_" .. i .. "_x"] or 0))
            file:write(string.format("preset_" .. i .. "_y=%d\n", settings["preset_" .. i .. "_y"] or 0))
            file:write(string.format("preset_" .. i .. "_repeat=%d\n", settings["preset_" .. i .. "_repeat"] or 1))
        end
-- PRO
        file:write("\n-- Options --\n")
        file:write(string.format("deselect=%d\n", settings["deselect"]))
        file:write(string.format("show_presets=%d\n", settings["show_presets"]))
        file:write(string.format("show_repeat_slider=%d\n", settings["show_repeat_slider"]))
        file:write(string.format("show_offset_slider=%d\n", settings["show_offset_slider"]))
        file:write(string.format("repeat_slider_limit=%d\n", settings["repeat_slider_limit"]))
        file:write(string.format("offset_slider_limit=%d\n", settings["offset_slider_limit"]))
-- PRO
        file:close()
    end
end
-- PRO
local function loadPreset(preset_number)
    -- Loads offset preset given by "preset_number" from settings file
    if preset_number >= 1 and preset_number <= 3 then
        settings["x_offset"] = settings["preset_" .. preset_number .. "_x"]
        settings["y_offset"] = settings["preset_" .. preset_number .. "_y"]
        settings["repeat"]   = settings["preset_" .. preset_number .. "_repeat"]

        if settings["repeat"] < 1 then
            dlg:modify{
                id="edit_repeat",
                text="1"
            }
        else
            dlg:modify{
                id="edit_repeat",
                text=tostring(settings["repeat"])
        }
        end

        updateFields()
    end
end

local function savePreset(preset_number)
    -- Stores offset preset given by "preset_number" to settings file
    if preset_number >= 1 and preset_number <= 3 then
        settings["preset_" .. preset_number .. "_x"] = settings["x_offset"]
        settings["preset_" .. preset_number .. "_y"] = settings["y_offset"]
        settings["preset_" .. preset_number .. "_repeat"] = settings["repeat"]
        saveSettings()
    end
end
-- PRO
local function performDuplication(SHIFT_SELECTION)
    saveSettings()

    -- Check if layer has content:
    if not app.cel then
        app.alert("No active cel found.")
        return
    end

    -- Create new transaction = group several sprite modifications in one undo/redo operation
    app.transaction("Duplicate Selection", function()
        local current_image = app.cel.image
        local selection = app.sprite.selection
        local sel_bounds = selection.bounds
        if sel_bounds.width == 0 or sel_bounds.height == 0 then
            return
        end
        local cel_pos = app.cel.position
        local repeat_value = settings["repeat"]

        -- Create expanded image with transparency, copy existing image into expanded image
        local full_width = app.sprite.width
        local full_height = app.sprite.height
        local expanded_image = Image(full_width, full_height, current_image.colorMode)
        expanded_image:clear()
        expanded_image:drawImage(current_image, Point(cel_pos.x, cel_pos.y))

        -- Copy only selected pixels that are inside the cel bounds
        for y = sel_bounds.y, sel_bounds.y + sel_bounds.height - 1 do
            for x = sel_bounds.x, sel_bounds.x + sel_bounds.width - 1 do
                if selection:contains(x, y) and 
                    (x >= cel_pos.x and x < cel_pos.x+current_image.width) and
                    (y >= cel_pos.y and y < cel_pos.y+current_image.height) then
                    -- Translate to cel-local (image) coordinates
                        image_x = x - cel_pos.x
                        image_y = y - cel_pos.y

                    local color = current_image:getPixel(image_x, image_y)
                    for i = 1, repeat_value do
                        expanded_image:drawPixel(
                            x + i * settings["x_offset"], 
                            y + i * settings["y_offset"], 
                            color)
                    end
                end
            end
        end
        
        -- Crop excessive transparent pixels so the cel tightly encloses visible pixels
        local opaque_bounds = expanded_image:shrinkBounds()
        local cropped_image = Image(opaque_bounds.width, opaque_bounds.height, current_image.colorMode)
        cropped_image:clear()
        cropped_image:drawImage(expanded_image, -opaque_bounds.x, -opaque_bounds.y)

        -- Assign the cropped image to the cel, update the cel's position
        app.cel.image = cropped_image
        app.cel.position = Point{ x=opaque_bounds.x, y=opaque_bounds.y }

        -- Shift the selection itself by the same offset as pixels (if not Deselect)
        if settings["deselect"] == 1 then
            selection:deselect()
        elseif SHIFT_SELECTION then
            local new_selection = Selection()
            for y = sel_bounds.y, sel_bounds.y + sel_bounds.height - 1 do
                for x = sel_bounds.x, sel_bounds.x + sel_bounds.width - 1 do
                    if selection:contains(x, y) then
                        new_selection:add(Rectangle(
                            x + settings["x_offset"] * repeat_value, 
                            y + settings["y_offset"] * repeat_value, 
                            1, 1))
                    end
                end
            end
            app.sprite.selection = new_selection
        end
    end)

    app.refresh()
end
-- PRO
local function resetToDefaultSettings()
    -- Restores all settigns to their default values (see the DEFAULT VALUES section in the beginning)
    local confirm = app.alert{
        title="Confirm Reset",
        text={"Are you sure you want to reset all settings to default values?", "(including Presets!)"},
        buttons = { "Yes", "No" }
    }

    if confirm == 1 then
        dlg_options:close()
        dlg:close()

        settings = copyTable(default_settings)
        saveSettings(true)
        dlg_options = nil

        createMainDialogBox()
    end
end
-- PRO
---------------------
-- MAIN DIALOG BOX --
---------------------
function createMainDialogBox()
    loadSettings()

    dlg = Dialog{ title="Duplicate Selection (Pro)" }
    dlg
-- PRO
        :button{
            id="button_options",
            text="Options",
            onclick=function()
                createOptionsDialogBox()
            end
        }
-- PRO
        :button{
            id="close",
            text="CLOSE",
            onclick=function()
                saveSettings()
                dlg:close()
            end
        }

        :separator()
-- PRO
        :label{ 
            id="empty",
            text="",
            visible=IntToBool(settings["show_presets"])
        }
        :label{ 
            id="preset_1",
            text="Preset 1:  ",
            visible=IntToBool(settings["show_presets"])
        }
        :label{ 
            id="preset_2",
            text="Preset 2: ",
            visible=IntToBool(settings["show_presets"])
        }
        :label{ 
            id="preset_3",
            text=" Preset 3:",
            visible=IntToBool(settings["show_presets"])
        }

        :newrow()

        :button{ 
            id="preset_1_S",
            text="S",
            visible=IntToBool(settings["show_presets"]),
            onclick=function()
               savePreset(1)
            end
        }
        :button{ 
            id="preset_1_L",
            text="L",
            visible=IntToBool(settings["show_presets"]),
            onclick=function()
               loadPreset(1)
            end
        }
        :button{ 
            id="preset_2_S",
            text="S",
            visible=IntToBool(settings["show_presets"]),
            onclick=function()
               savePreset(2)
            end
        }
        :button{ 
            id="preset_2_L",
            text="L",
            visible=IntToBool(settings["show_presets"]),
            onclick=function()
               loadPreset(2)
            end
        }
        :button{ 
            id="preset_3_S",
            text="S",
            visible=IntToBool(settings["show_presets"]),
            onclick=function()
               savePreset(3)
            end
        }
        :button{ 
            id="preset_3_L",
            text="L",
            visible=IntToBool(settings["show_presets"]),
            onclick=function()
               loadPreset(3)
            end
        }

        if IntToBool(settings["show_presets"]) then
            dlg:separator()
        end
-- PRO
     dlg:label{
            id="label_repeat",
            text="Repeat duplication:"
        }
        :number{ 
            id="edit_repeat",
            text=tostring(settings["repeat"]),
            onchange=function()
                -- Check if repeat duplication >= 1
                local repeat_value = tonumber(dlg.data.edit_repeat)
                if repeat_value < 1 then
                    dlg:modify{
                        id="edit_repeat",
                        text="1"
                    }
                end
                settings["repeat"] = repeat_value
                updateFields()
            end
        }
        :slider{ 
            id="slider_repeat",
            min=settings["repeat_slider_limit_min"],
            max=settings["repeat_slider_limit"],
            value=settings["repeat"],
            visible=IntToBool(settings["show_repeat_slider"]),
            onchange=function()
                settings["repeat"] = dlg.data.slider_repeat
                updateFields()
            end
        }

        :label{
            id="label_offsets",
            label="",
            text="X Offset:"
        }
        :label{
            id="label_offsets",
            text="Y Offset:"
        }

        :entry{ 
            id="x_input",
            text=tostring(settings["x_offset"]),
            focus=true,
            onchange=function()
                local input = tonumber(dlg.data.x_input)
                if input then
                    settings["x_offset"] = input
                    updateFields()
                end
            end
        }
        :entry{ 
            id="y_input",
            text=tostring(settings["y_offset"]),
            onchange=function()
                local input = tonumber(dlg.data.y_input)
                if input then
                    settings["y_offset"] = tonumber(dlg.data.y_input)
                    updateFields()
                end
            end
        }

        :slider{ 
            id="x_slider",
            min=-settings["offset_slider_limit"],
            max=settings["offset_slider_limit"],
            value=settings["x_offset"],
            visible=IntToBool(settings["show_offset_slider"]),
            onchange=function()
                settings["x_offset"] = dlg.data.x_slider
                updateFields()
            end
        }
        :slider{ 
            id="y_slider",
            min=-settings["offset_slider_limit"],
            max=settings["offset_slider_limit"],
            value=settings["y_offset"],
            visible=IntToBool(settings["show_offset_slider"]),
            onchange=function()
                settings["y_offset"] = dlg.data.y_slider
                updateFields()
            end
        }

        :button{ 
            id="reset_x",
            text="Reset X",
            onclick=function()
               settings["x_offset"] = 0
               updateFields()
            end
        }
        :button{ 
            id="reset_y",
            text="Reset Y",
            onclick=function()
               settings["y_offset"] = 0
               updateFields()
            end
        }
        :button{
            id="reset_both",
            text="Reset X,Y",
            onclick=function()
               settings["x_offset"] = 0
               settings["y_offset"] = 0
               updateFields()
            end
        }
        
        :separator() 

        :button{
            id="duplicate",
            text="Duplicate",
            onclick=function()
                performDuplication(false)
            end
        }

        :newrow() 

        :button{ 
            id="duplicate_shift",
            text="Duplicate (+shift selection)",
            visible=not IntToBool(settings["deselect"]),
            onclick=function()
                performDuplication(true)
            end
        }

        :show{
            wait=false,    -- Keep the dialog open without blocking Aseprite
            bounds=dlg_bounds
            }
end

-- PRO
------------------------
-- OPTIONS DIALOG BOX --
------------------------
function createOptionsDialogBox()
    local height_change = 0
    dlg_options = Dialog{ title="Options" }

    dlg_options
        :check{
            id="check_deselect",
            text="Auto-deselect after duplication",
            selected=IntToBool(settings["deselect"])
        }

        :separator()

        :check{
            id="check_show_presets",
            text="Show presets",
            selected=IntToBool(settings["show_presets"])
        }
        :newrow()
        :check{
            id="check_show_repeat_slider",
            text="Show repeat slider",
            selected=IntToBool(settings["show_repeat_slider"])
        }
        :newrow()
        :check{
            id="check_show_offset_slider",
            text="Show offset sliders",
            selected=IntToBool(settings["show_offset_slider"])
        }

        :separator()

        :label{
            text="Repeat slider limit:"
        }
        :number{
            id="repeat_slider_limit",
            text=tostring(settings["repeat_slider_limit"]),
            focus=true
        }

        :label{
            text="Offset slider limit:"
        }
        :number{
            id="offset_slider_limit",
            text=tostring(settings["offset_slider_limit"])
        }

        :separator()

        :button{
            id="reset_settings",
            text="Reset to factory settings",
            onclick=function()
                resetToDefaultSettings()
            end
        }

        :separator()

        :label{
            text=" "
        }

        :button{
            id="save_options",
            text="Save",
            onclick=function()
                if dlg_options.data.check_deselect then
                    settings["deselect"] = 1
                else
                    settings["deselect"] = 0
                end
                if dlg_options.data.check_show_presets then
                    settings["show_presets"] = 1
                else
                    settings["show_presets"] = 0
                end
                if dlg_options.data.check_show_repeat_slider then
                    settings["show_repeat_slider"] = 1
                else
                    settings["show_repeat_slider"] = 0
                end
                if dlg_options.data.check_show_offset_slider then
                    settings["show_offset_slider"] = 1
                else
                    settings["show_offset_slider"] = 0
                end
                settings["repeat_slider_limit"] = tonumber(dlg_options.data.repeat_slider_limit)
                settings["offset_slider_limit"] = tonumber(dlg_options.data.offset_slider_limit)
                dlg.bounds.height = dlg.bounds.height + height_change

                dlg_options:close()
                dlg:close()

                saveSettings()
                dlg = nil
                dlg_options = nil

                createMainDialogBox()
            end
        }
        :button{
            id="cancel_options",
            text="Cancel",
            onclick=function()
                dlg_options:close()
                dlg_options = nil
            end
        }

        :show{ wait=true }
end
-- PRO

createMainDialogBox()