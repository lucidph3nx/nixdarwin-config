{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./choose.nix
    ./cli
    ./firefox
    ./guiApps
    ./neovim
    ./qutebrowser
    ./scripts
    ./sops
    ./syncthing.nix
    ./opencode
  ];
  config = {
    homeManagerModules = {
      # note: firefox is config only
      firefox.enable = lib.mkDefault true;
      guiApps.enable = lib.mkDefault true;
      neovim.enable = lib.mkDefault true;
      sops.enable = lib.mkDefault false;
      syncthing.enable = lib.mkDefault true;
      choose.enable = lib.mkDefault true;
      opencode.enable = lib.mkDefault true;
    };
  };
}
