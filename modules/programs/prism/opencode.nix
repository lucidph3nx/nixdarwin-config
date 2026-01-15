{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.homeManagerModules.prism.opencode.enable (
    let
      envPrefix = config.homeManagerModules.prism._internal.agentEnvPrefix;
    in {
      home.packages = with pkgs; [
        # need npx on path for MCP servers
        nodejs_24
        # opencode is provided by the overlay using master
        opencode
        beads
      ];

      programs.zsh.shellAliases = {
        # set environment variables for opencode
        opencode = "${envPrefix} opencode";
      };

      # Manual configuration generation since programs.opencode is not in stable home-manager
      xdg.configFile."opencode/config.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        theme = config.theme.opencodename;
        agent = {
          soku = {
            description = "Beads workflow agent with automated context loading";
            mode = "primary";
            prompt = "You are the soku agent - a specialized agent for working with beads workflow management. The beads context will be automatically loaded when your session starts.";
            color = config.theme.orange;
            model = "github-copilot/claude-haiku-4.5";
          };
        };
        mcp = {
          playwright = {
            type = "local";
            command = [
              "${pkgs.playwright-mcp}/bin/mcp-server-playwright"
              "--executable-path"
              "/Applications/Chromium.app/Contents/MacOS/Chromium"
              "--headless"
            ];
            enabled = true;
          };
          atlasian = {
            type = "local";
            # problems with instantly filling the context window https://github.com/atlassian/atlassian-mcp-server/issues/17
            enabled = false;
            command = [
              "npx"
              "-y"
              "mcp-remote@0.1.13"
              "https://mcp.atlassian.com/v1/mcp"
            ];
          };
        };
        permission = {
          edit = "allow";
          webfetch = "allow";
          # Atlassian MCP permissions
          # fallback to ask
          "atlasian_*" = "ask";
          # Read operations (allow)
          "atlasian_atlassianUserInfo" = "allow";
          "atlasian_get*" = "allow";
          "atlasian_lookup*" = "allow";
          "atlasian_search*" = "allow";
          "atlasian_fetch" = "allow";
          # Write operations (ask)
          "atlasian_create*" = "ask";
          "atlasian_edit*" = "ask";
          "atlasian_update*" = "ask";
          "atlasian_add*" = "ask";
          "atlasian_transition*" = "ask";
          bash = {
            # default for any command not listed is ask
            "*" = "ask";
            # important tools for agents
            "bd*" = "allow";
            # we have made sure above that opencode runs with a readonly kubeconfig
            "flux *" = "allow";
            "helm *" = "allow";
            "kubectl *" = "allow";
            "helm dependency update" = "allow";
            "helm template *" = "allow";
            # file reading/viewing
            "cat *" = "allow";
            "head *" = "allow";
            "less *" = "allow";
            "more *" = "allow";
            "tail *" = "allow";
            # file/directory listing
            "file *" = "allow";
            "find *" = "allow";
            "ls *" = "allow";
            "tree *" = "allow";
            # text processing/searching
            "awk *" = "allow";
            "comm *" = "allow";
            "cut *" = "allow";
            "diff *" = "allow";
            "grep *" = "allow";
            "rg *" = "allow";
            "sed *" = "allow";
            "sort *" = "allow";
            "uniq *" = "allow";
            "wc *" = "allow";
            # system information (read-only)
            "date *" = "allow";
            "env *" = "allow";
            "hostname *" = "allow";
            "id *" = "allow";
            "printenv *" = "allow";
            "pwd *" = "allow";
            "uname *" = "allow";
            "whoami *" = "allow";
            # json/yaml processing
            "jq *" = "allow";
            "yq *" = "allow";
            "yq eval *" = "allow";
            # utilities
            "basename *" = "allow";
            "command *" = "allow";
            "dirname *" = "allow";
            "echo *" = "allow";
            "printf *" = "allow";
            "sleep *" = "allow";
            "type *" = "allow";
            "which *" = "allow";
            # git and gh commands
            "gh issue view *" = "allow";
            "gh pr view *" = "allow";
            "gh pr list *" = "allow";
            "gh repo view * " = "allow";
            "gh issue list *" = "allow";
            "gh release list *" = "allow";
            "gh release view *" = "allow";
            "git commit *" = "allow";
            "git diff *" = "allow";
            "git push *" = "ask";
            "git push" = "ask";
            "git status*" = "allow";
            "git add*" = "allow";
            "git log*" = "allow";
            # file operations that modify
            "mkdir *" = "allow";
            "rm *" = "allow";
            "mv *" = "allow";
            # nix commands
            "nh os build" = "allow";
            "nh os switch" = "ask";
            "nix build *" = "allow";
            "nix flake check *" = "allow";
            "nixfmt *" = "allow";
            # other dev tools
            "npm *" = "allow";
            "podman machine start" = "allow";
          };
        };
        plugin = [
          # a plugin to use Gemini auth for LLM access
          "opencode-gemini-auth@latest"
          # local plugin for soku beads workflow integration
          "./plugin/soku-hooks.js"
        ];
      };

      # Alias for legacy compatibility if needed
      xdg.configFile."opencode/opencode.json".source =
        config.xdg.configFile."opencode/config.json".source;

      # Copy the command directory
      xdg.configFile."opencode/command".source = ./opencode/command;

      # Copy the plugin directory for local plugins
      xdg.configFile."opencode/plugin".source = ./opencode/plugin;

      xdg.configFile."opencode/AGENTS.md".text =
        /*
        markdown
        */
        ''
          # Global Agent Instructions

          ## Skills
          When working in environments with domain-specific skills available (via the `skill` tool), err on the side of loading them. If a conversation touches a domain that has a skill, load it – even if you think you know the conventions from other context sources.
          Skills exist to prevent context drift and ensure consistency, not just for when you're uncertain. Loading a skill is cheap; missing domain-specific conventions or creating inconsistency is expensive.

          ## Web Fetching

          When the `webfetch` tool fails with a 403 Forbidden error or similar access restrictions, use a subagent with Playwright to fetch the content with a real browser instead.

          ### Usage

          If webfetch returns a 403 error:
          ```
          Error: HTTP 403 Forbidden
          ```

          Do NOT use the playwright_* tools directly in the main conversation, as they generate very large outputs that quickly fill the context window.

          Instead, use the Task tool to launch a subagent that will use Playwright to extract the content and return only the relevant information:
          ```
          Launch a general subagent with a prompt like:
          "Use the Playwright MCP server to navigate to [URL], extract [specific content needed], and return only the extracted information as markdown. Do not include full page snapshots or accessibility trees in your response to me."
          ```

          The subagent will handle all the verbose Playwright interactions in its own context, and only return the clean, extracted content back to you.

          ## Local Environment Instructions

          Avoid excessive use of `cd` commands at the start of your commands, if you are already in the right working directory, there is no need to `cd` into it before your command.

          Use podman, not docker. Before use, always run `podman machine start`
        '';
    }
  );
}
