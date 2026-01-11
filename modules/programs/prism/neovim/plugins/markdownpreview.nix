{pkgs, ...}: {
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.markdown-preview-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
        '';
    }
  ];
}
