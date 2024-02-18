return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("tokyonight").load({
          transparent = true,
          styles = {
            sidebars = "transparent",
            floats = "transparent",
          },
          on_highlights = function(hi, c)
            hi["@variable"] = { fg = c.yellow, style = "italic" }
          end,
        })
      end,
    },
  },
}
