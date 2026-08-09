-- file pinning and quick-jump plugin; replaces global marks for multi-file workflows
-- keybindings: ; = open menu, a = add/remove file, letter = jump, m = buffer bookmark prefix
-- save_on_toggle persists list changes when closing the menu without needing :w
return {
  "otavioschwanck/arrow.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("arrow").setup({
      show_icons = true,
      -- leader_key must be a single key; <leader>j style sequences break the internal toggle
      leader_key = ";",
      buffer_leader_key = "m",
      save_on_toggle = true,
      after_jump_callback = function()
        vim.cmd("normal! zz")
      end,
    })

    -- buffer bookmark jumps fire this event; hook it to always center
    vim.api.nvim_create_autocmd("User", {
      pattern = "ArrowGoToBookmark",
      callback = function()
        vim.cmd("normal! zz")
      end,
    })
  end,
}
