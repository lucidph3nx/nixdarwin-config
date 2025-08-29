# AGENTS.md

Build / validate:
- Apply: `darwin-rebuild switch --flake .`  (primary verification)
- Build only: `darwin-rebuild build --flake .`
- Flake checks: `nix flake check` (must pass before commit)
- Update inputs: `nix flake update` (run only when intentional)
- Format: `nix fmt` before committing (no separate test suite; this repo relies on successful eval/build)

Structure & scope:
- Machine specifics: `machines/{m1mac|m1mac-test|x86mac}/`; shared logic: `modules/`; user apps & dotfiles: `modules/home-manager/`
- Secrets: edit with `sops` only; encrypted material lives in `secrets/`; never commit decrypted outputs
- Themes: switch in `modules/colourScheme/default.nix` by toggling imports (Everforest active)

Module style:
- File order: options -> imports -> config; function header `{ config, lib, pkgs, ... }:`
- Use `lib.mkEnableOption` + `homeManagerModules.<name>.enable`; default via `lib.mkDefault`; conditional blocks via `lib.mkIf`
- Prefer explicit imports; keep modules minimal, deterministic, and side‑effect free

Packages & channels:
- Default `pkgs` (stable); reach for `pkgs-unstable` or `pkgs-master` only when required (document why in commit message); Homebrew only if absent from Nix

Quality & safety:
- No tests: validate by successful build + switch; avoid breaking other machines—touch only the intended host directory
- Keep secrets, keys, tokens out of git; run formatting + flake check before requesting review
