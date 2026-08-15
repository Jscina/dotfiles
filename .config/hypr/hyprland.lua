-- Hyprland loads this file when it is started without a config, and it prefers
-- it over hyprland.conf. HyDE loads it too, last, as the override layer below.
-- The block keeps the two apart: hyde.lua sets `hyde` on its first line, so it
-- runs only when this file is the entry point and HyDE has not been loaded.
-- Removing it leaves a session with a cursor and nothing else.
if not hyde then
	local share = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
	local entry = share .. "/hypr/hyde.lua"
	local handle = io.open(entry, "r")
	if not handle then
		error("HyDE is not installed at " .. entry .. ". Run install.sh -r, or point Hyprland at your own config.")
	end
	handle:close()
	dofile(entry)
end

-- Your Hyprland configuration. HyDE never overwrites this file.
--
-- It loads after HyDE's own binds, so settings here take precedence. Replacing
-- a bind needs more than that: see below. HyDE's defaults live in
-- ~/.local/share/hypr/lua/ and are overwritten on every update, so edits there
-- do not survive.
--
-- Adding a keybind:
--
--     hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(hyde.sh.gamelauncher()), {
--         description = "[Utilities] game launcher",
--     })
--
-- Replacing one of HyDE's: bind the same combination again and yours takes
-- over, but copy its flags across as well. A bind counts as the same one only
-- when its flags match, and `description` is not a flag — miss one and both
-- binds stay live on that combination. Copy the whole options table from
-- ~/.local/share/hypr/lua/key_binds.lua and change only what you need:
--
--     hl.bind("F9", hl.dsp.exec_cmd(hyde.sh.volumecontrol("-o", "m")), {
--         locked = true,
--         description = "[Hardware Controls|Audio] un/mute output",
--     })
--
-- Press SUPER + / to see what is actually loaded, your own binds included.
-- The full reference is KEYBINDINGS.md in the HyDE repository.
--
-- Other Lua files next to this one can be pulled in with require("name").
require("keybindings")
require("monitors")
require("userprefs")
require("windowrules")
require("nvidia")

hl.env("HYPRCURSOR_THEME", "McMojave-cursors")
hl.env("HYPRCURSOR_SIZE", "36")
hl.env("XCURSOR_THEME", "McMojave-cursors")
hl.env("XCURSOR_SIZE", "36")

hl.on("hyprland.start", function()
	-- `hyprctl setcursor THEME SIZE` has a known bug: it silently no-ops
	-- if SIZE is the same as whatever's already active, so the theme
	-- doesn't actually reapply. It can also fire before the IPC socket is
	-- fully up if called immediately on startup. hl.timer with a short
	-- delay dodges both — set to a throwaway size first, then the real one.
	hl.timer(function()
		hl.exec_cmd("hyprctl setcursor McMojave-cursors 1")
		hl.exec_cmd("hyprctl setcursor McMojave-cursors 36")
		hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'McMojave-cursors'")
		hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 36")
	end, { timeout = 300, type = "oneshot" })

	-- Icon theme + color scheme (GTK theme intentionally skipped)
	hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'BeautyLine'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")

	-- Fonts
	hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name 'SF Pro Text Regular 12'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface document-font-name 'SF Pro Text Regular 12'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface monospace-font-name 'SFMono 10'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface font-hinting 'full'")

	hl.exec_cmd("uwsm app -- kitty", { workspace = "1 silent" })
	hl.exec_cmd("uwsm app -- zen-browser", { workspace = "2 silent" })
	hl.exec_cmd("uwsm app -- steam", { workspace = "3 silent" })
	hl.exec_cmd("uwsm app -- discord", { workspace = "special silent" })
	hl.exec_cmd("uwsm app -- spotify", { workspace = "special silent" })
	-- hl.exec_cmd("uwsm app -- immersed", { workspace = "special silent" })
end)
