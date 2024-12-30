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
        pkgs.lsd
      ];
      # <<<<<<<<<< Packages <<<<<<<<<<

      # This allow that this syntax: <nixpkgs> refers to the path of inputs nixpkgs.
      nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

      # >>>>>>>>>> Homebrew >>>>>>>>>>
      # Homebrew configuration
      homebrew = {
        enable = true;
        brews = [
          "mas"
          "stow"
          "r"
          "starship"
          "pixi"
          "fzf"
          "bat"
          "zoxide"
          "zsh-autosuggestions"
          "zsh-completions"
          "zsh-syntax-highlighting"
        ];
        # List of Cask Apps
        casks = [
          "wezterm"
          "visual-studio-code"
          "rstudio"
          "spotify"
          "microsoft-teams"
          "readdle-spark"
          "onedrive"
          "obsidian"
          "zotero"
          "hammerspoon"
          "downie"
        ];
        # List of MacOS App Store Apps
        masApps = {
          # App name = App Store ID
          # Use 'mas search app_name' to find App Store ID
          "Windows App" = 1295203466;
          "Parallels Desktop" = 1085114709;
          "WhatsApp" = 310633997;
          "Slack" = 803453959;
          "ASUSTOR Control Center" = 1515453657;
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
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.fira-mono
        pkgs.nerd-fonts.caskaydia-mono
        pkgs.nerd-fonts.sauce-code-pro
        pkgs.nerd-fonts.monaspace
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
      # https://mynixos.com/nix-darwin/options
      # Local Host Name
      networking.hostName = "Ecthelion";
      # Computer Name
      networking.computerName = "Ecthelion";

      # System configuration
      system.defaults = {
        # Finder
        finder.AppleShowAllExtensions = true; # Always show file extensions
        finder.AppleShowAllFiles = false; # Allways shos hidden files
        finder.FXPreferredViewStyle = "clmv"; # "icnv" = Icon view, "Nlsv" = List view, "clmv" = Column View, "Flwv" = Gallery View The default is icnv.
        finder.FXRemoveOldTrashItems = false; # Remove items in the trash after 30 days. The default is false.
        finder.FXEnableExtensionChangeWarning = true; # Whether to show warnings when change the file extension of files. The default is true.
        finder.QuitMenuItem = false; # Whether to allow quitting of the Finder. The default is false.
        finder.ShowExternalHardDrivesOnDesktop = true; # Whether to show external disks on desktop. The default is true.
        finder.ShowHardDrivesOnDesktop = false; # Whether to show hard disks on desktop. The default is false.
        finder.ShowMountedServersOnDesktop = false; # Whether to show connected servers on desktop. The default is false.
        finder.ShowPathbar = true; # Show path breadcrumbs in finder windows. The default is false.
        finder.ShowRemovableMediaOnDesktop = true; # Whether to show removable media (CDs, DVDs and iPods) on desktop. The default is true.
        finder.ShowStatusBar = true; # Show status bar at bottom of finder windows with item/disk space stats. The default is false.
        # Activity Monitor
        ActivityMonitor.IconType = null; # Change the icon in the dock when running.
        ActivityMonitor.OpenMainWindow = true; # Open the main window when opening Activity Monitor. Default is true.
        ActivityMonitor.ShowCategory = 100; # Change which processes to show.
        ActivityMonitor.SortColumn = null; # Which column to sort the main activity page (such as "CPUUsage"). Default is null.
        ActivityMonitor.SortDirection = null; # The sort direction of the sort column (0 is decending). Default is null.
        # Control Center
        controlcenter.AirDrop = true; # Show a AirDrop control in menu bar. Default is null.
        controlcenter.BatteryShowPercentage = false; # Show a battery percentage in menu bar. Default is null.
        controlcenter.Bluetooth = false; # Show a bluetooth control in menu bar. Default is null.
        controlcenter.Display = true; # Show a Screen Brightness control in menu bar. Default is null.
        controlcenter.FocusModes = true; # Show a Focus control in menu bar. Default is null.
        controlcenter.NowPlaying = true; # Show a Now Playing control in menu bar. Default is null.
        controlcenter.Sound = true; # Show a sound control in menu bar . Default is null.
        # Dock
        dock.autohide = true;
        # Hitoolbox
        hitoolbox.AppleFnUsageType = "Show Emoji & Symbols"; # Chooses what happens when you press the Fn key on the keyboard. A restart is required for this setting to take effect. "Do Nothing", "Change Input Source", "Show Emoji & Symbols", "Start Dictation"
        # Loging Window
        loginwindow.GuestEnabled = false; # Allow users to login to the machine as guests using the Guest account. Default is true.
        loginwindow.LoginwindowText = "Álvaro Román"; # Text to be shown on the login window. Default is "\\U03bb".
        loginwindow.PowerOffDisabledWhileLoggedIn = false; # If set to true, the Power Off menu item will be disabled when the user is logged in. Default is false.
        loginwindow.RestartDisabled = false; # Hides the Restart button on the login screen. Default is false.
        loginwindow.RestartDisabledWhileLoggedIn = false; # Disables the “Restart” option when users are logged in. Default is false.
        loginwindow.SHOWFULLNAME = false; # Displays login window as a name and password field instead of a list of users. Default is false.
        loginwindow.ShutDownDisabled = false; # Hides the Shut Down button on the login screen. Default is false.
        loginwindow.ShutDownDisabledWhileLoggedIn = false; # Disables the "Shutdown" option when users are logged in. Default is false.
        loginwindow.SleepDisabled = false; # Hides the Sleep button on the login screen. Default is false.
        # Menu Extra Clock
        # TODO
        # NSGlobalDomain
        NSGlobalDomain.AppleInterfaceStyle = "Dark"; # Set to 'Dark' to enable dark mode, or leave unset for normal mode.
        NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false; # Whether to automatically switch between light and dark mode. The default is false.

        # Screen capture
        screencapture.disable-shadow = false;
        screencapture.include-date = true;
        screencapture.location = "/Users/alvaroroman/Screenshots";
        screencapture.show-thumbnail = true;
        screencapture.type = "png";
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
