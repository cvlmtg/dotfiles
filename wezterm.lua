local wezterm = require("wezterm")
local config = wezterm.config_builder()
local action = wezterm.action

config.colors = {
  tab_bar = {
    background = '#3a3a3a',

    active_tab = {
      bg_color = '#000000',
      fg_color = '#909090',
      italic = false,
      strikethrough = false,

      -- "Half", "Normal" or "Bold"
      intensity = 'Bold',

      -- "None", "Single" or "Double"
      underline = 'None',
    },

    inactive_tab = {
      bg_color = '#3a3a3a',
      fg_color = '#808080',
    },

    inactive_tab_hover = {
      bg_color = '#2a2a2a',
      fg_color = '#808080',
    },

    new_tab = {
      bg_color = '#3a3a3a',
      fg_color = '#808080',
    },

    new_tab_hover = {
      bg_color = '#2a2a2a',
      fg_color = '#808080',
    },
  },
}

config.window_padding = {
  left = 4,
  right = 4,
  top = 4,
  bottom = 4,
}

config.font = wezterm.font("Fira Code")
config.term = "xterm-256color"
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.initial_cols = 100
config.initial_rows = 40

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  { key = 'a', mods = 'LEADER', action = action.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'a', mods = 'LEADER|CTRL', action = action.ActivateLastTab },
  { key = "s", mods = "LEADER", action = action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = "v", mods = "LEADER", action = action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'm', mods = 'LEADER', action = action.TogglePaneZoomState },
  { key = "LeftArrow", mods = "LEADER", action = action.ActivatePaneDirection("Left") },
  { key = "h", mods = "LEADER", action = action.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = action.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = action.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = action.ActivatePaneDirection("Right") },
  { key = "RightArrow", mods = "LEADER", action = action.ActivatePaneDirection("Right") },
  { key = "c", mods = "LEADER", action = action.SpawnTab("CurrentPaneDomain") },
  { key = "p", mods = "LEADER", action = action.ActivateTabRelative(-1) },
  { key = "n", mods = "LEADER", action = action.ActivateTabRelative(1) },
  { key = "n", mods = "LEADER", action = action.ActivateTabRelative(1) },
}

for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = "LEADER", action = action.ActivateTab(i - 1) })
end

config.launch_menu = {
  {
    label = "Git Bash",
    args = { "C:\\Program Files\\Git\\bin\\bash.exe", "--login", "-i" },
  },
  {
    label = "Powershell",
    args = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe" },
  },
}

config.default_prog = { "C:\\Program Files\\Git\\bin\\bash.exe", "--login", "-i" }

return config
