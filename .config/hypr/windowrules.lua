-- █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
-- ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█
--
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--
-- NOTE: the original file wrapped everything in a `hyprlang if
-- WINDOWRULES_HYPRLAND_V_0_53` guard — that was a HyDE compatibility shim
-- for a hyprlang syntax version bump. Lua config doesn't need that kind of
-- versioned preprocessor block; if you ever need to gate something on
-- version, use `hl.version()` directly instead. Dropped here.

------------------------------------------------
---- IDLE INHIBIT RULES -------------------------
------------------------------------------------

local idleInhibitRules = {
	{ class = "^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$" },
	{ class = "^(.*[Ss]potify.*)$" },
	{
		class = "^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$",
	},
}
for _, r in ipairs(idleInhibitRules) do
	hl.window_rule({ match = { class = r.class }, idle_inhibit = "fullscreen" })
end

------------------------------------------------
---- PICTURE-IN-PICTURE -------------------------
------------------------------------------------

-- NOTE ON TAGS: the original applies two `tag = +x` lines to the same
-- rule (tags stack in classic hyprlang). The Lua `tag` field is documented
-- as a single string, so I'm relying on named-rule merge behavior
-- (re-calling hl.window_rule with the same `name` updates/adds to that
-- rule rather than replacing it) to get both tags applied. Worth
-- confirming both tags actually land — if not, drop the second call and
-- put both tags in one string, e.g. tag = "picture-in-picture hyde_picture_in_picture".
hl.window_rule({
	name = "hyde_picture_in_picture",
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	tag = "picture-in-picture",
	float = true,
	keep_aspect_ratio = true,
	move = "(monitor_w*0.73) (monitor_h*0.72)",
	size = "(monitor_w*0.25) (monitor_h*0.25)",
	pin = true,
})
hl.window_rule({ name = "hyde_picture_in_picture", tag = "hyde_picture_in_picture" })

------------------------------------------------
---- OPACITY (active inactive fullscreen) -------
------------------------------------------------
-- Classic hyprlang's "$&" meant "repeat the previous value" when chaining
-- active/inactive/fullscreen opacity. That shorthand doesn't parse in the
-- Lua opacity field (confirmed — Hyprland threw "bad input" on it), so
-- each slot is spelled out explicitly here instead, e.g. "0.90 0.90 1".

local opacityRulesTriple = {
	{ class = "^(firefox)$", opacity = "0.90 0.90 1" },
	{ class = "^(zen)$", opacity = "0.90 0.90 1" },
	{ class = "^(brave-browser)$", opacity = "0.90 0.90 1" },
	{ class = "^(code-oss)$", opacity = "0.80 0.80 1" },
	{ class = "^([Cc]ode)$", opacity = "0.80 0.80 1" },
	{ class = "^(code-url-handler)$", opacity = "0.80 0.80 1" },
	{ class = "^(code-insiders-url-handler)$", opacity = "0.80 0.80 1" },
	{ class = "^(kitty)$", opacity = "0.80 0.80 1" },
	{ class = "^(org.kde.dolphin)$", opacity = "0.80 0.80 1" },
	{ class = "^(org.kde.ark)$", opacity = "0.80 0.80 1" },
	{ class = "^(nwg-look)$", opacity = "0.80 0.80 1" },
	{ class = "^(qt5ct)$", opacity = "0.80 0.80 1" },
	{ class = "^(qt6ct)$", opacity = "0.80 0.80 1" },
	{ class = "^(kvantummanager)$", opacity = "0.80 0.80 1" },
	{ class = "^(org.pulseaudio.pavucontrol)$", opacity = "0.80 0.70 1" },
	{ class = "^(blueman-manager)$", opacity = "0.80 0.70 1" },
	{ class = "^(nm-applet)$", opacity = "0.80 0.70 1" },
	{ class = "^(nm-connection-editor)$", opacity = "0.80 0.70 1" },
	{ class = "^(hyprpolkitagent)$", opacity = "0.80 0.70 1" },
	{ class = "^(org.freedesktop.impl.portal.desktop.gtk)$", opacity = "0.80 0.70 1" },
	{ class = "^(org.freedesktop.impl.portal.desktop.hyprland)$", opacity = "0.80 0.70 1" },
	{ class = "^([Ss]team)$", opacity = "0.70 0.70 1" },
	{ class = "^(steamwebhelper)$", opacity = "0.70 0.70 1" },
	{ class = "^([Ss]potify)$", opacity = "0.70 0.70 1" },
	{ initial_title = "^(Spotify Free)$", opacity = "0.70 0.70 1" },
	{ initial_title = "^(Spotify Premium)$", opacity = "0.70 0.70 1" },
	{ class = "^(blender)$", opacity = "1.00 1.00 1" },
}
for _, r in ipairs(opacityRulesTriple) do
	local match = {}
	if r.class then
		match.class = r.class
	end
	if r.initial_title then
		match.initial_title = r.initial_title
	end
	hl.window_rule({ match = match, opacity = r.opacity })
end

------------------------------------------------
---- OPACITY (active inactive) ------------------
------------------------------------------------

local opacityRulesDouble = {
	{ class = "^(com.github.rafostar.Clapper)$", opacity = "0.90 0.90" }, -- Clapper-Gtk
	{ class = "^(com.github.tchx84.Flatseal)$", opacity = "0.80 0.80" }, -- Flatseal-Gtk
	{ class = "^(hu.kramo.Cartridges)$", opacity = "0.80 0.80" }, -- Cartridges-Gtk
	{ class = "^(com.obsproject.Studio)$", opacity = "0.80 0.80" }, -- Obs-Qt
	{ class = "^(gnome-boxes)$", opacity = "0.80 0.80" }, -- Boxes-Gtk
	{ class = "^(vesktop)$", opacity = "0.80 0.80" }, -- Vesktop
	{ class = "^(discord)$", opacity = "0.80 0.80" }, -- Discord-Electron
	{ class = "^(WebCord)$", opacity = "0.80 0.80" }, -- WebCord-Electron
	{ class = "^(ArmCord)$", opacity = "0.80 0.80" }, -- ArmCord-Electron
	{ class = "^(app.drey.Warp)$", opacity = "0.80 0.80" }, -- Warp-Gtk
	{ class = "^(net.davidotek.pupgui2)$", opacity = "0.80 0.80" }, -- ProtonUp-Qt
	{ class = "^(yad)$", opacity = "0.80 0.80" }, -- Protontricks-Gtk
	{ class = "^(Signal)$", opacity = "0.80 0.80" }, -- Signal-Gtk
	{ class = "^(io.github.alainm23.planify)$", opacity = "0.80 0.80" }, -- planify-Gtk
	{ class = "^(io.gitlab.theevilskeleton.Upscaler)$", opacity = "0.80 0.80" }, -- Upscaler-Gtk
	{ class = "^(com.github.unrud.VideoDownloader)$", opacity = "0.80 0.80" }, -- VideoDownloader-Gtk
	{ class = "^(io.gitlab.adhami3310.Impression)$", opacity = "0.80 0.80" }, -- Impression-Gtk
	{ class = "^(io.missioncenter.MissionCenter)$", opacity = "0.80 0.80" }, -- MissionCenter-Gtk
	{ class = "^(io.github.flattool.Warehouse)$", opacity = "0.80 0.80" }, -- Warehouse-Gtk
}
for _, r in ipairs(opacityRulesDouble) do
	hl.window_rule({ match = { class = r.class }, opacity = r.opacity })
end

------------------------------------------------
---- FLOAT (by class) ---------------------------
------------------------------------------------

local floatRulesByClass = {
	{ class = "^(Signal)$" }, -- Signal-Gtk
	{ class = "^(com.github.rafostar.Clapper)$" }, -- Clapper-Gtk
	{ class = "^(app.drey.Warp)$" }, -- Warp-Gtk
	{ class = "^(net.davidotek.pupgui2)$" }, -- ProtonUp-Qt
	{ class = "^(yad)$" }, -- Protontricks-Gtk
	{ class = "^(eog)$" }, -- Imageviewer-Gtk
	{ class = "^(io.github.alainm23.planify)$" }, -- planify-Gtk
	{ class = "^(io.gitlab.theevilskeleton.Upscaler)$" }, -- Upscaler-Gtk
	{ class = "^(com.github.unrud.VideoDownloader)$" }, -- VideoDownloader-Gkk
	{ class = "^(io.gitlab.adhami3310.Impression)$" }, -- Impression-Gtk
	{ class = "^(io.missioncenter.MissionCenter)$" }, -- MissionCenter-Gtk
}
for _, r in ipairs(floatRulesByClass) do
	hl.window_rule({ match = { class = r.class }, float = true })
end

------------------------------------------------
---- FLOAT (by title) ---------------------------
------------------------------------------------

local floatRulesByTitle = {
	{ title = "^(Friends List)$" }, -- Steam Friends List
	{ title = "^(Steam Settings)$" }, -- Steam Settings
}
for _, r in ipairs(floatRulesByTitle) do
	hl.window_rule({ match = { title = r.title }, float = true })
end

------------------------------------------------
---- ONE-OFF WINDOW RULES -----------------------
------------------------------------------------

-- Blender render window: float + size, matched on both initial title and class
hl.window_rule({
	name = "blender-image-editor",
	match = { initial_title = "^(Image Editor)$", class = "^(blender)$" },
	float = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

-- Ghidra project manager
hl.window_rule({
	match = { initial_title = "^(Ghidra: NO ACTIVE PROJECT)" },
	float = true,
})

-- Workaround for JetBrains IDE dropdowns/popups causing flicker
hl.window_rule({
	match = { class = "^(.*jetbrains.*)$", title = "^(win[0-9]+)$" },
	no_initial_focus = true,
})

------------------------------------------------
---- LAYER RULES ---------------------------------
------------------------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/#layer-rules
-- Each namespace originally got two separate lines (blur + ignore_alpha);
-- combined into one call per namespace since these are anonymous rules
-- that don't merge across calls the way named window rules do.

hl.layer_rule({ match = { namespace = "rofi" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "swaync-control-center" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
