-- █░█ █▀ █▀▀ █▀█   █▀█ █▀█ █▀▀ █▀▀ █▀
-- █▄█ ▄█ ██▄ █▀▄   █▀▀ █▀▄ ██▄ █▀░ ▄█
--
-- Set your personal hyprland configuration here
-- See https://wiki.hypr.land/Configuring for more information

hl.config({
	decoration = {
		rounding = 10,
		shadow = { enabled = true, range = 20, render_power = 3, color = "rgba(1a1a1aee)" },
		blur = { enabled = true, size = 3, passes = 3 },
	},
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,
		["col.active_border"] = "rgba(cba6f7ee)",
		["col.inactive_border"] = "rgba(595959aa)",
	},
})
