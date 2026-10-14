return {
  "nvim-treesitter/nvim-treesitter-context",
  opts = {
    -- Cap sticky context height (default: unlimited).
    max_lines = 3,
    -- Skip context computation for large Java buffers (threshold: vim.g.java_bigfile_lines).
    on_attach = function(buf)
      if vim.bo[buf].filetype == "java" and vim.api.nvim_buf_line_count(buf) > (vim.g.java_bigfile_lines or 3000) then
        return false
      end
      return true
    end,
  },
}
