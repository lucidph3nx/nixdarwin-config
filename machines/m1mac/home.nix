{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
  homeManagerModules = {
    asdf.enable = true;
    mpv.enable = false; # currently a broken package with swift
    sops = {
      enable = true;
      generalSecrets.enable = true;
      signingKeys.enable = true;
      workSSH.enable = true;
      kubeconfig.enable = true;
    };
    homeAutomation.enable = true;
    qutebrowser.enable = false;
  };
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ben";
  home.homeDirectory = "/Users/ben";

  # home.packages = with pkgs; [
  # ];
  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less";
    KUBECONFIG = "${config.sops.secrets.workkube.path}";
  };
  home.sessionPath = [
    "/opt/homebrew/bin"
  ];
  home.file = {
    ".config/karabiner/karabiner.json".source = ./files/karabiner.json;
    ".config/aerospace/aerospace.toml".source = ./files/aerospace.toml;
  };
  programs.ssh = {
    enable = true;
    includes = ["workconfig"];
  };
}
