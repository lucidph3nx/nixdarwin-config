{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
  users.users.ben = {
    home = "/Users/ben";
  };

  programs.zsh = {
    enable = true;
    shellInit = ''
      export ZDOTDIR=$HOME/.local/share/zsh
    '';
  };
  environment = {
    shells = [pkgs.bash pkgs.zsh];
    systemPackages = with pkgs; [
      age
      arping
      azure-cli
      cloudflared
      direnv
      eza
      fzf
      fzy
      gh
      gnupg
      gnutar
      htop
      imagemagick
      jq
      openssh
      p7zip
      podman
      ripgrep
      rustup
      sops
      ssm-session-manager-plugin
      tree
      tridactyl-native
      utm
      yq-go
      zsh
    ];
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  fonts.packages = [
    (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];
  security.sudo.extraConfig = ''
    ben ALL=(ALL:ALL) NOPASSWD: ALL
  '';
  services = {
    nix-daemon.enable = true;
    karabiner-elements.enable = false;
  };
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
    };
    dock = {
      autohide = true;
      # basically, permanantly hide dock
      autohide-delay = 1000.0;
      orientation = "left";
    };
    menuExtraClock = {
      IsAnalog = false;
      Show24Hour = true;
      ShowAMPM = false;
      ShowSeconds = true;
    };
    spaces = {
      spans-displays = false;
    };
    universalaccess = {
      reduceMotion = true;
      reduceTransparency = true;
    };
    NSGlobalDomain = {
      _HIHideMenuBar = true;
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
      AppleInterfaceStyle = "Dark";
      AppleICUForce24HourTime = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
      NSWindowShouldDragOnGesture = true;
      NSAutomaticWindowAnimationsEnabled = false;
    };
  };
  homebrew = {
    enable = true;
    brews = [
      # "int128/kubelogin/kubelogin"
      "node"
      "borders" # JankyBorders
      "ripgrep" # for plenary in neovim, it can't find the nix binary
      "python"
    ];
    taps = [
      "FelixKratz/formulae" # JankyBorders
    ];
    casks = [
      "1password"
      "1password-cli"
      "bitwarden"
      "firefox"
      "karabiner-elements"
      "nikitabobko/tap/aerospace"
      "qutebrowser"
      "raycast"
      "scroll-reverser"
    ];
  };

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit pkgs-unstable;
    };
    users = {
      ben.imports = [
        ./home.nix
        ../../modules
      ];
    };
  };
  system.stateVersion = 5;
}
