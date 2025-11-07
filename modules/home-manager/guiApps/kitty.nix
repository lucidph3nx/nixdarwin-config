{
  config,
  pkgs,
  lib,
  ...
}:
with config.theme; let 
  kittyconf = ''
    symbol_map U+1f636,U+200D,U+1F32B,U+FE0F Noto Color Emoji
    prefer_color_emoji yes
    hide_window_decorations titlebar-only
    window_margin_width 10
    window_padding_width 0
    confirm_os_window_close 0
    background_opacity 1
    enable_audio_bell no
    paste_actions no-op
    cursor_trail 1
    cursor_trail_decay 0.05 0.2

    foreground                      ${foreground}
    background                      ${bg0}
    selection_foreground            ${grey2}
    selection_background            ${bg_visual}

    cursor                          ${foreground}
    cursor_text_color               ${bg1}

    url_color                       ${blue}

    active_border_color             ${green}
    inactive_border_color           ${bg5}
    bell_border_color               ${orange}
    visual_bell_color               none

    wayland_titlebar_color          system
    macos_titlebar_color            system

    active_tab_background           ${bg0}
    active_tab_foreground           ${foreground}
    inactive_tab_background         ${bg2}
    inactive_tab_foreground         ${grey2}
    tab_bar_background              ${bg1}
    tab_bar_margin_color            none

    mark1_foreground                ${bg0}
    mark1_background                ${blue}
    mark2_foreground                ${bg0}
    mark2_background                ${foreground}
    mark3_foreground                ${bg0}
    mark3_background                ${purple}

    #: black
    color0                          ${bg1}
    color8                          ${bg2}

    #: red
    color1                          ${red}
    color9                          ${red}

    #: green
    color2                          ${green}
    color10                         ${green}

    #: yellow
    color3                          ${yellow}
    color11                         ${yellow}

    #: blue
    color4                          ${blue}
    color12                         ${blue}

    #: magenta
    color5                          ${purple}
    color13                         ${purple}

    #: cyan
    color6                          ${aqua}
    color14                         ${aqua}

    #: white
    color7                          ${grey1}
    color15                         ${grey2}
  '';
  in
{
  options = {
    homeManagerModules.kitty = {
      enable = lib.mkEnableOption "enables kitty";
      configOnly = lib.mkEnableOption "only place config file, do not install kitty";
    };
  };
  config = lib.mkIf config.homeManagerModules.kitty.enable {
    # on macos 15.1, kitty installed via home-manager does not work
    # it will be installed iva brew, but the config set here
    home.file.".config/kitty/kitty.conf" = lib.mkIf config.homeManagerModules.kitty.configOnly {
      text = ''
        font_family JetBrainsMono Nerd Font Mono Medium
        font_size 14.000000
        shell_integration no-rc
        ${kittyconf}
      '';
    };
    programs.kitty = lib.mkIf (config.homeManagerModules.kitty.configOnly != true) {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font Mono Medium";
        size = 14.0;
      };
      extraConfig = ''
        ${kittyconf}
      '';
    };
  };
}
