{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.homeManagerModules.qutebrowser.enable {
    sops.secrets = {
      "bookmarks.sops" = {
        # using binary format to preserve multiline strings
        format = "binary";
        sopsFile = ./secrets/bookmarks.sops;
        path = "${config.home.homeDirectory}/.qutebrowser/bookmarks/urls";
      };
      bitwarden_password = {
        sopsFile = ./secrets/bitwarden.sops.yaml;
      };
    };
    home.sessionVariables = {
      BITWARDEN_PASSWORD = "$(cat ${config.sops.secrets.bitwarden_password.path})";
    };
  };
}
