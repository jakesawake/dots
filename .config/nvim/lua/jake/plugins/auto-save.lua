return {
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle", -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    opts = {
      enabled = true,
      trigger_events = { -- See :h events
        immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
        defer_save = { "InsertLeave", "TextChanged" },
        -- fixed typo: was cancel_defered_save (single r)
        cancel_deferred_save = { "InsertEnter" },
      },
      -- only save real files; skips floating windows like harpoon, oil, etc.
      condition = function(buf)
        return vim.bo[buf].buftype == "" and vim.bo[buf].modifiable
      end,
      write_all_buffers = false,
      noautocmd = false,
      lockmarks = false,
      debounce_delay = 1000,
      debug = false,
    },
    -- execution_message was removed from the plugin; notifications are now
    -- handled manually via the AutoSaveWritePost user event
    config = function(_, opts)
      require("auto-save").setup(opts)

      local group = vim.api.nvim_create_augroup("autosave", {})
      vim.api.nvim_create_autocmd("User", {
        pattern = "AutoSaveWritePost",
        group = group,
        callback = function(ev)
          if ev.data.saved_buffer ~= nil then
            -- use :t (tail) to avoid long paths triggering the press-Enter prompt
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.data.saved_buffer), ":t")
            vim.notify("AutoSave: saved " .. filename .. " at " .. vim.fn.strftime("%H:%M:%S"), vim.log.levels.INFO)
          end
        end,
      })
    end,
  },
}
