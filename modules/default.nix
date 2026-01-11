{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./home-manager
    ./colourScheme
    ./programs
  ];
}
