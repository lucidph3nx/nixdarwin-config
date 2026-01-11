{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./abbreviations.nix
    ./autocmd.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];
  config = lib.mkIf config.homeManagerModules.prism.neovim.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
