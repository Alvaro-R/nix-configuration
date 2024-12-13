{
  description = "Nix-darwin configuration file";

  inputs = {
    # Nix Packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Canal estable
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    # Nix Darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # Homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Dotfiles
    # dotfiles = {
    #   url = "github:Alvaro-R/dotfiles";
    #   flake = false;
    # };
  };

  outputs = inputs @ {
    self,
    # dotfiles,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    home-manager,
  }: let
    configuration = {pkgs, ...}: {
      # Search for configuration options: https://mynixos.com/nix-darwin/options

      # >>>>>>>>>> Nixpkgs configuration >>>>>>>>>>
      # Allow installation of packages with unfree licence
      nixpkgs.config.allowUnfree = true;
      # <<<<<<<<<< Nixpkgs configuration <<<<<<<<<<

      # >>>>>>>>>> Packages >>>>>>>>>>
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.neovim
        pkgs.bashly
        pkgs.alejandra
        pkgs.nixd
        pkgs.bash-completion
      ];
      # <<<<<<<<<< Packages <<<<<<<<<<

      nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

      # >>>>>>>>>> Homebrew >>>>>>>>>>
      # Homebrew configuration
      homebrew = {
        enable = true;
        brews = [
          "mas"
        ];
        # List of Cask Apps
        casks = [
          "wezterm"
	  "visual-studio-code"
        ];
        # List of MacOS App Store Apps
        masApps = {
          # App name = App Store ID
          # Use 'mas search app_name' to find App Store ID
          "Windows App" = 1295203466;
          "Parallels Desktop" = 1085114709;
        };
        # Ensure only packages specified in configuration are installed.
        # Apps not listed in configuration will be removed
        onActivation.cleanup = "zap";
        # Update Homebrew packages
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };
      # <<<<<<<<<< Homebrew <<<<<<<<<<

      # >>>>>>>>>> Fonts >>>>>>>>>>
      # List fonts to be installed in system profile.
      fonts.packages = [
        # Version Nix 24.0
        # (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})
        # Version Nix 25.05
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.fira-mono
      ];
      # <<<<<<<<<< Fonts <<<<<<<<<<

      users.users.alvaroroman = {
        name = "alvaroroman";
        home = "/Users/alvaroroman";
      };
      # home-manager.backupFileExtension = "backup";

      
      nix.configureBuildUsers = true;
      nix.useDaemon = true;

      # Nix Garbage Collection
      nix.gc = {
          automatic = true;
          interval = [
            {
              Hour = 3;
              Minute = 15;
              Weekday = 7;
              }
            ];
          options = "--delete-older-than 30d";
        };

      # Nix Store Optimiser
      nix.optimise.automatic = true;
      nix.optimise.interval = [
        {
          Hour = 4;
          Minute = 15;
          Weekday = 7;
        }
      ];

      # >>>>>>>>> MACOS CONFIGURATION >>>>>>>>>
      # Local Host Name
      networking.hostName = "Ecthelion";
      # Computer Name
      networking.computerName = "Ecthelion";

      # System configuration
      system.defaults = {
        dock.autohide = true;
      };

      security.pam.enableSudoTouchIdAuth = true;

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true; # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;
      # <<<<<<<<<< MACOS CONFIGURATION <<<<<<<<<<

      # The platform the configuration will be used on.
      # x86_64-darwin - Intel
      # aarch64-darwin - Apple Silicon
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Ecthelion
    darwinConfigurations."Ecthelion" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          # Homebrew config
          nix-homebrew = {
            enable = true;
            # Apple Silicon Only
            enableRosetta = true;
            # User owning the Hombrew prefix
            user = "alvaroroman";
            # If Homebrew already installed, automatically migrate existing Homebrew installations
            autoMigrate = true;
          };
        }
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.alvaroroman = import ./home.nix;

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
          home-manager.extraSpecialArgs = {inherit inputs;};
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Ecthelion".pkgs;
  };
}
