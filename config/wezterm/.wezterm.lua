local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = 'Gruvbox dark, soft (base16)'
config.font_size = 15
config.font = wezterm.font('Iosevka NF', { weight = 'Regular' })
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.prefer_to_spawn_tabs = true

config.default_cursor_style = 'SteadyUnderline'
config.cursor_thickness = 3
config.window_padding = {
  left = 3,
  right = 3,
  top = 3,
  bottom = 0
}
config.initial_cols = 120
config.initial_rows = 40

-- TAB BAR
config.tab_max_width = 64
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.colors = {
  tab_bar = {
    background = "#3c3836"
  }
}
config.tab_bar_style = {
  new_tab = wezterm.format {
    { Foreground = { AnsiColor = 'Silver' }},
    { Background = { Color = '#3c3836' }},
    { Text = " + " },
  },
  new_tab_hover = wezterm.format {
    { Attribute = { Intensity = "Bold" }},
    { Foreground = { AnsiColor = 'Green' }},
    { Text = " + "},
  },
}

-- Tab Titles
local function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local index = tab.tab_index + 1
  local title = tab_title(tab)
  local state = ' -'
  local fg = { AnsiColor = 'Grey' }
  local bg = { Color = '#3c3836' }

  for _, pane in ipairs(tab.panes) do
    if pane.is_zoomed then
      state = ' Z'
      break
    end
  end

  if tab.is_active then
    fg = { AnsiColor = 'Green' }
    bg = { Color = '#504945' }
  end

  local r = string.format(
    " %d %s%s ",
    index,
    title,
    state
  )

  return {
    { Background = bg },
    { Foreground = fg },
    { Text = r }
  }
end)

-- Key Bindings
config.leader = {
  key = 'Space',
  mods = 'CTRL'
}

config.keys = {
  -- Moving Between Tabs
  { key = "1", mods = "ALT", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "ALT", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "ALT", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "ALT", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "ALT", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "ALT", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "ALT", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "ALT", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "ALT", action = wezterm.action.ActivateTab(8) },

  -- Splits (Pane Creation)
  {
    key = "\\",
    mods = "LEADER",
    action = wezterm.action.SplitHorizontal({
      domain = "CurrentPaneDomain",
    }),
  },
  {
    key = "|",
    mods = "LEADER|SHIFT",
    action = wezterm.action.SplitVertical({
      domain = "CurrentPaneDomain",
    }),
  },

  -- Move Panes Around (PaneSelect mode)
  {
    key = "p",
    mods = "LEADER|SHIFT",
    action = wezterm.action.PaneSelect { mode = "SwapWithActive" }
  },

  -- New Tab
  {
    key = "c",
    mods = "LEADER",
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },

  -- Shift Tabs
  {
    key = '{',
    mods = "SHIFT|ALT",
    action = wezterm.action.MoveTabRelative(-1)
  },
  {
    key = '}',
    mods = "SHIFT|ALT",
    action = wezterm.action.MoveTabRelative(1)
  },

  -- Rename Tab
  {
    key = "r",
    mods = "LEADER",
    action = wezterm.action.PromptInputLine {
      description = "Rename Tab:",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- Close Panes
  {
    key = "x",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentPane({
      confirm = true,
    })
  },

  -- Move Between Panes
  {
    key = "h",
    mods = "ALT",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "j",
    mods = "ALT",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },
  {
    key = "k",
    mods = "ALT",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },
  {
    key = "l",
    mods = "ALT",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },

  -- Hide/"Zoom"
  {
    key = "z",
    mods = "LEADER",
    action = wezterm.action.TogglePaneZoomState,
  },

  -- Copy Mode
  {
    key = "[",
    mods = "LEADER",
    action = wezterm.action.ActivateCopyMode,
  },

  -- Open Link
  {
    key = "u",
    mods = "LEADER",
    action = wezterm.action.QuickSelectArgs {
      label = "open url under cursor",
      patterns = {
        "https?://\\S+",
      },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        if url then
          wezterm.open_with(url)
        end
      end),
    }
  },

  -- Disabled Shortcuts
  {
    key = "n",
    mods = "CTRL|SHIFT",
    action = wezterm.action.DisableDefaultAssignment,
  },
}

return config
