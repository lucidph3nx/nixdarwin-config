{pkgs, ...}: {
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.leap-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          -- Set up leap with manual mappings (create_default_mappings is deprecated)
          vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap-forward)')
          vim.keymap.set({'n', 'x', 'o'}, 'S',  '<Plug>(leap-backward)')
          vim.keymap.set({'n', 'x', 'o'}, 'gs', '<Plug>(leap-from-window)')
        '';
    }
    {
      plugin = pkgs.pkgs.vimPlugins.flit-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('flit').setup()
        '';
    }
    pkgs.vimPlugins.vim-repeat
  ];
}
