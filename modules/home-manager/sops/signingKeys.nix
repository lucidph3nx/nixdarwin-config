{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options = {
    homeManagerModules.sops.signingKeys.enable =
      lib.mkEnableOption "Set up signingKeys";
  };
  config = lib.mkIf config.homeManagerModules.sops.signingKeys.enable {
    sops.secrets = let
      sopsFile = ../../../secrets/signingKeys.yaml;
    in {
      "ssh/prismatic-koi-ed25519-signingkey" = {
        path = "${config.home.homeDirectory}/.ssh/prismatic-koi-ed25519-signingkey";
        sopsFile = sopsFile;
      };
      "ssh/prismatic-koi-ed25519-signingkey.pub" = {
        path = "${config.home.homeDirectory}/.ssh/prismatic-koi-ed25519-signingkey.pub";
        sopsFile = sopsFile;
      };
    };
  };
}
