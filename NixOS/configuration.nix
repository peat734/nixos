# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, st, inputs, lib, ... }:

let
   nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
   export __NV_PRIME_RENDER_OFFLOAD=1
   export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
   export __GLX_VENDOR_LIBRARY_NAME=nvidia
   export __VK_LAYER_NV_optimus=NVIDIA_only
   exec -a "$0" "$@"
   '';
in



{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  networking.hostName = "asusg14"; # Define your hostname.
  networking.wireless.iwd.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend= "iwd";

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  #enable zsh
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  environment.binsh = "${pkgs.zsh}/bin/zsh";

  #add PATH
  environment.localBinInPath = true;

  # Enable the X11 windowing system.

  services.xserver.enable = true;
  services.xserver.displayManager.defaultSession = "none+bspwm";

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.windowManager.bspwm.configFile = "/home/peat/.config/bspwm/bspwmrc";
  services.xserver.windowManager.bspwm.sxhkd.configFile = "/home/peat/.config/sxhkd/sxkdrc";

  # Configure keymap in X11
  services.xserver = {
    layout = "pl,us";
    xkbModel = "asus_laptop";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  #bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.disableWhileTyping = true;

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";

    # Not officially in the specification
    XDG_BIN_HOME    = "$HOME/.local/bin";
    PATH = [ 
      "${XDG_BIN_HOME}"
      "/home/peat/.cargo/bin"
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.peat = {
    isNormalUser = true;
    description = "Nguyen Anh Do";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  services.flatpak.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.permittedInsecurePackages = [
                "openssl-1.1.1w"
              ];

 
  #auto update
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;



  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;
    prime = {
    	offload.enable = true;
    	amdgpuBusId = "PCI:4:0:0";
    	nvidiaBusId = "PCI:1:0:0";
    };
    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Do not disable this unless your GPU is unsupported or if you have a good reason to.
    open = true;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  #turn on latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neofetch
    neovim
    #discord
    spotify
    bspwm
    polybar
    picom
    dunst
    kitty
    rofi
    sxhkd
    zsh
    flameshot
    mpd
    ncmpcpp
    ranger
    git
    slock
    xfce.thunar	
    htop
    xfce.xfce4-power-manager
    zathura
    feh
    networkmanager
    gnumake
    gcc
    pulseaudio
    brightnessctl
    unzip
    slock
    obsidian
    steam
    gnome.gnome-disk-utility
    bat
    spotdl
    yt-dlp
    python3
    python310Packages.pillow
    papirus-icon-theme
    papirus-folders
    xfce.tumbler
    notion-app-enhanced
    vencord
    (pkgs.discord.override{
    withVencord = false;
    })
    xclip
    ripgrep
    lxappearance
    #pkgs.st
    (pkgs.st.overrideAttrs (oldAttrs: rec {
    src = fetchFromGitHub {
      owner = "siduck";
      repo = "st";
      rev = "b42b7a8a0970b0e4aec13699d005d7ca06791df0";
      sha256 = "iVIyj8Hp4Ed6FUrPHK1RMgCRPcI2alRFi9xdficYPGQ=";
    };
    #Make sure you include whatever dependencies the fork needs to build properly!
    buildInputs = oldAttrs.buildInputs ++ [ harfbuzz pkg-config xorg.libX11 xorg.libXft fontconfig gd glib ];
    configFile = writeText "config.def.h" (builtins.readFile /home/peat/.config/st/st-config.h);
    postPatch = "${oldAttrs.postPatch}\n cp ${configFile} config.def.h";
    }))
    p7zip
    libreoffice
    ueberzugpp
    cbonsai
    gtk4
    sassc
    gnome.nautilus
    pfetch
    go-sct
    wiki-tui
    spotify-tui
    spotifyd
    jq
    bc
    nvidia-offload
    minecraft
    killall
    eww
    cargo
    rustup
    cargo-auditable-cargo-wrapper
    whatsapp-for-linux
    gnome.gnome-tweaks  
    flatpak
    gnome.gnome-software
    vscodium
    clang
    keepassxc
    imagemagick
    krita
    chromium
    btop
    pomodoro
    nodejs_21
    tree
    latte-dock
    cmake
    libsForQt5.applet-window-appmenu
    qalculate-gtk
    nicotine-plus
    libsForQt5.kdeconnect-kde
    viewnior
    playerctl
    hsetroot
    maim
    jq
    imagemagick
    i3lock-color
    xdo
    giph
    redshift
    jgmenu
    yarn-berry
    bunnyfetch
    mommy
    j4-dmenu-desktop
    ani-cli
    melonDS
];

  programs.slock.enable = true;
    programs.xss-lock = {
    enable = true;
    lockerCommand = "/run/wrappers/bin/slock";
  };
  security.wrappers.slock.source = "${pkgs.slock.out}/bin/slock";
  #enabling kdeconnect
  programs.kdeconnect.enable = true; 
  
 programs.steam = {
   enable = true;
   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
 };



  #fonts
  fonts = {
  	fonts = with pkgs; [
    	  maple-mono-SC-NF
	  maple-mono
	  terminus_font
	  victor-mono
	  dm-sans
	  material-icons
  	];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  #asusctl shit
  services.supergfxd.enable = true;
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
};

}
