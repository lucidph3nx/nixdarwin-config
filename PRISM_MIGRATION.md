# Prism Development Environment - NixDarwin Migration Plan

## Document Purpose

This document provides a comprehensive, step-by-step plan to migrate the Prism development environment from the nixos-config repository to nixdarwin-config. This plan is designed to be resumable at any phase and can be handed off to another agent if needed.

**Migration Date:** January 12, 2026  
**Source:** `~/code/nixos-config` (nixos-config with prism)  
**Target:** `~/code/nixdarwin-config` (this repository)

---

## Executive Summary

**Prism** is an integrated development environment combining:
- **Neovim:** Fully-configured with LSP, plugins, and custom keybindings
- **Tmux:** Session management with agent-aware keybindings
- **OpenCode:** AI agent with secure permissions and environment isolation
- **Context Switcher:** Git worktree-aware project/session management (the "killer feature")
- **Helper Scripts:** Git worktree cloning, launcher, sessioniser

### Current vs Target State

**Current State (nixdarwin-config):**
- ✅ Basic neovim (~20 plugins)
- ✅ Basic tmux configuration
- ✅ OpenCode with Playwright MCP
- ✅ Simple project sessioniser
- ✅ Theme system (Everforest)

**Target State (full Prism):**
- 🎯 Enhanced neovim with additional plugins
- 🎯 Advanced tmux with agent integration
- 🎯 Context switcher with git worktree support
- 🎯 Enhanced OpenCode configuration
- 🎯 Helper scripts for workflow automation
- 🎯 3-window session layout (edit, agent, term)

---

## Configuration Decisions

Based on user input:

1. **Launcher:** Aerospace keyboard shortcut integration
2. **Module Enables:** Prism enabled by default, no per-machine config changes needed
3. **Obsidian Path:** `/Users/ben/Documents/obsidian` (capital D)
4. **Plugins:** Keep existing neovim plugins as-is (don't add extras from nixos-config)
5. **Window Layout:** 3-window default (edit, agent, term) ✅
6. **Kubernetes Config:** Use existing path `$HOME/code/azure-kubernetes/kubeconfig/kubeconfig-agents-readonly`
7. **Project Locations:** Search `~/code`, `~/documents/obsidian/` (remove `jarden-digital` and `.ssh`)

---

## Architecture Overview

### Directory Structure

```
modules/programs/prism/
├── default.nix              # Main orchestration module
├── tmux.nix                 # Tmux configuration
├── opencode.nix             # OpenCode configuration
├── sessioniser.nix          # Enhanced project sessioniser
├── context-switcher.nix     # Git worktree context switcher
├── scripts.nix              # Helper scripts (gwc, launcher)
└── neovim/                  # Neovim configuration (moved from home-manager)
    ├── default.nix
    ├── keymaps.nix
    ├── options.nix
    ├── autocmd.nix
    ├── abbreviations.nix
    └── plugins/
        └── (all existing plugin files)
```

### Module Options

```nix
homeManagerModules.prism = {
  enable = true;  # Default: true, enabled everywhere
  
  agent.envVars = {
    KUBECONFIG = "$HOME/code/azure-kubernetes/kubeconfig/kubeconfig-agents-readonly";
  };
  
  sessioniser.windows = [
    { index = 0; name = "edit"; command = null; }
    { index = 1; name = "agent"; command = "agent"; }
    { index = 2; name = "term"; command = null; }
  ];
  
  # Submodules (all default true)
  neovim.enable = true;
  opencode.enable = true;
  tmux.enable = true;
  sessioniser.enable = true;
  contextSwitcher.enable = true;
  scripts.enable = true;
  
  # Internal (computed)
  _internal.agentEnvPrefix = "<computed>";
};
```

---

## Implementation Phases

### Phase 1: Create Prism Module Structure

**Goal:** Set up the prism directory and main orchestration module

**Status:** ⏸️ Not Started

**Tasks:**

1. Create directory structure:
   ```bash
   mkdir -p modules/programs/prism/neovim/plugins
   ```

2. Create `modules/programs/prism/default.nix`:
   - Import `lib` and define module with proper function signature
   - Define options:
     - `homeManagerModules.prism.enable` (default: `true`)
     - `homeManagerModules.prism.agent.envVars` (attrset)
     - `homeManagerModules.prism.sessioniser.windows` (list of attrsets)
     - Submodule enables: `neovim.enable`, `opencode.enable`, `tmux.enable`, `sessioniser.enable`, `contextSwitcher.enable`, `scripts.enable` (all default `true`)
     - `homeManagerModules.prism._internal.agentEnvPrefix` (computed from `agent.envVars`)
   - Set defaults for `agent.envVars`:
     ```nix
     agent.envVars = lib.mkDefault {
       KUBECONFIG = "$HOME/code/azure-kubernetes/kubeconfig/kubeconfig-agents-readonly";
     };
     ```
   - Set defaults for `sessioniser.windows`:
     ```nix
     sessioniser.windows = lib.mkDefault [
       { index = 0; name = "edit"; command = null; }
       { index = 1; name = "agent"; command = "agent"; }
       { index = 2; name = "term"; command = null; }
     ];
     ```
   - Compute `_internal.agentEnvPrefix`:
     ```nix
     _internal.agentEnvPrefix = lib.concatStringsSep " " (
       lib.mapAttrsToList (name: value: "${name}=${value}") config.homeManagerModules.prism.agent.envVars
     );
     ```
   - Add imports for submodules (will create in later phases):
     ```nix
     imports = [
       ./neovim
       ./opencode.nix
       ./tmux.nix
       ./sessioniser.nix
       ./context-switcher.nix
       ./scripts.nix
     ];
     ```

3. Add prism import to `modules/home-manager/default.nix`:
   ```nix
   imports = [
     # ... existing imports
     ../programs/prism
   ];
   ```

4. Remove prism submodule enables from `modules/home-manager/cli/default.nix`:
   - Delete lines for `tmux.enable` and `tmuxSessioniser.enable` (will be managed by prism)
   - Keep other CLI tools as-is

5. Remove neovim enable from `modules/home-manager/default.nix`:
   - Delete `neovim.enable` line (will be managed by prism)

6. Remove opencode enable from `modules/home-manager/default.nix`:
   - Delete `opencode.enable` line (will be managed by prism)

**Testing:**
```bash
nix flake check
darwin-rebuild build --flake .
```

**Expected Result:** Build succeeds but functionality unchanged (imports point to old locations still)

**Rollback:** `git revert HEAD`

---

### Phase 2: Migrate Neovim to Prism

**Goal:** Move neovim configuration into prism structure

**Status:** ⏸️ Not Started

**Prerequisites:** Phase 1 complete

**Tasks:**

1. Move neovim directory:
   ```bash
   # Don't actually run these yet - document only
   mv modules/home-manager/neovim/* modules/programs/prism/neovim/
   rmdir modules/home-manager/neovim
   ```

2. Update `modules/programs/prism/neovim/default.nix`:
   - Change option path from `homeManagerModules.neovim.enable` to `homeManagerModules.prism.neovim.enable`
   - Wrap config in `lib.mkIf config.homeManagerModules.prism.neovim.enable`
   - Keep all existing functionality unchanged

3. Update all neovim plugin files in `modules/programs/prism/neovim/plugins/`:
   - No changes needed if they don't reference the enable option
   - If any reference `homeManagerModules.neovim.enable`, update to `homeManagerModules.prism.neovim.enable`

4. Update `modules/programs/prism/neovim/keymaps.nix`:
   - Verify `C-f` keybinding exists for sessioniser (should already be there)

5. Update `modules/programs/prism/neovim/autocmd.nix`:
   - Ensure format-on-save is present

6. Update `modules/programs/prism/neovim/plugins/obsidian.nix`:
   - Update vault path to use `/Users/ben/Documents/obsidian` (capital D)
   - Or use `${config.home.homeDirectory}/Documents/obsidian`

7. Remove old neovim import from `modules/home-manager/default.nix`:
   - Delete `./neovim` from imports list

**Testing:**
```bash
darwin-rebuild switch --flake .
nvim --version  # Should launch
nvim test.md    # Test in a markdown file
# In neovim:
:checkhealth    # Verify LSP and plugins
:Telescope find_files  # Test telescope
<leader>sf      # Test telescope keybinding
# Test Obsidian (if in vault)
:ObsidianToday
```

**Expected Result:** Neovim works identically to before, now managed by prism

**Rollback:** `git revert HEAD`

---

### Phase 3: Migrate Tmux to Prism

**Goal:** Move tmux configuration to prism and add agent-aware keybindings

**Status:** ⏸️ Not Started

**Prerequisites:** Phase 2 complete

**Tasks:**

1. Move tmux configuration:
   ```bash
   # Don't actually run - document only
   mv modules/home-manager/cli/tmux.nix modules/programs/prism/tmux.nix
   ```

2. Update `modules/programs/prism/tmux.nix`:
   - Change option: `homeManagerModules.tmux.enable` → `homeManagerModules.prism.tmux.enable`
   - Wrap config in `lib.mkIf config.homeManagerModules.prism.tmux.enable`
   - Keep all existing configuration (prefix, terminal, colors, image passthrough)

3. Add context switcher popup keybinding to `extraConfig`:
   ```tmux
   # context switcher popup
   bind -n C-f display-popup -E -w 80% -h 80% -b single "cli.tmux.contextSwitcher"
   ```

4. Add term window toggle to `extraConfig`:
   ```tmux
   # toggle to/from term window
   unbind C-Space
   bind -n C-Space if-shell 'tmux has-session -t "#{session_name}:term" 2>/dev/null' \
     'if-shell "[ #{window_name} = term ]" "last-window" "select-window -t term"' \
     'new-window -n term'
   ```

5. Add split toggle for agent window to `extraConfig`:
   ```tmux
   # toggle split layout between edit and agent
   bind Space if-shell 'tmux list-windows | grep -q "agent"' \
     'if-shell "tmux list-panes | wc -l | grep -q 1" \
       "split-window -h -t edit \\; select-pane -t 1 \\; send-keys -t agent C-z \\; select-window -t edit \\; select-pane -t 1 \\; send-keys fg Enter" \
       "kill-pane -t 1"' \
     'display-message "No agent window found"'
   ```

6. Update agent window keybinding to use shared env vars:
   - Access `config.homeManagerModules.prism._internal.agentEnvPrefix`
   - Update line:
     ```nix
     bind a new-window -n agent "${config.homeManagerModules.prism._internal.agentEnvPrefix} opencode"
     ```

7. Remove old tmux import from `modules/home-manager/cli/default.nix`:
   - Delete `./tmux.nix` from imports

8. Remove tmux.enable from `modules/home-manager/cli/default.nix`:
   - Delete from `homeManagerModules` options block

**Testing:**
```bash
darwin-rebuild switch --flake .
tmux  # Launch tmux
# Test keybindings:
C-a a        # New agent window
C-Space      # Toggle term window
C-f          # Should show error (context switcher not yet implemented)
Space        # Toggle split (if agent window exists)
C-u/C-d      # Scroll in opencode (if opencode running)
```

**Expected Result:** Tmux works with new keybindings (context switcher will error until Phase 5)

**Rollback:** `git revert HEAD`

---

### Phase 4: Migrate OpenCode to Prism

**Goal:** Move opencode configuration to prism structure

**Status:** ⏸️ Not Started

**Prerequisites:** Phase 3 complete

**Tasks:**

1. Move opencode configuration:
   ```bash
   # Don't actually run - document only
   mv modules/home-manager/opencode/default.nix modules/programs/prism/opencode.nix
   # Keep the command file
   mkdir -p modules/programs/prism/opencode-files
   mv modules/home-manager/opencode/command modules/programs/prism/opencode-files/
   rmdir modules/home-manager/opencode
   ```

2. Update `modules/programs/prism/opencode.nix`:
   - Change option: `homeManagerModules.opencode.enable` → `homeManagerModules.prism.opencode.enable`
   - Wrap config in `lib.mkIf config.homeManagerModules.prism.opencode.enable`
   - Update shell alias to use shared env prefix:
     ```nix
     programs.zsh.shellAliases = {
       opencode = "${config.homeManagerModules.prism._internal.agentEnvPrefix} opencode";
     };
     ```
   - Remove tmux extraConfig section (now handled in tmux.nix)
   - Remove neovim extraLuaConfig section (commented out anyway)
   - Update command file path:
     ```nix
     xdg.configFile."opencode/command".source = ./opencode-files/command;
     ```
   - Keep all existing permissions, MCP servers, and config

3. Remove old opencode import from `modules/home-manager/default.nix`:
   - Delete `./opencode` from imports

4. Remove opencode.enable from `modules/home-manager/default.nix`:
   - Delete from `homeManagerModules` options block

**Testing:**
```bash
darwin-rebuild switch --flake .
opencode --version  # Test alias works
cd ~/code/some-project
opencode .          # Launch opencode
# Verify:
# - MCP servers load (check startup messages)
# - Theme is correct
# - Can execute allowed commands (ls, cat, kubectl get pods)
# - Asked for permission on restricted commands (rm, git push)
```

**Expected Result:** OpenCode works identically, now managed by prism with shared env vars

**Rollback:** `git revert HEAD`

---

### Phase 5: Implement Context Switcher

**Goal:** Add git worktree-aware context switching (the killer feature)

**Status:** ⏸️ Not Started

**Prerequisites:** Phase 4 complete, Phase 6 (scripts) should be done first for gwc command

**Tasks:**

1. Create `modules/programs/prism/context-switcher.nix`:
   - Define option: `homeManagerModules.prism.contextSwitcher.enable` (default `true`)
   - Wrap in `lib.mkIf config.homeManagerModules.prism.contextSwitcher.enable`

2. Create Python script `cli.tmux.contextSwitcher`:
   - Reference nixos-config: `~/code/nixos-config/modules/programs/prism/context-switcher.nix`
   - Script should:
     - Get project list from `cli.tmux.projectGetter`
     - Add `[scratchpad]` option
     - Use fzy for selection
     - Detect bare repos (`.bare` directory exists)
     - List worktrees if bare repo, sort default branch first
     - Allow typing new branch name
     - Create worktree on-the-fly if branch doesn't exist
     - Session naming: `project_name` for regular, `project@branch` for worktrees
     - Create session with windows from `config.homeManagerModules.prism.sessioniser.windows`
     - Use smart file opening (same logic as sessioniser)
     - Use `config.homeManagerModules.prism._internal.agentEnvPrefix` for agent window

3. Install script:
   ```nix
   home.file.".local/scripts/cli.tmux.contextSwitcher" = {
     executable = true;
     text = '' <script content> '';
   };
   ```

4. Key worktree detection logic:
   ```python
   # Check if bare repo
   bare_dir = os.path.join(selected_dir, ".bare")
   if os.path.isdir(bare_dir):
       # List worktrees using: git -C .bare worktree list
       # Parse output for worktree paths
       # Get default branch: git -C .bare symbolic-ref refs/remotes/origin/HEAD
       # Sort with default branch first
       # Use fzy for selection or allow typing new branch name
   
   # Create new worktree if branch doesn't exist:
   # 1. Check if branch exists locally
   # 2. Check if branch exists on remote
   # 3. Otherwise create from default branch
   ```

5. Session creation logic:
   ```python
   # For regular projects:
   session_name = project.replace(".", "_")
   
   # For worktrees:
   session_name = f"{project}@{branch}"
   
   # Create session if doesn't exist
   # Create windows from config.sessioniser.windows
   # Window 0: nvim with smart file detection
   # Window 1: opencode with env vars
   # Window 2: plain shell
   
   # Switch to session
   ```

6. Update `modules/programs/prism/sessioniser.nix`:
   - Update `cli.tmux.projectGetter` script
   - Change locations to:
     ```bash
     locations=(
       "~/code"
     )
     specific_folders=(
       "~/Documents/obsidian/"
     )
     ```
   - (Note: capital D for Documents)

**Testing:**
```bash
darwin-rebuild switch --flake .

# Test context switcher
# In tmux:
C-f                    # Open context switcher

# Test with regular project:
# 1. Select non-worktree project
# 2. Verify 3 windows created
# 3. Verify nvim opens correct file

# Test with worktree project (need Phase 6 first):
# 1. Clone test repo: gwc git@github.com:user/test-repo.git
# 2. C-f to open context switcher
# 3. Select the test-repo
# 4. Should list existing worktrees
# 5. Type new branch name "test-feature"
# 6. Verify new worktree created
# 7. Verify session named "test-repo@test-feature"
# 8. Verify 3 windows created

# Test scratchpad:
# 1. C-f, select [scratchpad]
# 2. Verify single term window
# 3. Verify session named "scratchpad"
```

**Expected Result:** Full git worktree workflow functional

**Rollback:** `git revert HEAD`

---

### Phase 6: Add Helper Scripts

**Goal:** Implement git worktree clone and prism launcher

**Status:** ⏸️ Not Started

**Prerequisites:** Phase 4 complete (do this before Phase 5 for gwc testing)

**Tasks:**

1. Create `modules/programs/prism/scripts.nix`:
   - Define option: `homeManagerModules.prism.scripts.enable` (default `true`)
   - Wrap in `lib.mkIf config.homeManagerModules.prism.scripts.enable`

2. Create `cli.git.worktreeClone` script:
   - Reference nixos-config: `~/code/nixos-config/modules/programs/prism/scripts.nix`
   - Takes arguments: `<repo-url>` and optional `[directory-name]`
   - Logic:
     ```bash
     # Parse repo URL to get default directory name
     # Create project directory
     # Clone as bare: git clone --bare <url> project/.bare
     # Set up git directory: echo "gitdir: ./.bare" > project/.git
     # Configure fetch: git -C .bare config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
     # Detect default branch (main/master)
     # Create default branch worktree: git -C .bare worktree add ../main main
     # Set upstream: git -C main branch --set-upstream-to=origin/main
     ```
   - Handle errors gracefully

3. Install worktree clone script and alias:
   ```nix
   home.file.".local/scripts/cli.git.worktreeClone" = {
     executable = true;
     text = '' <script content> '';
   };
   
   programs.zsh.shellAliases = {
     gwc = "cli.git.worktreeClone";
   };
   ```

4. Create `cli.prism.launch` script:
   - Reference nixos-config: `~/code/nixos-config/modules/programs/prism/scripts.nix`
   - Logic:
     ```bash
     # Check if inside tmux
     if [ -n "$TMUX" ]; then
       # Inside tmux: switch to scratchpad session
       if ! tmux has-session -t scratchpad 2>/dev/null; then
         tmux new-session -ds scratchpad
         tmux rename-window -t scratchpad:0 term
       fi
       tmux switch-client -t scratchpad
       # Open context switcher popup
       tmux display-popup -E -w 80% -h 80% "cli.tmux.contextSwitcher"
     else
       # Outside tmux: launch kitty with tmux
       kitty -e tmux new-session -A -s scratchpad \; \
         rename-window term \; \
         display-popup -E -w 80% -h 80% "cli.tmux.contextSwitcher"
     fi
     ```

5. Install launcher script:
   ```nix
   home.file.".local/scripts/cli.prism.launch" = {
     executable = true;
     text = '' <script content> '';
   };
   ```

6. Add Aerospace keyboard shortcut:
   - Check if aerospace config is managed by nix or manual file
   - Current file: `.config/aerospace/aerospace.toml` (symlinked from `machines/m1mac/files/aerospace.toml`)
   - Need to add keybinding in aerospace.toml:
     ```toml
     # Prism launcher
     alt-p = "exec-and-forget /Users/ben/.local/scripts/cli.prism.launch"
     ```
   - Update `machines/m1mac/files/aerospace.toml` to add this binding

7. Make kitty available if not already in home.packages:
   - Check if kitty is installed (should be from `modules/home-manager/guiApps/kitty.nix`)
   - Verify it's available on PATH

**Testing:**
```bash
darwin-rebuild switch --flake .

# Test worktree clone
gwc git@github.com:user/test-repo.git
cd test-repo
ls -la
# Should see:
# .bare/  (bare repo)
# .git    (points to .bare)
# main/   (worktree for default branch)

cd main
git status  # Should show clean working tree
git log     # Should show commit history

# Test launcher from terminal (outside tmux)
cli.prism.launch
# Should:
# 1. Launch kitty
# 2. Start tmux scratchpad session
# 3. Open context switcher popup

# Test launcher from tmux (inside tmux)
# (in existing tmux session)
cli.prism.launch
# Should:
# 1. Switch to scratchpad session
# 2. Open context switcher popup

# Test Aerospace keybinding
# Press ALT+p
# Should launch prism environment
```

**Expected Result:** All helper scripts functional, launcher accessible via ALT+p

**Rollback:** `git revert HEAD`

---

### Phase 7: Enhance Sessioniser

**Goal:** Upgrade sessioniser to 3-window layout with agent integration

**Status:** ⏸️ Not Started

**Prerequisites:** All previous phases complete

**Tasks:**

1. Move sessioniser configuration:
   ```bash
   # Don't actually run - document only
   mv modules/home-manager/cli/tmuxSessioniser.nix modules/programs/prism/sessioniser.nix
   ```

2. Update `modules/programs/prism/sessioniser.nix`:
   - Change option: `homeManagerModules.tmuxSessioniser.enable` → `homeManagerModules.prism.sessioniser.enable`
   - Wrap in `lib.mkIf config.homeManagerModules.prism.sessioniser.enable`
   - `cli.tmux.projectGetter` already updated in Phase 5

3. Enhance `cli.tmux.projectSessioniser` script:
   - Keep existing project selection and file detection logic
   - Update to create 3 windows instead of 1:
     ```bash
     # Window 0: edit (existing nvim logic)
     tmux new-session -s $selected_name -c $selected -d -n edit
     if [[ -n $selected_file ]]; then
         tmux send-keys -t $selected_name:edit "nvim '$selected_file'" C-m
     else
         tmux send-keys -t $selected_name:edit "nvim" C-m
     fi
     
     # Window 1: agent (opencode with env vars)
     tmux new-window -t $selected_name:1 -n agent -c $selected
     tmux send-keys -t $selected_name:agent "${envPrefix} opencode" C-m
     
     # Window 2: term (plain shell)
     tmux new-window -t $selected_name:2 -n term -c $selected
     
     # Select edit window
     tmux select-window -t $selected_name:edit
     ```
   - Use `config.homeManagerModules.prism._internal.agentEnvPrefix` for env vars
   - Keep existing file detection logic (obsidian landing page, README.md)
   - Update obsidian path check to use `Documents` (capital D)

4. Make window creation configurable:
   - Read from `config.homeManagerModules.prism.sessioniser.windows`
   - Loop through window definitions:
     ```nix
     let
       windowsConfig = config.homeManagerModules.prism.sessioniser.windows;
       createWindows = lib.concatMapStringsSep "\n" (win: ''
         tmux new-window -t $selected_name:${toString win.index} -n ${win.name} -c $selected
         ${lib.optionalString (win.command == "agent") ''
           tmux send-keys -t $selected_name:${win.name} "${config.homeManagerModules.prism._internal.agentEnvPrefix} opencode" C-m
         ''}
       '') (lib.tail windowsConfig);  # Skip first window (created with session)
     in
     ```

5. Remove old sessioniser import from `modules/home-manager/cli/default.nix`:
   - Delete `./tmuxSessioniser.nix` from imports
   - Delete `tmuxSessioniser.enable` from options

**Testing:**
```bash
darwin-rebuild switch --flake .

# Test sessioniser
# In neovim (or terminal):
C-f             # Open sessioniser

# Select a project
# Verify:
# 1. Session created with correct name
# 2. Three windows: edit, agent, term
# 3. Edit window has nvim open
# 4. Agent window has opencode running
# 5. Term window has plain shell
# 6. Correct file opened in nvim (landing page, README, or default)

# Test with Obsidian vault:
C-f
# Select obsidian folder
# Verify opens Documents/obsidian/notes/landingpage.md

# Test from zsh:
cli.tmux.projectSessioniser
# Should work the same
```

**Expected Result:** Sessioniser creates full 3-window layout with agent integration

**Rollback:** `git revert HEAD`

---

## Testing Checklist

After all phases complete, verify the complete prism workflow:

### Basic Functionality
- [ ] Neovim launches without errors
- [ ] LSP works (go to definition, hover, diagnostics)
- [ ] Telescope works (file search, grep)
- [ ] Tmux launches with correct theme
- [ ] OpenCode launches and connects to MCP servers

### Tmux Keybindings
- [ ] `C-a h/j/k/l` - Navigate panes
- [ ] `C-a v/b` - Split panes
- [ ] `C-a a` - New agent window
- [ ] `C-Space` - Toggle term window
- [ ] `C-f` - Open context switcher popup
- [ ] `Space` - Toggle split layout
- [ ] `C-u/C-d` in opencode - Scroll agent

### Neovim Keybindings
- [ ] `C-f` - Open project sessioniser
- [ ] `<leader>sf` - Telescope find files
- [ ] `<leader>sg` - Telescope live grep
- [ ] `<leader>sr` - Recent files
- [ ] `gd` - Go to definition
- [ ] `<leader>ca` - Code actions
- [ ] `<leader>f` - Format buffer
- [ ] Obsidian shortcuts (if in vault)

### Workflows

#### Regular Project Workflow
- [ ] Launch prism: `ALT+p` or `cli.prism.launch`
- [ ] Select project from list
- [ ] Verify 3 windows created (edit, agent, term)
- [ ] Verify nvim opens appropriate file
- [ ] Test switching between windows
- [ ] Test using agent in agent window
- [ ] Test running commands in term window

#### Git Worktree Workflow
- [ ] Clone bare repo: `gwc git@github.com:user/repo.git`
- [ ] Verify structure: `.bare/`, `.git`, `main/`
- [ ] Open context switcher: `C-f`
- [ ] Select the bare repo project
- [ ] Verify worktree list shows (with main/master at top)
- [ ] Type new branch name: `feature-test`
- [ ] Verify new worktree created
- [ ] Verify session named `repo@feature-test`
- [ ] Verify 3 windows in new session
- [ ] Switch to main worktree: `C-f`, select repo, select main
- [ ] Verify session named `repo@main`
- [ ] Both sessions exist simultaneously

#### Obsidian Workflow
- [ ] `C-f`, select obsidian folder
- [ ] Verify opens `Documents/obsidian/notes/landingpage.md`
- [ ] Test `:ObsidianToday`
- [ ] Test `<leader>od` - Today's daily note
- [ ] Test `<leader>ol` - Create wiki link
- [ ] Test `<leader>osn` - Search notes

#### Scratchpad Workflow
- [ ] `C-f`, select `[scratchpad]`
- [ ] Verify single term window
- [ ] Verify session named `scratchpad`
- [ ] Can switch away and back with `C-f`

### Integration Tests
- [ ] Launch from outside tmux (terminal)
- [ ] Launch from inside tmux
- [ ] Launch with Aerospace: `ALT+p`
- [ ] Switch between multiple project sessions
- [ ] Multiple worktree sessions from same repo
- [ ] Theme consistency across tmux, neovim, opencode
- [ ] Environment variables passed to agent correctly

---

## Rollback Strategy

Each phase is a separate git commit. To rollback:

1. **Rollback single phase:**
   ```bash
   git revert HEAD
   darwin-rebuild switch --flake .
   ```

2. **Rollback multiple phases:**
   ```bash
   git log --oneline  # Find commit before migration
   git revert --no-commit <commit>..HEAD
   git commit -m "Rollback prism migration"
   darwin-rebuild switch --flake .
   ```

3. **Emergency disable:**
   Add to any machine config:
   ```nix
   homeManagerModules.prism.enable = false;
   ```

---

## Common Issues & Solutions

### Issue: Flake check fails
**Solution:** 
- Check syntax errors in nix files
- Verify all imports exist
- Run `nix flake check --show-trace` for detailed errors

### Issue: Context switcher errors with "fzy not found"
**Solution:**
- Verify fzy is in home.packages
- Check `$HOME/.local/scripts` is in PATH

### Issue: Worktree creation fails
**Solution:**
- Verify git version supports worktrees (2.5+)
- Check bare repo structure (`.bare` directory exists)
- Verify remote is configured correctly

### Issue: Aerospace keybinding doesn't work
**Solution:**
- Restart Aerospace: `aerospace reload-config`
- Check aerospace.toml syntax
- Verify script path is correct
- Test script directly from terminal first

### Issue: OpenCode MCP servers fail to load
**Solution:**
- Check nodejs_24 is available: `node --version`
- Verify Chromium is at `/Applications/Chromium.app/Contents/MacOS/Chromium`
- Check MCP server logs in opencode

### Issue: Tmux keybindings conflict
**Solution:**
- Check for conflicting keybindings in aerospace or system
- Test keybindings in plain tmux session (no other config)
- Use `tmux list-keys` to see all bindings

### Issue: Neovim plugins fail to load
**Solution:**
- Run `:checkhealth` in neovim
- Check LSP servers are installed: `which lua-language-server`
- Verify plugin files in `~/.config/nvim/`

---

## Phase Progress Tracking

Use this table to track progress:

| Phase | Status | Started | Completed | Tested | Notes |
|-------|--------|---------|-----------|--------|-------|
| Phase 1: Module Structure | ⏸️ Not Started | - | - | - | - |
| Phase 2: Neovim Migration | ⏸️ Not Started | - | - | - | - |
| Phase 3: Tmux Migration | ⏸️ Not Started | - | - | - | - |
| Phase 4: OpenCode Migration | ⏸️ Not Started | - | - | - | - |
| Phase 5: Context Switcher | ⏸️ Not Started | - | - | - | - |
| Phase 6: Helper Scripts | ⏸️ Not Started | - | - | - | - |
| Phase 7: Enhanced Sessioniser | ⏸️ Not Started | - | - | - | - |

Status Codes:
- ⏸️ Not Started
- 🔄 In Progress
- ✅ Complete
- ❌ Failed
- ⏭️ Skipped

---

## Dependencies Reference

All dependencies already present in nixdarwin-config or overlays:

**Already Available:**
- ✅ nodejs_24 (for opencode, MCP servers)
- ✅ opencode (via overlay from master)
- ✅ playwright-mcp (via overlay from master)
- ✅ fzy (for fuzzy finding)
- ✅ tmux
- ✅ neovim
- ✅ kitty
- ✅ git
- ✅ python3
- ✅ zsh
- ✅ LSP servers (helm-ls, lua-language-server, nil, rust-analyzer, typescript-language-server, yaml-language-server)
- ✅ Formatters (stylua, nixfmt, black, jq)

**No new dependencies required** ✅

---

## Handover Notes

If handing over to another agent:

1. **Current Phase:** Check the Phase Progress Tracking table above
2. **Last Commit:** Run `git log --oneline -5` to see recent commits
3. **Testing Status:** Review Testing Checklist section
4. **Open Issues:** Check Common Issues & Solutions section
5. **Context:** This document and `~/code/nixos-config` are the source of truth

**Key Files to Reference:**
- Source (nixos-config): `~/code/nixos-config/modules/programs/prism/`
- Target (nixdarwin-config): `~/code/nixdarwin-config/modules/programs/prism/`
- This plan: `~/code/nixdarwin-config/PRISM_MIGRATION.md`

**Commands to Resume:**
```bash
cd ~/code/nixdarwin-config
git status                    # Check current state
git log --oneline            # Check completed phases
nix flake check              # Verify configuration
darwin-rebuild build --flake .  # Test build
```

---

## Success Criteria

✅ All 7 phases completed without errors  
✅ `nix flake check` passes  
✅ `darwin-rebuild switch --flake .` succeeds  
✅ All items in Testing Checklist verified  
✅ Git worktree workflow functional  
✅ 3-window session layout works  
✅ Context switcher can create/switch worktrees  
✅ Aerospace launcher (`ALT+p`) works  
✅ No regressions in existing functionality  
✅ Documentation updated  

---

## Estimated Timeline

- Phase 1: 30 minutes
- Phase 2: 1 hour
- Phase 3: 1 hour
- Phase 4: 30 minutes
- Phase 5: 2-3 hours (most complex)
- Phase 6: 1-2 hours (includes Aerospace integration)
- Phase 7: 1 hour
- Testing & debugging: 2-3 hours

**Total: 9-12 hours**

**Recommended Approach:**
- Session 1 (4-5 hours): Phases 1-4 (foundation)
- Session 2 (5-7 hours): Phases 5-7 + testing (advanced features)

---

## Notes

- This migration preserves all existing functionality while adding prism features
- Prism is enabled by default - no per-machine config changes needed
- All configuration is declarative and reproducible
- The git worktree support is the standout feature of prism
- Each phase is independently testable and reversible

**Last Updated:** January 12, 2026  
**Document Version:** 1.0  
**Migration Status:** Ready to Begin
