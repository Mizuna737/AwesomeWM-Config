--------------------------------
-- defaultApps.lua
-- Central file defining default applications
--------------------------------

local defaultApps = {
    terminalCommand = "alacritty -e tmux",
    terminal = "alacritty",
    browserCommand = "zen-browser",
    browser = "zen",
    zen = "zen-browser",
    editor = "vscodium",
    fileManagerCommand = "QT_QPA_PLATFORMTHEME=qt5ct QT_STYLE_OVERRIDE=kvantum dolphin",
    fileManager = "dolphin"
}

return defaultApps