{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    tree-sitter
    nixd
    pyright
    yaml-language-server
    vscode-langservers-extracted
    nixfmt
    lazygit
    (neovim.override {
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            nvim-lspconfig
            nvim-cmp
            nvim-treesitter.withAllGrammars
            telescope-nvim
            neo-tree-nvim
            lualine-nvim
            bufferline-nvim
            toggleterm-nvim
            gitsigns-nvim
            which-key-nvim
            nvim-web-devicons
            blink-cmp
            tokyonight-nvim
            comment-nvim
            nvim-autopairs
          ];
        };
        customRC = ''
          -- Лидер-клавиши (должны быть объявлены первыми!)
          vim.g.mapleader = " "
          vim.g.maplocalleader = "\\"

          -- Базовые настройки интерфейса
          local opt = vim.opt
          opt.number         = true
          opt.relativenumber = true
          opt.mouse          = "a"
          opt.cursorline     = true
          opt.termguicolors  = true

          -- Индексация и табы
          opt.tabstop       = 2
          opt.shiftwidth    = 2
          opt.softtabstop   = 2
          opt.expandtab     = true
          opt.smartindent   = true
          opt.autoindent    = true
          opt.copyindent    = true

          -- Отображение невидимых символов
          opt.list          = true
          opt.listchars     = { tab = "❯ ", trail = "·", nbsp = "␣" }

          -- Цветовая схема
          vim.cmd.colorscheme("tokyonight")

          -- Настройка плагинов
          require('lualine').setup()
          require('neo-tree').setup({})
          require('which-key').setup({})
          require('gitsigns').setup({})
          require('Comment').setup({})
          require('nvim-autopairs').setup({})

          require('blink.cmp').setup({
            keymap = { preset = 'default' },
            sources = {
              default = { 'lsp', 'path', 'snippets', 'buffer' }
            }
          })

          require('toggleterm').setup({
            open_mapping = [[<C-\>]],
            direction = 'horizontal',
            size = 15
          })

          -- Горячие клавиши (Keymaps)
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Find Files" })
          vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = "Live Grep" })
          vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { silent = true })

          -- Настройка LSP (Включение серверов)
          vim.lsp.enable({'nixd', 'pyright', 'yamlls', 'jsonls', 'html'})

          -- Автокоманды (Autocmds)
          local autocmd = vim.api.nvim_create_autocmd

          -- Автоформатирование при сохранении
          autocmd('BufWritePre', {
            pattern = '*',
            callback = function()
              vim.lsp.buf.format({ async = false })
            end
          })

          -- Автооткрытие Neo-tree при старте (если открыта папка или пусто)
          autocmd('VimEnter', {
            callback = function()
              local arg = vim.fn.argv(0) or ""
              if vim.fn.isdirectory(arg) == 1 or vim.fn.argc() == 0 then
                vim.cmd("Neotree show")
              end
            end
          })
        '';
      };
    })
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
