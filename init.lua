function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, {...})
  print(unpack(objects))
end

local fn = vim.fn
fn.setenv("MACOSX_DEPLOYMENT_TARGET", "10.15")

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap =
    fn.system(
    {
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path
    }
  )
end

require("packer").startup {
  function(use, use_rocks)
    use {"wbthomason/packer.nvim"}
    use "joshdick/onedark.vim"
    use "neovim/nvim-lspconfig"
    use "hrsh7th/nvim-cmp"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/cmp-path"
    use "hrsh7th/cmp-cmdline"
    use "mhartington/formatter.nvim"
    use {
      "lewis6991/gitsigns.nvim",
      requires = {
        "nvim-lua/plenary.nvim"
      }
    }

    use_rocks {"lua-cjson", "luafilesystem", "luautf8", "penlight"}

    if packer_bootstrap then
      require("packer").sync()
    end
  end
}

vim.o.number = true
vim.o.cursorline = true
vim.o.splitright = true

vim.o.syntax = "on"
vim.o.termguicolors = true
vim.cmd "colorscheme onedark"

vim.o.completeopt = "menu,menuone,noselect"

local prettier = function()
  return {
    exe = "prettier",
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), "--single-quote"},
    stdin = true
  }
end

local luafmt = function()
  return {
    exe = "luafmt",
    args = {"--indent-count", 2, "--stdin"},
    stdin = true
  }
end

require("formatter").setup(
  {
    logging = false,
    filetype = {
      yaml = {
        prettier
      },
      javascript = {
        prettier
      },
      javascriptreact = {
        prettier
      },
      typescript = {
        prettier
      },
      typescriptreact = {
        prettier
      },
      lua = {
        luafmt
      }
    }
  }
)

require("gitsigns").setup()

local cmp = require "cmp"

cmp.setup(
  {
    mapping = {
      ["<CR>"] = cmp.mapping.confirm({select = true})
    },
    sources = cmp.config.sources({{name = "nvim_lsp"}}, {{name = "buffer"}})
  }
)

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
require("lspconfig")["tsserver"].setup {capabilities = capabilities}

require "theme".auto_load_color_scheme()
require "panda.pandaline".pandaline_augroup()

vim.g.mapleader = " "

vim.api.nvim_set_keymap("n", "<leader>e", "<cmd>lua require'panda.pandatree'.togger_tree()<CR>", {silent = true})
vim.api.nvim_set_keymap("n", "<leader>w", "<cmd>lua require'panda.pandawin'.choose_win()<CR>", {silent = true})
vim.api.nvim_set_keymap("n", "<leader>cf", ":Format<CR>", {silent = true})
