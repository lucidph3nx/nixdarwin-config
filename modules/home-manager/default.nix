{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./cli
    ./guiApps
    ./neovim
    ./scripts
    ./sops
    ./syncthing.nix
  ];
  config = {
    homeManagerModules = {
      guiApps.enable = lib.mkDefault true;
      neovim.enable = lib.mkDefault true;
      sops.enable = lib.mkDefault false;
      syncthing.enable = lib.mkDefault true;
    };
  };
}
