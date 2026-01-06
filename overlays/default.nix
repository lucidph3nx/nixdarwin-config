{
  outputs,
  inputs,
}: let
  addPatches = pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ patches;
    });
in {
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs
      (_: flake: (flake.legacyPackages or flake.packages or {}).${final.system} or {})
      inputs;
  };
  # Overlays for various pkgs (e.g. broken, not updated)
  modifications = final: prev: let
    masterPkgs = import inputs.nixpkgs-master {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  in rec {
    # use master for opencode, need the bleeding edge
    opencode = masterPkgs.opencode;

    # use master for claude-code, need the bleeding edge
    claude-code = masterPkgs.claude-code;

    # use master for playwright-mcp, not in stable yet
    playwright-mcp = masterPkgs.playwright-mcp;
  };
}
