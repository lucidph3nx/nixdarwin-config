{pkgs, ...}: {
  home.packages = with pkgs; [
    helm-ls
    lua-language-server
    nil
    terraform-ls
    typescript-language-server
    yaml-language-server
  ];
  programs.neovim.plugins = [
    # LSP and completions for injected langs
    pkgs.vimPlugins.otter-nvim
    pkgs.vimPlugins.cmp-nvim-lsp
    pkgs.vimPlugins.vim-helm
    # LSP
    {
      plugin = pkgs.vimPlugins.nvim-lspconfig;
      type = "lua";
      config =
        /*
        lua
        */
        ''
            -- Use new vim.lsp.config API (nvim 0.11+)
            -- This replaces the deprecated require('lspconfig') pattern
            local default_capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Helper function to configure and enable LSP servers
            local function setup_lsp(server_name, user_config)
              user_config = user_config or {}
              
              -- Directly require the server config to avoid deprecated metatable __index
              -- This accesses lspconfig's server definitions without triggering the deprecation warning
              local ok, server_module = pcall(require, 'lspconfig.configs.' .. server_name)
              if not ok then
                vim.notify('LSP config not found for: ' .. server_name, vim.log.levels.WARN)
                return
              end
              
              local default_config = server_module.default_config
              local cmd = user_config.cmd or default_config.cmd
              
              -- Only configure if the command is executable
              if cmd and vim.fn.executable(cmd[1]) == 1 then
                -- Configure using new vim.lsp.config API
                vim.lsp.config(server_name, vim.tbl_deep_extend('force', {
                  cmd = cmd,
                  filetypes = default_config.filetypes,
                  root_markers = default_config.root_dir and {} or nil,
                  capabilities = default_capabilities,
                }, user_config))
                
                -- Enable the server
                vim.lsp.enable(server_name)
              end
            end

            -- Set up all LSP servers
            setup_lsp('clojure_lsp', {})
            setup_lsp('cssls', {})
            setup_lsp('dockerls', {})
            setup_lsp('eslint', {})
            setup_lsp('helm_ls', {})
            setup_lsp('html', {})
            setup_lsp('jsonls', {})
            setup_lsp('lua_ls', {})
            setup_lsp('nil_ls', {
              settings = { ['nil'] = {
                formatting = { command = { "alejandra" }}
              }}
            })
            setup_lsp('pylsp', {})
            setup_lsp('sqlls', {})
            setup_lsp('terraformls', {})
            setup_lsp('ts_ls', {})
            setup_lsp('yamlls', {
              settings = { ['yamlls'] = {
                keyOrdering = false,
              }}
            })

          -- LSP keymaps
          vim.keymap.set('n', '<leader>rn',
            vim.lsp.buf.rename, { desc = '[R]e[n]ame'})
          vim.keymap.set('n', '<leader>ca',
            vim.lsp.buf.code_action, { desc = '[C]ode [A]ction'})

          vim.keymap.set('n', 'gd',
            vim.lsp.buf.definition, { desc = '[G]oto [D]efinition'})
          vim.keymap.set('n', 'gD',
            vim.lsp.buf.declaration, { desc = '[G]oto [D]eclaration'})
          vim.keymap.set('n', 'gi',
            vim.lsp.buf.implementation, { desc = '[G]oto [I]mplementation'})
          vim.keymap.set('n', 'gr',
            vim.lsp.buf.references, { desc = '[G]oto [R]eferences'})
          vim.keymap.set('n', 'K',
            vim.lsp.buf.hover, { desc = '[K]ind (Hover Documentation)'})

          vim.keymap.set('n', '<leader>D',
            vim.lsp.buf.type_definition, { desc = 'Type [D]efinition'})
          vim.keymap.set('n', '<leader>ds',
            require('telescope.builtin').lsp_document_symbols, { desc = '[D]ocument [S]ymbols'})
          vim.keymap.set('n', '<leader>ws',
            require('telescope.builtin').lsp_workspace_symbols, { desc = '[W]orkspace [S]ymbols'})
          -- format
          -- vim.keymap.set('n', '<leader>f',
          --   vim.lsp.buf.formatting, { desc = '[F]ormat'})
        '';
    }
  ];
}
