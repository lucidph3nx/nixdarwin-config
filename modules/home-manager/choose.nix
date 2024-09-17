{
  config,
  pkgs,
  lib,
  ...
}:
let
  terminal = "${pkgs.kitty}/bin/kitty";
in {
  imports = [../cli/tmuxSessioniser.nix]; #needed for one of the choose scripts
  options = {
    homeManagerModules.choose.enable =
      lib.mkEnableOption "enables choose";
  };
  config = lib.mkIf config.theme.choose.enable {
    home.packages = with pkgs; [
      choose-ui
    ];
    homeManagerModules.tmuxSessioniser.enable = true;
    home.file.".local/scripts/application.nvim.sessionLauncher" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Get the selection from tmux project getter
        selection=$(~/.local/scripts/cli.tmux.projectGetter | choose )
        if [ -n "$selection" ]; then
          # Run the tmux sessioniser with the selected session
          xargs -I{} ${terminal} ~/.local/scripts/cli.tmux.projectSessioniser "{}" 2> /dev/null <<<"$selection"
        fi
      '';
    };
  };
}
