-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Large Java buffers: trim jdtls-driven per-keystroke work (threshold: vim.g.java_bigfile_lines).
-- Treesitter highlighting is intentionally left on.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("java_bigfile_lsp", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "jdtls" then
      return
    end
    if vim.api.nvim_buf_line_count(buf) <= (vim.g.java_bigfile_lines or 3000) then
      return
    end

    -- Semantic tokens: per-buffer off (0.12 API); fall back to dropping the capability if absent.
    local ok = vim.lsp.semantic_tokens
      and pcall(vim.lsp.semantic_tokens.enable, false, { bufnr = buf })
    if not ok then
      client.server_capabilities.semanticTokensProvider = nil
    end

    -- Reference highlighting: LazyVim uses snacks.words (vim-illuminate extra is not enabled).
    vim.b[buf].snacks_words = false

    -- Codelens: LazyVim's opts.codelens.enabled is false and not overridden, so nothing to disable.
  end,
})
