-- █▄░█ █░█ █ █▀▄ █ ▄▀█
-- █░▀█ ▀▄▀ █ █▄▀ █ █▀█
--
-- For multi GPU setups, please manually test the environment that works best for you.
-- Hyprland Nvidia Configuration
-- See https://wiki.hypr.land/Nvidia/

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia") -- Disable this if you have issues with screensharing

-- If you want to try hardware cursors, you can enable them by setting
-- cursor.no_hardware_cursors = false below, but it will also require
-- enabling cursor.use_cpu_buffer.
hl.config({
	cursor = {
		no_hardware_cursors = true, -- Set to true to avoid hitches
		-- use_cpu_buffer = true,
	},
})

-- https://wiki.hypr.land/Nvidia/#va-api-hardware-video-acceleration
-- Hardware video acceleration on Nvidia and Wayland is possible with the
-- nvidia-vaapi-driver. This may solve specific issues in Electron apps.
hl.env("NVD_BACKEND", "direct") -- Requires 'libva-nvidia-driver' package

-- https://wiki.hypr.land/Nvidia/#regarding-environment-variables
-- If you encounter crashes in Firefox, remove this line
hl.env("GBM_BACKEND", "nvidia-drm")

-- If you have a multi-GPU setup and you are facing lag in external monitor,
-- see https://wiki.hypr.land/Configuring/Multi-GPU/
