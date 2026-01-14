{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
# NOTE: MACOS ONLY, use nix/sops.nix for nixos
{
  imports = [
    ./generalSecrets.nix
    ./signingKeys.nix
    ./workSSH.nix
    ./kubeconfig.nix
    inputs.sops-nix.homeManagerModules.sops
  ];
  options = {
    homeManagerModules.sops.enable = lib.mkEnableOption "Enable sops home manager module";
  };
  config = lib.mkIf config.homeManagerModules.sops.enable {
    homeManagerModules = {
      sops.generalSecrets.enable = lib.mkDefault false;
      sops.signingKeys.enable = lib.mkDefault false;
      sops.workSSH.enable = lib.mkDefault false;
      sops.kubeconfig.enable = lib.mkDefault false;
    };
    # sops defaults
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        keyFile = "${config.home.homeDirectory}/.config/sops-nix/key.txt";
        sshKeyPaths = ["${config.home.homeDirectory}/.ssh/nix-ed25519"];
        generateKey = true;
      };
    };
    
    # Temporary workaround for https://github.com/Mic92/sops-nix/issues/890
    # The LaunchAgent on macOS has an empty PATH when no age plugins are configured,
    # causing sops-install-secrets to fail finding 'getconf' at /usr/bin/getconf.
    # This can be removed once https://github.com/Mic92/sops-nix/pull/891 is merged
    # and we update sops-nix.
    launchd.agents.sops-nix = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        EnvironmentVariables = {
          PATH = lib.mkForce "/usr/bin:/bin:/usr/sbin:/sbin";
        };
      };
    };
    
    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops-nix/key.txt";
    };
  };
}
