---
name: machine-management
description: "Manage this Mac declaratively with nix-darwin. Trigger: installing, removing, or updating any software, CLI, app, or macOS setting on this computer (brew, npm -g, curl installers, mas, defaults)."
metadata:
  author: alvaroroman
  version: "1.0"
---

# Machine management

This Mac is fully managed declaratively with nix-darwin + Home Manager.

- Source of truth: `~/.config/nix/nix-darwin`
- Read `~/.config/nix/nix-darwin/AGENTS.md` BEFORE changing anything; it says
  where each kind of software is declared and how to apply changes.

## Rules

- NEVER install imperatively (`brew install`, `npm install -g`, `curl | sh`,
  `mas install`, manual `defaults write`). Homebrew cleanup is `zap`: undeclared
  packages are removed on the next rebuild.
- Declare the change in that repo, then apply it:
  `cd ~/.config/nix/nix-darwin && git add -A && sudo darwin-rebuild switch --flake .#Ecthelion`
- If you are working in another project and need a tool, propose the change to
  the nix-darwin repo instead of installing it ad hoc.
- If the change alters HOW the machine is managed (structure, mechanisms,
  commands, agents), update `AGENTS.md`, this skill, and the skill deployment
  in `home.nix` in the same commit. See "Keep docs, skills, and agent config in
  sync" in `AGENTS.md`.
