{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./cli
    ./firefox
    ./guiApps
    ./neovim
    ./scripts
    ./sops
    ./syncthing.nix
    ./choose.nix
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
    };
  };
}
