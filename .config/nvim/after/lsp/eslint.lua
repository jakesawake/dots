return {
  -- html/css removed: ESLint doesn't lint those, and attaching caused
  -- "[lspconfig] Unable to find ESLint library" warnings on every open
  filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact", "svelte" },
  handlers = {
    -- silently ignore "no local eslint found" instead of showing a warning
    ["eslint/noLibrary"] = function()
      return {}
    end,
  },
}
