{
  config,
  lib,
  ...
}: {
  # Placeholder - will be populated in Phase 4
  config = lib.mkIf config.homeManagerModules.prism.opencode.enable {
    # OpenCode configuration will go here
  };
}
