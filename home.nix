# Home-manager switch is not necessary when is used with nix-darwin. darwin-rebuild will do it.
{
  pkgs,
  lib,
  ...
}: let
  # Self-updating tools installed through their official installers instead of
  # Nix/Homebrew, to get new releases as soon as they ship. Declared here so this
  # repo still reflects everything installed; versions are not pinned by Nix.
  # Each entry: binary path checked for presence -> installer command.
  selfUpdatingTools = {
    claude-code = {
      bin = "$HOME/.local/bin/claude";
      install = "curl -fsSL https://claude.ai/install.sh | bash";
    };
  };

  # Global npm packages (Homebrew node), upgraded to @latest on every rebuild.
  npmGlobalPackages = [
    "gentle-pi" # provides gentle-shell
    "@openai/codex"
  ];
  # npm 11 blocks install scripts by default. gentle-pi's postinstall fetches the
  # Gentle AI binary it needs; the rest are its dependencies' native setup.
  npmAllowScripts = ["gentle-pi" "@google/genai" "esbuild" "protobufjs"];
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "alvaroroman";
  home.homeDirectory = "/Users/alvaroroman";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.hello
    pkgs.fastfetch

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; }

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # home.file.".config/git" = {
  #   source = "${inputs.dotfiles}/git";
  #   recursive = true;
  # };
  # home.file = {
  # # Building this configuration will create a copy of 'dotfiles/screenrc' in
  # # the Nix store. Activating the configuration will then make '~/.screenrc' a
  # # symlink to the Nix store copy.
  # ".screenrc".source = dotfiles/screenrc;

  # # You can also set the file content immediately.
  # ".gradle/gradle.properties".text = ''
  #   org.gradle.console=verbose
  #   org.gradle.daemon.idletimeout=3600000
  # '';
  # };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/alvaroroman/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # programs.zsh.enableSyntaxHighlighting=true;
  # programs.zsh.enableCompletion = true;
  # programs.zsh.enableBashCompletion = true;

  # Applications configuration
  programs = {
  #   git = {
  #     enable = true;
  #     userName = "Alvaro-R";
  #     userEmail = "alvaro.roman@users.noreply.github.com";
  #     extraConfig = {
  #       core = {
  #         excludesFile="/Users/alvaroroman/.dotfiles/.config/git/gitignore_global";
  #         editor = "code --wait";
  #   };
  # };
  #   };
  };

  # Install missing self-updating tools; existing ones update themselves.
  # A failed install only warns so it never aborts the rest of the activation.
  home.activation.installSelfUpdatingTools = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${lib.makeBinPath [pkgs.bash pkgs.curl pkgs.coreutils]}:/usr/bin:/bin:$PATH"
    ${lib.concatStrings (lib.mapAttrsToList (name: tool: ''
        if [ ! -x "${tool.bin}" ]; then
          echo "Installing ${name}..."
          # pipefail: a failed download in `curl | bash` must not exit 0.
          run bash -o pipefail -c ${lib.escapeShellArg tool.install} \
            || echo "warning: failed to install ${name}" >&2
        fi
      '')
      selfUpdatingTools)}
  '';

  # Install or upgrade global npm packages; runs after the homebrew step, so
  # Homebrew node is available. A failure only warns, like the step above.
  home.activation.installNpmGlobalPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"
    if command -v npm >/dev/null; then
      run npm install --global --no-fund --no-audit \
        --allow-scripts=${lib.escapeShellArg (lib.concatStringsSep "," npmAllowScripts)} \
        ${lib.concatMapStringsSep " " (pkg: lib.escapeShellArg "${pkg}@latest") npmGlobalPackages} \
        || echo "warning: failed to install global npm packages" >&2
    else
      echo "warning: npm not found; skipping global npm packages" >&2
    fi
  '';
}
