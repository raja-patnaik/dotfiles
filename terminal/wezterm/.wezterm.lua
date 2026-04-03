-- WezTerm configuration
local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

-- This table will hold the configuration
local config = {}

-- Use the config_builder for clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- ============================================================================
-- General Settings
-- ============================================================================

-- Color scheme
config.color_scheme = 'Tokyo Night'
-- Alternative schemes: 'Catppuccin Mocha', 'Dracula', 'Nord', 'One Dark (terminal.sexy)'

-- Font configuration
config.font = wezterm.font_with_fallback {
  'JetBrains Mono',
  'FiraCode Nerd Font',
  'Cascadia Code',
  'Consolas',
}
config.font_size = 11.0
config.line_height = 1.2

-- Enable ligatures
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Window configuration
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.95
config.macos_window_background_blur = 10
config.initial_cols = 120
config.initial_rows = 30
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

-- Scrollback
config.scrollback_lines = 10000

-- ============================================================================
-- Key Bindings
-- ============================================================================

config.leader = { key = 'a', mods = 'ALT', timeout_milliseconds = 1000 }

config.keys = {
  -- Pane management (like tmux)
  {
    key = '|',
    mods = 'LEADER|SHIFT',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '-',
    mods = 'LEADER',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'h',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'x',
    mods = 'LEADER',
    action = act.CloseCurrentPane { confirm = true },
  },
  {
    key = 'z',
    mods = 'LEADER',
    action = act.TogglePaneZoomState,
  },

  -- Tab management
  {
    key = 'c',
    mods = 'LEADER',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'n',
    mods = 'LEADER',
    action = act.ActivateTabRelative(1),
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = act.ActivateTabRelative(-1),
  },
  {
    key = '&',
    mods = 'LEADER|SHIFT',
    action = act.CloseCurrentTab { confirm = true },
  },

  -- Tab navigation by number
  {
    key = '1',
    mods = 'LEADER',
    action = act.ActivateTab(0),
  },
  {
    key = '2',
    mods = 'LEADER',
    action = act.ActivateTab(1),
  },
  {
    key = '3',
    mods = 'LEADER',
    action = act.ActivateTab(2),
  },
  {
    key = '4',
    mods = 'LEADER',
    action = act.ActivateTab(3),
  },
  {
    key = '5',
    mods = 'LEADER',
    action = act.ActivateTab(4),
  },

  -- Copy mode (like tmux)
  {
    key = '[',
    mods = 'LEADER',
    action = act.ActivateCopyMode,
  },

  -- Paste
  {
    key = ']',
    mods = 'LEADER',
    action = act.PasteFrom 'Clipboard',
  },

  -- Show tab navigator
  {
    key = 'w',
    mods = 'LEADER',
    action = act.ShowTabNavigator,
  },

  -- Rename tab
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- Quick split and run commands
  {
    key = 'g',
    mods = 'LEADER',
    action = act.SplitPane {
      direction = 'Right',
      command = { args = { 'lazygit' } },
      size = { Percent = 50 },
    },
  },

  -- Font size
  {
    key = '=',
    mods = 'CTRL',
    action = act.IncreaseFontSize,
  },
  {
    key = '-',
    mods = 'CTRL',
    action = act.DecreaseFontSize,
  },
  {
    key = '0',
    mods = 'CTRL',
    action = act.ResetFontSize,
  },

  -- Search
  {
    key = 'f',
    mods = 'CTRL|SHIFT',
    action = act.Search { CaseSensitiveString = '' },
  },

  -- Show launcher menu
  {
    key = 'l',
    mods = 'LEADER|SHIFT',
    action = act.ShowLauncher,
  },

  -- Clear scrollback
  {
    key = 'k',
    mods = 'CTRL|SHIFT',
    action = act.ClearScrollback 'ScrollbackAndViewport',
  },
}

-- ============================================================================
-- Mouse Bindings
-- ============================================================================

config.mouse_bindings = {
  -- Right click to paste
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },

  -- Ctrl+Click to open URL
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- ============================================================================
-- Hyperlink Rules
-- ============================================================================

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Add custom hyperlink rule for file paths
table.insert(config.hyperlink_rules, {
  regex = '([\\w\\-./]+\\.\\w+:\\d+)',
  format = 'file://$1',
})

-- ============================================================================
-- Launch Menu
-- ============================================================================

config.launch_menu = {
  {
    label = 'PowerShell',
    args = { 'pwsh.exe', '-NoLogo' },
  },
  {
    label = 'Command Prompt',
    args = { 'cmd.exe' },
  },
  {
    label = 'Git Bash',
    args = { 'bash.exe' },
  },
}

-- Add WSL distros if on Windows
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  -- Enumerate WSL distros and add them to launch menu
  local success, wsl_list, stderr = wezterm.run_child_process { 'wsl.exe', '-l', '-q' }

  if success then
    for line in string.gmatch(wsl_list, '[^\r\n]+') do
      -- Remove BOM and whitespace
      local distro = line:gsub('^[%z\1-\127\194-\244][\128-\191]*', ''):gsub('%s+$', '')

      if distro ~= '' then
        table.insert(config.launch_menu, {
          label = 'WSL: ' .. distro,
          args = { 'wsl.exe', '-d', distro },
        })
      end
    end
  end
end

-- ============================================================================
-- Status Bar
-- ============================================================================

local function escape_lua(s)
  return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

wezterm.on('update-right-status', function(window, pane)
  local cells = {}

  -- workspace
  table.insert(cells, window:active_workspace())

  -- cwd (Url → path → tidy → ~)
  local cwd = ""
  do
    local uri = pane:get_current_working_dir()
    if uri then
      cwd = uri.file_path or tostring(uri)
    end
    cwd = tostring(cwd)

    -- If tostring(uri) returned a URL, strip scheme/host.
    cwd = cwd:gsub('^file://[^/]*', '')

    -- Normalize slashes & fix /C:/ on Windows
    cwd = cwd:gsub("\\", "/")
             :gsub("^/([A-Za-z]:/)", "%1")

    -- Home → ~
    local home = os.getenv("HOME") or os.getenv("USERPROFILE") or ""
    if home ~= "" then
      home = home:gsub("\\", "/")
      cwd = cwd:gsub("^" .. escape_lua(home), "~")
    end

    if cwd ~= "" then table.insert(cells, cwd) end
  end

  -- time
  table.insert(cells, wezterm.strftime("%H:%M"))

  -- format
  local formatted = {}
  for _, cell in ipairs(cells) do
    table.insert(formatted, " " .. tostring(cell) .. " ")
  end

  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#808080" } },
    { Text = table.concat(formatted, " | ") },
  }))
end)

-- ============================================================================
-- Platform-specific Configuration
-- ============================================================================

-- Windows-specific settings
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }

  -- Use Windows Terminal GPU backend for better performance
  config.front_end = 'WebGpu'
  config.webgpu_preferred_adapter = wezterm.gui.enumerate_gpus()[1]
end

-- macOS-specific settings
if wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then
  config.native_macos_fullscreen_mode = true
  config.macos_window_background_blur = 20
end

-- Linux/WSL-specific settings
if wezterm.target_triple:find('linux') then
  config.enable_wayland = true
end

-- ============================================================================
-- Performance Settings
-- ============================================================================

config.animation_fps = 60
config.max_fps = 60
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'

-- ============================================================================
-- Startup Behavior
-- ============================================================================

-- Start maximized/fullscreen
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()

end)

-- ============================================================================
-- Return Configuration
-- ============================================================================

return config