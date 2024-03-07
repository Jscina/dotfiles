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
          on_highlights = function(hi, _)
            hi["@variable"] = { fg = "#f7768e", style = "italic" }
          end,
        })
      end,
    },
  },
}
