{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./calibre.nix
    ./kitty.nix
    ./libreoffice.nix
    ./mpv.nix
    ./obsidian.nix
    ./zathura.nix
  ];

  options = {
    homeManagerModules.guiApps.enable =
      lib.mkEnableOption "Enable GUI applications";
  };
  config = lib.mkIf config.homeManagerModules.guiApps.enable {
    homeManagerModules = {
      calibre.enable = lib.mkDefault false;
      kitty.enable = lib.mkDefault true;
      libreoffice.enable = lib.mkDefault false;
      mpv.enable = lib.mkDefault true;
      obsidian.enable = lib.mkDefault false;
      zathura.enable = lib.mkDefault true;
    };
  };
}
