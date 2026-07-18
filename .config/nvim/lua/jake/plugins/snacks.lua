return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = true,
        float = false,
        max_width = 80,
        max_height = 40,
      },
    },
  },
  init = function()
    local initialized = {}  -- { [buf] = true } after FileType fires
    local pending     = {}  -- { [buf] = true } reattach already scheduled
    local resize_timer = nil
    local group = vim.api.nvim_create_augroup("snacks_image_ux", { clear = true })

    local function reattach(buf)
      Snacks.image.placement.clean(buf)
      Snacks.image.buf.attach(buf)
    end

    -- Deduplicates rapid reattach requests (e.g. BufLeave then BufEnter in the
    -- same tick) into a single deferred call, preventing rapid clean+attach cycles.
    local function schedule_reattach(buf)
      if pending[buf] then return end
      pending[buf] = true
      vim.schedule(function()
        pending[buf] = nil
        if vim.api.nvim_buf_is_valid(buf)
          and initialized[buf]
          and vim.bo[buf].filetype == "image"
        then
          reattach(buf)
        end
      end)
    end

    -- Clear when leaving an image buffer so it never overlaps other windows.
    vim.api.nvim_create_autocmd("BufLeave", {
      group = group,
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].filetype == "image" then
          Snacks.image.placement.clean(buf)
        end
      end,
    })

    -- Re-render when returning to an image buffer.
    vim.api.nvim_create_autocmd("BufEnter", {
      group = group,
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].filetype == "image" and initialized[buf] then
          schedule_reattach(buf)
        end
      end,
    })

    -- tmux pane/window switch: clear on focus loss.
    vim.api.nvim_create_autocmd("FocusLost", {
      group = group,
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "image" then
            Snacks.image.placement.clean(buf)
          end
        end
      end,
    })

    -- tmux pane/window switch: re-render once Neovim has fully regained focus.
    vim.api.nvim_create_autocmd("FocusGained", {
      group = group,
      callback = vim.schedule_wrap(function()
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].filetype == "image" and initialized[buf] then
          schedule_reattach(buf)
        end
      end),
    })

    -- Window layout change (file explorer open/close): clear immediately so the
    -- image never bleeds over adjacent windows, then re-render after layout settles.
    vim.api.nvim_create_autocmd("WinResized", {
      group = group,
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        if not (vim.bo[buf].filetype == "image" and initialized[buf]) then return end
        Snacks.image.placement.clean(buf)
        if resize_timer then
          resize_timer:stop()
          resize_timer:close()
          resize_timer = nil
        end
        resize_timer = vim.uv.new_timer()
        resize_timer:start(150, 0, vim.schedule_wrap(function()
          if resize_timer then
            resize_timer:close()
            resize_timer = nil
          end
          local cbuf = vim.api.nvim_get_current_buf()
          if vim.api.nvim_buf_is_valid(cbuf)
            and vim.bo[cbuf].filetype == "image"
            and initialized[cbuf]
          then
            reattach(cbuf)
          end
        end))
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "image",
      callback = function(ev)
        local buf = ev.buf

        -- Clear any other image buffers when a new one opens to prevent stacking.
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if b ~= buf and vim.bo[b].filetype == "image" then
            Snacks.image.placement.clean(b)
          end
        end

        vim.schedule(function()
          initialized[buf] = true
        end)
      end,
    })
  end,
}
