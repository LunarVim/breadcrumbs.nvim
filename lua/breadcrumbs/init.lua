local M = {}

local use_icons = true

M.winbar_filetype_exclude = {
  "NeogitCommitMessage",
  "netrw",
  "help",
  "startify",
  "dashboard",
  "lazy",
  "neo-tree",
  "neogitstatus",
  "NvimTree",
  "Trouble",
  "alpha",
  "lir",
  "Outline",
  "git",
  "spectre_panel",
  "toggleterm",
  "DressingSelect",
  "Jaq",
  "harpoon",
  "dap-repl",
  "dap-terminal",
  "dapui_console",
  "dapui_hover",
  "lab",
  "notify",
  "noice",
  "neotest-summary",
  "zellij",
  "",
}

M.get_filename = function()
  local filename = vim.fn.expand "%:t"
  local extension = vim.fn.expand "%:e"
  local f = require "breadcrumbs.utils"

  if not f.isempty(filename) then
    local file_icon, hl_group
    local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
    if use_icons and devicons_ok then
      file_icon, hl_group = devicons.get_icon(filename, extension, { default = true })

      if f.isempty(file_icon) then
        file_icon = ""
      end
    else
      file_icon = ""
      hl_group = "WinBar"
    end

    local buf_ft = vim.bo.filetype

    if buf_ft == "dapui_breakpoints" then
      file_icon = ""
    end

    if buf_ft == "dapui_stacks" then
      file_icon = ""
    end

    if buf_ft == "dapui_scopes" then
      file_icon = ""
    end

    if buf_ft == "dapui_watches" then
      file_icon = "󰂥"
    end

    if buf_ft == "dapui_console" then
      file_icon = ""
    end

    return " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*" .. " " .. "%#WinBar#" .. filename .. "%*"
  end
end

local get_navic = function()
  local status_navic_ok, navic = pcall(require, "nvim-navic")
  if not status_navic_ok then
    return ""
  end

  local status_ok, navic_location = pcall(navic.get_location, {})
  if not status_ok then
    return ""
  end

  if not navic.is_available() or navic_location == "error" then
    return ""
  end

  if not require("breadcrumbs.utils").isempty(navic_location) then
    return "%#NavicSeparator#" .. "" .. "%* " .. navic_location
  else
    return ""
  end
end

local excludes = function()
  return vim.tbl_contains(M.winbar_filetype_exclude or {}, vim.bo.filetype)
end

M.get_winbar = function()
  if excludes() then
    return
  end
  local f = require "breadcrumbs.utils"
  local value = M.get_filename()

  local navic_added = false
  if not f.isempty(value) then
    local navic_value = get_navic()
    value = value .. " " .. navic_value
    if not f.isempty(navic_value) then
      navic_added = true
    end
  end

  if not f.isempty(value) and f.get_buf_option "mod" then
    local mod = "%#LspCodeLens#" .. " " .. "%*"
    if navic_added then
      value = value .. " " .. mod
    else
      value = value .. mod
    end
  end

  -- local num_tabs = #vim.api.nvim_list_tabpages()
  --
  -- if num_tabs > 1 and not f.isempty(value) then
  --   local tabpage_number = tostring(vim.api.nvim_tabpage_get_number(0))
  --   value = value .. "%=" .. tabpage_number .. "/" .. tostring(num_tabs)
  -- end

  local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
  if not status_ok then
    return
  end
end

M.setup = function()
  vim.api.nvim_create_augroup("_winbar", {})
  vim.api.nvim_create_autocmd({
    "CursorHoldI",
    "CursorHold",
    -- "BufWinEnter",
    -- "BufEnter",
    -- "BufRead",
    "BufReadPost",
    "BufFilePost",
    "InsertEnter",
    "BufWritePost",
    "TabClosed",
    "TabEnter",
  }, {
    group = "_winbar",
    callback = function()
      local status_ok, _ = pcall(vim.api.nvim_buf_get_var, 0, "lsp_floating_window")
      if not status_ok then
        M.get_winbar()
      end
    end,
  })
end

return M

