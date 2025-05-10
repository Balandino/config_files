local wezterm = require 'wezterm'
local act = wezterm.action

-- This table will hold the configuration.
local config = wezterm.config_builder()

-- PowerShell on Windows only
if wezterm.target_triple:match('windows') then
   config.default_prog = { "pwsh.exe", '-NoLogo' }
end

-------------------------------------------------------------
-------------------------------------------------------------
--                     General Config                      --
-------------------------------------------------------------
-------------------------------------------------------------

-- opactity
config.text_background_opacity = 1.0
config.window_background_opacity = 0.7

-- Some configuration options
config.font = wezterm.font 'Hurmit Nerd Font Mono'
config.font = wezterm.font("Hurmit Nerd Font Mono", { weight = "Bold" })
config.font_size = 14 -- ATTENTION: Can cause borders in nvim
config.max_fps = 200
config.use_fancy_tab_bar = false
config.tab_max_width = 30
config.audible_bell = "Disabled"
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE" -- Affects title bar


-- Newer version needed, currently Nightly only
-- Could be helpful when borders appear upon zoomed font
-- config.window_content_alignment = {
--    horizontal = "Center",
--    vertical = "Center",
-- }
--

-------------------------------------------------------------
-------------------------------------------------------------
--                     Colour Scheme                       --
-------------------------------------------------------------
-------------------------------------------------------------

-- config.color_scheme = 'Gruvbox dark, medium (base16)'
-- config.color_scheme = 'Gruvbox Dark (Gogh)'
-- Customise Colour Scheme
local scheme = wezterm.color.get_builtin_schemes()['Gruvbox Dark (Gogh)']
scheme.cursor_border = "#FF0000"
scheme.cursor_bg = "#FF0000"
scheme.cursor_fg = "#000000"

config.color_schemes = {
   ['Gruvbox red'] = scheme
}

config.color_scheme = 'Gruvbox red'

config.window_padding = {
   left = 0,
   right = 0,
   top = 0,
   bottom = 0
}

-------------------------------------------------------------
-------------------------------------------------------------
--                       Tabs                              --
-------------------------------------------------------------
-------------------------------------------------------------

-- Sort tab colouring out
function Tab_title(tab_info)
   local title = tab_info.tab_title
   -- if the tab title is explicitly set, take that
   if title and #title > 0 then
      return title
   end
   -- Otherwise, use the title from the active pane
   -- in that tab
   return tab_info.active_pane.title
end

wezterm.on(
   'format-tab-title',
   function(tab)
      local title = Tab_title(tab)

      if tab.is_active then
         return {
            { Background = { Color = '#f0544c' } },
            { Text = '   ' .. title .. '   ' },
         }
      end
      return {
         { Background = { Color = '#f0544c' } },
         { Text = '   ' .. title .. '   ' },
      }
   end
)

config.colors = {
   tab_bar = {
      background = '#f0544c',
      new_tab = {
         bg_color = '#f0544c',
         fg_color = 'white',
      },
      active_tab = {
         bg_color = '#282828',
         fg_color = 'white',
      },
      inactive_tab = {
         bg_color = '#282828',
         fg_color = 'black'
      }
   },
}

-------------------------------------------------------------
-------------------------------------------------------------
--                  Keyboard Shortcuts                     --
-------------------------------------------------------------
-------------------------------------------------------------

-- Shortcuts for splits
-- Remember!  Ctrl + Shift + Arrow  to move between panes
config.keys = {
   -- paste from the clipboard
   { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
   -- paste from the primary selection
   -- { key = 'V', mods = 'CTRL', action = act.PasteFrom 'PrimarySelection' },

   {
      key = '+',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitPane { direction = 'Right' },
   },
   {
      key = '_',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
   }
}


-------------------------------------------------------------
-------------------------------------------------------------
--                  Return Config                          --
-------------------------------------------------------------
-------------------------------------------------------------
-- and finally, return the configuration to wezterm
return config
