{pkgs, ...}: {
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.nvim-sops;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('nvim_sops').setup {
            enabled = true,
            debug = true,
          }
          vim.keymap.set('n', '<leader>ef',
            vim.cmd.SopsEncrypt, { desc = '[E]ncrypt [F]ile' })
          vim.keymap.set('n', '<leader>df',
            vim.cmd.SopsDecrypt, { desc = '[D]ecrypt [F]ile' })
        '';
    }
  ];
}
