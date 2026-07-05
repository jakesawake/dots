return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  -- only load when opening markdown files inside the vault
  event = {
    "BufReadPre " .. vim.fn.expand("~") .. "/Obsidian_Notes/Obsidian Notes/*.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/Obsidian_Notes/Obsidian Notes/*.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Obsidian_Notes/Obsidian Notes",
      },
    },
  },
}
