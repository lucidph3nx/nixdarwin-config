{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.rust.enable =
      lib.mkEnableOption "enables rust toolchain";
  };
  config = lib.mkIf config.homeManagerModules.rust.enable {
    home.packages = with pkgs; [
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
    ];
  };
}
