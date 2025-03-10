{
  config,
  pkgs,
  lib,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
  imports = [
    ./homePage.nix
    ./tridactyl.nix
    ./tridactylStyle.nix
    ./userChrome.nix
    ./userContent.nix
  ];
  options = {
    homeManagerModules.firefox.enable =
      lib.mkEnableOption "enables firefox";
  };
  config = lib.mkIf config.homeManagerModules.firefox.enable {
# doesnt work with macos currently
    # programs.firefox = {
    #   enable = true;
    #   nativeMessagingHosts = [
    #     pkgs.tridactyl-native
    #   ];
    #   profiles = {
    #     main = {
    #       id = 0;
    #       name = "ben";
    #       isDefault = true;
    #       settings = {
    #         "signon.rememberSignons" = false; # Disable built-in password manager
    #         "browser.startup.homepage" = "${homeDir}/.config/tridactyl/home.html"; # custom homepage
    #         "browser.compactmode.show" = true;
    #         "browser.uidensity" = 1; # enable compact mode
    #         "browser.aboutConfig.showWarning" = false;
    #         "browser.tabs.firefox-view" = false;
    #         "browser.download.folderList" = 2; # 2 = custom location
    #         "browser.download.dir" = "${homeDir}/downloads";
    #         "browser.urlbar.update2.engineAliasRefresh" = true; # allow search engine updates
    #         "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    #         "ui.systemUsesDarkTheme" = if config.theme.type == "dark" then 1 else 0;
    #         "extensions.pocket.enabled" = false;
    #
    #         # dubious performance enhancements
    #         "network.buffer.cache.size" = 524288; # 512KB (default is 32 kB)
    #         "network.http.max-connections" = 1800; # default is 900
    #         "network.http.max-persistent-connections-per-server" = 12; # default is 6
    #         "network.http.max-urgent-start-excessive-connections-per-host" = 10; # default is 3
    #         "network.http.pacing.requests.burst" = 32; # default is 10
    #         "network.http.pacing.requests.min-parallelism" = 10; # default is 6
    #         "network.websocket.max-connections" = 400; # default is 200
    #         "network.ssl_tokens_cache_capacity" = 32768; # more TLS token caching (fast reconnects) (default is 2048)
    #         "image.mem.decode_bytes_at_a_time" = 65536; # 64KB (default is 16KB)
    #
    #         # Enable installing non signed extensions
    #         "extensions.langpacks.signatures.required" = false;
    #         "xpinstall.signatures.required" = false;
    #
    #         # Enable userChrome editor (Ctrl+Shift+Alt+I)
    #         "devtools.chrome.enabled" = true;
    #         "devtools.debugger.remote-enabled" = true;
    #       };
    #     };
    #   };
    # };
  };
}
