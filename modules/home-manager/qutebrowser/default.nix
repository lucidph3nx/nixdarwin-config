{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./colours.nix
    ./greasemonkey.nix
    ./keybindings.nix
    ./secrets.nix
  ];
  options = {
    homeManagerModules.qutebrowser.enable =
      lib.mkEnableOption "enables qutebrowser"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.homeManagerModules.qutebrowser.enable {
    programs.qutebrowser = {
      enable = true;
      settings = {
        url = {
          start_pages = [
            "qute://start"
          ];
          default_page = "qute://start";
          open_base_url = true; # open base url when a search engine is used without a query
        };
        downloads = {
          location = {
            directory = "~/downloads";
            prompt = false;
          };
        };
        content = {
          # disable autoplay globally
          autoplay = false;
          geolocation = false;
          # turn off notifications
          notifications = {
            enabled = false;
          };
          javascript = {
            clipboard = "access";
          };
          tls = {
            certificate_errors = "ask-block-thirdparty";
          };
          # don't register handlers for things like mail and calendar
          register_protocol_handler = false;
        };
        confirm_quit = [
          "downloads"
        ];
        completion.open_categories = [
          "searchengines"
          "quickmarks"
          "bookmarks"
          "history"
        ];
        scrolling = {
          bar = "when-searching";
        };
        spellcheck = {
          languages = [
            "en-AU"
          ];
        };
        editor.command = [
          "${pkgs.kitty}/bin/kitty"
          "--class"
          "qute-editor"
          "-e"
          "nvim"
          "{}"
        ];
        fonts = {
          default_family = "JetBrainsMono Nerd Font";
          default_size = "10pt";
        };
        # false beacuse it causes a weird colour shift
        # https://github.com/qutebrowser/qutebrowser/issues/5528
        window.hide_decoration = false;
        tabs = {
          position = "top";
          # only show if there are multiple tabs
          show = "multiple";
          favicons = {
            scale = 1;
          };
          # close window if last tab is closed
          last_close = "close";
        };
        hints.radius = 0; # no rounded corners on hints
        fileselect = {
          handler = "external";
          single_file.command = [
            "${pkgs.kitty}/bin/kitty"
            "--class"
            "qute-filepicker"
            "-e"
            "${pkgs.lf}/bin/lf"
            "-selection-path"
            "{}"
          ];
          multiple_files.command = [
            "${pkgs.kitty}/bin/kitty"
            "--class"
            "qute-filepicker"
            "-e"
            "${pkgs.lf}/bin/lf"
            "-selection-path"
            "{}"
          ];
        };
      };
      extraConfig =
        /*
        python
        */
        ''
          # enable geolocation on some sites
          config.set("content.geolocation", True, "https://www.bunnings.co.nz")
          config.set("content.geolocation", True, "https://www.metlink.org.nz")
          config.set("content.geolocation", True, "https://www.newworld.co.nz")
          config.set("content.geolocation", True, "https://www.pbtech.co.nz")
          # tab padding
          c.tabs.padding = {
              "bottom": 5,
              "left": 5,
              "top": 5,
              "right": 5,
          }
        '';
      quickmarks = {
        "fm" = "messenger.com";
        "gc" = "calendar.google.com";
        "gh" = "github.com";
        "gm" = "maps.google.com";
        "gp" = "photos.google.com";
        "ww" = "https://www.metservice.com/towns-cities/locations/wellington";
        "yt" = "youtube.com";
      };
      searchEngines = {
        "DEFAULT" = "https://search.tinfoilforest.nz/search?q={}";
        "gg" = "https://google.com/search?hl=en&q={}";
        "gh" = "https://github.com/search?q={}";
        "ghnx" = "https://github.com/search?q={}+language%3ANix&type=code&l=Nix";
        "hm" = "https://home-manager-options.extranix.com/?query={}";
        "nixopt" = "https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={}";
        "nixpkgs" = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={}";
        "nw" = "https://www.newworld.co.nz/shop/search?q={}";
        "protondb" = "https://www.protondb.com/search?q={}";
        "reo" = "https://maoridictionary.co.nz/search?idiom=&phrase=&proverb=&loan=&histLoanWords=&keywords={}";
        "wk" = "https://en.wikipedia.org/w/index.php?search={}&title=Special%3ASearch&ns0=1";
        "yt" = "https://www.youtube.com/results?search_query={}";
      };
    };
    home.file."Library/Application Support/qutebrowser/userscripts/bitwarden" = {
      source = ./userscripts/bitwarden;
    };
    home.file."Library/Application Support/qutebrowser/userscripts/open-firefox" = {
      source = ./userscripts/open-firefox;
    };
    home.file."Library/Application Support/qutebrowser/userscripts/open-bitwarden" = {
      source = ./userscripts/open-bitwarden;
    };
    home.file."Library/Application Support/qutebrowser/userscripts/ytm-download" = {
      source = ./userscripts/ytm-download;
    };
  };
}
