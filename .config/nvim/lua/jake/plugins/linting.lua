return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      svelte = { "eslint_d" },
      python = { "pylint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        -- skip eslint_d when no eslint config exists in the project tree;
        -- without this check, eslint_d errors with "Could not find config file"
        -- and nvim-lint surfaces it as a parse error diagnostic on line 1
        local eslint_fts = { javascript = true, typescript = true, javascriptreact = true, typescriptreact = true, svelte = true }
        if eslint_fts[vim.bo.filetype] then
          local has_config = #vim.fs.find({
            ".eslintrc", ".eslintrc.js", ".eslintrc.cjs",
            ".eslintrc.yaml", ".eslintrc.yml", ".eslintrc.json",
            "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs",
          }, { path = vim.fn.expand("%:p:h"), upward = true }) > 0
          if not has_config then return end
        end
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
