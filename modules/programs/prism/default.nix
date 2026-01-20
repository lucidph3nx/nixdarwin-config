{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    homeManagerModules.prism = {
      enable = lib.mkEnableOption "enables prism development environment" // {
        default = true;
      };

      agent.envVars = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          KUBECONFIG = "$HOME/code/azure-kubernetes/main/kubeconfig/kubeconfig-agents-readonly";
        };
        description = "Environment variables to pass to the AI agent (opencode)";
      };

      sessioniser.windows = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            index = lib.mkOption {
              type = lib.types.int;
              description = "Window index";
            };
            name = lib.mkOption {
              type = lib.types.str;
              description = "Window name";
            };
            command = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = "Command to run in window (null for default shell, 'agent' for opencode)";
            };
          };
        });
        default = [
          { index = 0; name = "edit"; command = null; }
          { index = 1; name = "agent"; command = "agent"; }
          { index = 2; name = "term"; command = null; }
        ];
        description = "Default window layout for project sessions";
      };

      # Submodule enables
      neovim.enable = lib.mkEnableOption "enables neovim" // {
        default = true;
      };
      opencode.enable = lib.mkEnableOption "enables opencode" // {
        default = true;
      };
      tmux.enable = lib.mkEnableOption "enables tmux" // {
        default = true;
      };
      sessioniser.enable = lib.mkEnableOption "enables sessioniser" // {
        default = true;
      };
      contextSwitcher.enable = lib.mkEnableOption "enables context switcher" // {
        default = true;
      };
      scripts.enable = lib.mkEnableOption "enables helper scripts" // {
        default = true;
      };

      # Internal computed values
      _internal.agentEnvPrefix = lib.mkOption {
        type = lib.types.str;
        internal = true;
        readOnly = true;
        default = lib.concatStringsSep " " (
          lib.mapAttrsToList (name: value: "${name}=${value}") config.homeManagerModules.prism.agent.envVars
        );
        description = "Computed environment variable prefix for agent commands";
      };
    };
  };

  imports = [
    ./neovim
    ./opencode.nix
    ./tmux.nix
    ./sessioniser.nix
    ./context-switcher.nix
    ./scripts.nix
  ];

  config = lib.mkIf config.homeManagerModules.prism.enable {
    # Prism is enabled - submodules handle their own configuration
  };
}
