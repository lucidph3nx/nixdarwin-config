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
          # Workaround for Kitty focus grip issue with choose-gui (AeroSpace issue #754)
          # Launch choose with a helper to force activation after window appears
          
          # Start choose in background with PID capture
          (
            # Give choose a moment to spawn its window
            sleep 0.1
            # Force choose to front - try multiple methods
            osascript -e 'tell application "System Events" to set frontmost of first application process whose name is "choose" to true' 2>/dev/null
            # Fallback: try activating by finding the choose window
            osascript -e 'tell application "System Events" to perform action "AXRaise" of (first window of (first application process whose name is "choose"))' 2>/dev/null
          ) &
          focus_helper_pid=$!
          
          # Run choose normally (blocking, outputs to stdout)
          selection=$(~/.local/scripts/cli.tmux.projectGetter | ${pkgs-unstable.choose-gui}/bin/choose ${choose-options})
          
          # Clean up background helper
          kill $focus_helper_pid 2>/dev/null
          wait $focus_helper_pid 2>/dev/null
          
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
