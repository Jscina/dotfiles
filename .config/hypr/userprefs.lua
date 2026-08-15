-- █░█ █▀ █▀▀ █▀█   █▀█ █▀█ █▀▀ █▀▀ █▀
-- █▄█ ▄█ ██▄ █▀▄   █▀▀ █▀▄ ██▄ █▀░ ▄█
--
-- Set your personal hyprland configuration here
-- See https://wiki.hypr.land/Configuring for more information

-- // █ █▄░█ █▀█ █░█ ▀█▀
-- // █ █░▀█ █▀▀ █▄█ ░█░

-- Uncomment to enable // change to a preferred value
-- 🔗 See https://wiki.hypr.land/Configuring/Basics/Variables/ (input section)
-- All hyprland.conf { category { ... } } blocks become one hl.config()
-- call with matching nested tables.
hl.config({
	input = {
		-- kb_layout = "us",
		-- follow_mouse = 1,
		-- sensitivity = 0,
		-- force_no_accel = false,
		-- accel_profile = "flat",
		-- numlock_by_default = true,

		-- 🔗 See https://wiki.hypr.land/Configuring/Basics/Variables/ (touchpad section)
		touchpad = {
			natural_scroll = false,
		},
	},

	-- 🔗 See https://wiki.hypr.land/Configuring/Basics/Variables/ (gestures section)
	gestures = {
		-- workspace_swipe = true,
		-- workspace_swipe_fingers = 3,
	},

	-- for window swallow, similar to devour
	misc = {
		-- enable_swallow = true,
		-- swallow_regex = "(foot|kitty|allacritty|Alacritty|ghostty|Ghostty|org.wezfurlong.wezterm)",
	},

	-- Don't show update news on first launch
	ecosystem = {
		-- no_update_news = true,
	},
})
