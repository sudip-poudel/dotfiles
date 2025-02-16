-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
      renderer = {
        icons = {
          show = {
            folder = true, -- Show folder icons
            file = true, -- Show file icons
            folder_arrow = true, -- Show folder arrow icons
          },
          glyphs = {
            folder = {
              arrow_open = '', -- Open folder arrow icon
              arrow_closed = '', -- Closed folder arrow icon
            },
            default = '', -- Default file type icon (e.g., for text files)
          },
        },
      },
    },
  },
}
