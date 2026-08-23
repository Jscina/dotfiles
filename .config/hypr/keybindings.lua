-- █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
-- █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█
--
-- Converted from hyprlang (hyprland.conf) to the Lua config API
-- introduced in Hyprland 0.55. See https://wiki.hypr.land/Configuring/Start/
--
-- require() this file from your main hyprland.lua, e.g.:
--   require("keybinds")

------------------------
---- VARIABLES ----------
------------------------

-- NOTE: $mainMod and $scrPath weren't defined in the snippet you shared —
-- they're presumably set in another sourced file (this looks like a HyDE
-- dotfiles setup). Adjust these two to match your actual setup.
local mainMod = "SUPER"
local scrPath = os.getenv("SCRIPTS_DIR") or (os.getenv("HOME") .. "/.local/lib/hyde")

local terminal = "kitty"
local editor = "nvim"
local explorer = "dolphin"
local browser = "zen-browser"
local word_processor = "libreoffice --writer"
local rofiLaunch = scrPath .. "/rofilaunch.sh"

-------------------------------------
---- WINDOW MANAGEMENT --------------
-------------------------------------

hl.bind(mainMod .. " + Delete", hl.dsp.exec_cmd("hyde-shell logout"), { desc = "kill hyprland session" })
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), { desc = "toggle floating" })
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { desc = "toggle group" })
hl.bind(
	mainMod .. " + F",
	hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
	{ desc = "toggle fullscreen" }
)
hl.bind(mainMod .. " + ALT + SHIFT + L", hl.dsp.exec_cmd("lockscreen.sh"), { desc = "lock screen" })
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(scrPath .. "/logoutlaunch.sh"), { desc = "logout menu" })
hl.bind("Alt_R + Control_R", hl.dsp.exec_cmd("hyde-shell waybar --hide"), { desc = "toggle waybar and reload config" })
-- Toggle waybar without reloading (faster), uncomment if you want it back:
-- hl.bind("Alt_R + Control_R", hl.dsp.exec_cmd("killall waybar || waybar"))

-------------------------------------
---- GROUP NAVIGATION ---------------
-------------------------------------

hl.bind(mainMod .. " + ALT + H", hl.dsp.group.prev(), { desc = "change active group backwards" })
hl.bind(mainMod .. " + ALT + L", hl.dsp.group.next(), { desc = "change active group forwards" })

-------------------------------------
---- CHANGE FOCUS -------------------
-------------------------------------

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), { desc = "focus left" })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), { desc = "focus down" })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), { desc = "focus up" })
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), { desc = "focus right" })

-------------------------------------
---- RESIZE ACTIVE WINDOW -----------
-------------------------------------

hl.bind(
	mainMod .. " + SHIFT + CTRL + L",
	hl.dsp.window.resize({ x = 30, y = 0 }),
	{ repeating = true, desc = "resize window right" }
)
hl.bind(
	mainMod .. " + SHIFT + CTRL + H",
	hl.dsp.window.resize({ x = -30, y = 0 }),
	{ repeating = true, desc = "resize window left" }
)
hl.bind(
	mainMod .. " + SHIFT + CTRL + K",
	hl.dsp.window.resize({ x = 0, y = -30 }),
	{ repeating = true, desc = "resize window up" }
)
hl.bind(
	mainMod .. " + SHIFT + CTRL + J",
	hl.dsp.window.resize({ x = 0, y = 30 }),
	{ repeating = true, desc = "resize window down" }
)

-------------------------------------------------
---- MOVE ACTIVE WINDOW ACROSS WORKSPACE --------
-------------------------------------------------

-- Your original used a shell one-liner that checked hyprctl for floating
-- state and branched between `moveactive` (floating) and `movewindow`
-- (tiled). Lua lets us do that natively instead of shelling out:
local function moveActiveWindow(dx, dy, dir)
	return function()
		local w = hl.get_active_window()
		if w ~= nil and w.floating then
			hl.dispatch(hl.dsp.window.move({ x = dx, y = dy, relative = true }))
		else
			hl.dispatch(hl.dsp.window.move({ direction = dir }))
		end
	end
end

hl.bind(
	mainMod .. " + SHIFT + H",
	moveActiveWindow(-30, 0, "left"),
	{ repeating = true, desc = "Move active window to the left" }
)
hl.bind(
	mainMod .. " + SHIFT + L",
	moveActiveWindow(30, 0, "right"),
	{ repeating = true, desc = "Move active window to the right" }
)
hl.bind(mainMod .. " + SHIFT + K", moveActiveWindow(0, -30, "up"), { repeating = true, desc = "Move active window up" })
hl.bind(
	mainMod .. " + SHIFT + J",
	moveActiveWindow(0, 30, "down"),
	{ repeating = true, desc = "Move active window down" }
)

-------------------------------------
---- MOVE & RESIZE WITH MOUSE -------
-------------------------------------

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, desc = "hold to move window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, desc = "hold to resize window" })
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(), { desc = "hold to move window" })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { desc = "hold to resize window" })

-------------------------------------
---- LAUNCHER: APPS -----------------
-------------------------------------

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("app2unit -- " .. terminal), { desc = "terminal emulator" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("app2unit -- " .. explorer), { desc = "file explorer" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("app2unit -- " .. browser), { desc = "web browser" })
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("app2unit -- " .. word_processor), { desc = "word processor" })

-------------------------------------
---- LAUNCHER: ROFI MENUS -----------
-------------------------------------

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("pkill -x rofi || " .. rofiLaunch .. " d"), { desc = "application finder" })
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("pkill -x rofi || " .. rofiLaunch .. " w"), { desc = "window switcher" })
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("pkill -x rofi || " .. rofiLaunch .. " f"), { desc = "file finder" })
hl.bind(
	mainMod .. " + slash",
	hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/keybinds_hint.sh c"),
	{ desc = "keybindings hint" }
)
hl.bind(
	mainMod .. " + comma",
	hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/emoji-picker.sh"),
	{ desc = "emoji picker" }
)
hl.bind(
	mainMod .. " + period",
	hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/glyph-picker.sh"),
	{ desc = "glyph picker" }
)
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/cliphist.sh -c"), { desc = "clipboard" })
hl.bind(
	mainMod .. " + SHIFT + V",
	hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/cliphist.sh"),
	{ desc = "clipboard manager" }
)
hl.bind(
	mainMod .. " + SHIFT + A",
	hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofiselect.sh"),
	{ desc = "select rofi launcher" }
)

-------------------------------------
---- HARDWARE: AUDIO ----------------
-------------------------------------

hl.bind("F10", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o m"), { locked = true, desc = "toggle mute output" })
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o m"),
	{ locked = true, desc = "toggle mute output" }
)
hl.bind(
	"F11",
	hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o d"),
	{ locked = true, repeating = true, desc = "decrease volume" }
)
hl.bind(
	"F12",
	hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o i"),
	{ locked = true, repeating = true, desc = "increase volume" }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -i m"),
	{ locked = true, desc = "un/mute microphone" }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o d"),
	{ locked = true, repeating = true, desc = "decrease volume" }
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o i"),
	{ locked = true, repeating = true, desc = "increase volume" }
)

-------------------------------------
---- HARDWARE: MEDIA ----------------
-------------------------------------

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "play media" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "pause media" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, desc = "next media" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, desc = "previous media" })

-------------------------------------
---- HARDWARE: BRIGHTNESS -----------
-------------------------------------

hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd(scrPath .. "/brightnesscontrol.sh i"),
	{ locked = true, repeating = true, desc = "increase brightness" }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(scrPath .. "/brightnesscontrol.sh d"),
	{ locked = true, repeating = true, desc = "decrease brightness" }
)

-------------------------------------
---- UTILITIES ----------------------
-------------------------------------

hl.bind(
	mainMod .. " + K",
	hl.dsp.exec_cmd(scrPath .. "/keyboardswitch.sh"),
	{ locked = true, desc = "toggle keyboard layout" }
)
hl.bind(
	mainMod .. " + ALT + K",
	hl.dsp.exec_cmd(scrPath .. "/keyboardswitch.sh"),
	{ locked = true, desc = "toggle keyboard layout" }
)

-------------------------------------
---- SCREEN CAPTURE -----------------
-------------------------------------

hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd("hyprpicker -an"), { desc = "color picker" })
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(scrPath .. "/screenshot.sh s"), { desc = "snip screen" })
hl.bind(mainMod .. " + CTRL + Y", hl.dsp.exec_cmd(scrPath .. "/screenshot.sh sf"), { desc = "freeze and snip screen" })
hl.bind(
	mainMod .. " + ALT + Y",
	hl.dsp.exec_cmd(scrPath .. "/screenshot.sh m"),
	{ locked = true, desc = "print monitor" }
)
hl.bind("Print", hl.dsp.exec_cmd(scrPath .. "/screenshot.sh p"), { locked = true, desc = "print all monitors" })

-------------------------------------
---- THEMING AND WALLPAPER ----------
-------------------------------------

hl.bind(
	mainMod .. " + ALT + right",
	hl.dsp.exec_cmd(scrPath .. "/wallpaper.sh -Gn"),
	{ desc = "next global wallpaper" }
)
hl.bind(
	mainMod .. " + ALT + left",
	hl.dsp.exec_cmd(scrPath .. "/wallpaper.sh -Gp"),
	{ desc = "previous global wallpaper" }
)
hl.bind(
	mainMod .. " + SHIFT + W",
	hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/wallpaper.sh -SG"),
	{ desc = "select a global wallpaper" }
)
hl.bind(mainMod .. " + ALT + up", hl.dsp.exec_cmd(scrPath .. "/wbarconfgen.sh n"), { desc = "next waybar layout" })
hl.bind(
	mainMod .. " + ALT + down",
	hl.dsp.exec_cmd(scrPath .. "/wbarconfgen.sh p"),
	{ desc = "previous waybar layout" }
)
hl.bind(
	mainMod .. " + SHIFT + R",
	hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/wallbashtoggle.sh -m"),
	{ desc = "wallbash mode selector" }
)
hl.bind(
	mainMod .. " + SHIFT + T",
	hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/themeselect.sh"),
	{ desc = "select a theme" }
)
hl.bind(
	mainMod .. " + SHIFT + A",
	hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/animations.sh --select"),
	{ desc = "select animations" }
)
hl.bind(
	mainMod .. " + SHIFT + U",
	hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/hyprlock.sh --select"),
	{ desc = "select hyprlock layout" }
)

-------------------------------------
---- WORKSPACES: NAVIGATION ---------
-------------------------------------

-- This is the loop the whole Lua migration is worth it for — nine nearly
-- identical bind pairs collapse to one loop.
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), { desc = "navigate to workspace " .. i })
	hl.bind(
		mainMod .. " + SHIFT + " .. key,
		hl.dsp.window.move({ workspace = i, follow = true }),
		{ desc = "move to workspace " .. i }
	)
	hl.bind(
		mainMod .. " + ALT + " .. key,
		hl.dsp.window.move({ workspace = i, follow = false }),
		{ desc = "move to workspace " .. i .. " (silent)" }
	)
end

hl.bind(mainMod .. " + N", hl.dsp.focus({ workspace = "r+1" }), { desc = "change active workspace forwards" })
hl.bind(mainMod .. " + P", hl.dsp.focus({ workspace = "r-1" }), { desc = "change active workspace backwards" })
hl.bind(
	mainMod .. " + CTRL + P",
	hl.dsp.focus({ workspace = "empty" }),
	{ desc = "navigate to the nearest empty workspace" }
)

hl.bind(
	mainMod .. " + CTRL + ALT + right",
	hl.dsp.window.move({ workspace = "r+1", follow = true }),
	{ desc = "move window to next relative workspace" }
)
hl.bind(
	mainMod .. " + CTRL + ALT + left",
	hl.dsp.window.move({ workspace = "r-1", follow = true }),
	{ desc = "move window to previous relative workspace" }
)

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { desc = "next workspace" })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { desc = "previous workspace" })

-------------------------------------
---- WORKSPACES: SPECIAL ------------
-------------------------------------

hl.bind(
	mainMod .. " + SHIFT + S",
	hl.dsp.window.move({ workspace = "special", follow = true }),
	{ desc = "move to scratchpad" }
)
hl.bind(
	mainMod .. " + ALT + S",
	hl.dsp.window.move({ workspace = "special", follow = false }),
	{ desc = "move to scratchpad (silent)" }
)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special(), { desc = "toggle scratchpad" })
