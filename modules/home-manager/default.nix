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
    # opencode now managed by prism
  ];
  config = {
    homeManagerModules = {
      # note: firefox is config only
      firefox.enable = lib.mkDefault true;
      guiApps.enable = lib.mkDefault true;
      # neovim now managed by prism
      sops.enable = lib.mkDefault false;
      syncthing.enable = lib.mkDefault true;
      choose.enable = lib.mkDefault true;
      # opencode now managed by prism
    };
  };
}
