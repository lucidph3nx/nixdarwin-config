{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:
with config.theme; let
  terminal = "${pkgs.kitty}/bin/kitty";
  choose-options = "-f 'JetbrainsMono Nerd Font' -c '${builtins.substring 1 6 config.theme.green}' -b '${builtins.substring 1 6 config.theme.bg2}' -s 20";
in {
  imports = [./cli/tmuxSessioniser.nix]; #needed for one of the choose scripts
  options = {
    homeManagerModules.choose.enable =
      lib.mkEnableOption "enables choose";
  };
  config = lib.mkIf config.homeManagerModules.choose.enable {
    home.packages = with pkgs; [
      # https://github.com/NixOS/nixpkgs/issues/355539
      pkgs-unstable.choose-gui
    ];
    homeManagerModules.tmuxSessioniser.enable = true;
    home.file.".local/scripts/application.nvim.sessionLauncher" = {
      executable = true;
      text =
        /*
        bash
        */
        ''
          #!/bin/zsh
          # Get the selection from tmux project getter
          selection=$(~/.local/scripts/cli.tmux.projectGetter | ${pkgs-unstable.choose-gui}/bin/choose ${choose-options})
          if [ -n "$selection" ]; then
            # Run the tmux sessioniser with the selected session
            xargs -I{} ${terminal} ~/.local/scripts/cli.tmux.projectSessioniser "{}" 2> /dev/null <<<"$selection"
          fi
        '';
    };
    home.file.".local/scripts/application.scripts.launcher" = {
      executable = true;
      text =
        /*
        bash
        */
        ''
          #!/bin/zsh
          scripts=$(ls ~/.local/scripts)
          scripts=$(echo "$scripts" | grep -v '^cli.')
          selection=$(echo "$scripts" | ${pkgs-unstable.choose-gui}/bin/choose ${choose-options})
          echo $selection
          if [ -n "$selection" ]; then
            /bin/bash -c ~/.local/scripts/$selection
          fi
        '';
    };
  };
}
