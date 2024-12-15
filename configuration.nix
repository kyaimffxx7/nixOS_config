# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # home-manager
      # inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable IP forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  #  "net.ipv6.conf.all.forwarding" = 1
  };

  # AMDGPU setup
  ## move to hardware-configuration.nix
  # boot.initrd.kernelModules = [ "amdgpu" ];

  # Newest packages
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Wifi driver setup
  hardware.enableRedistributableFirmware = true;
  ## move to hardware-configuration.nix
  # boot.kernelModules = [ "rtw89" ];

  # Bluetooth setting
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Insecure Packages Setting
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
    "openssl-1.1.1w"
  ];


  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  
  # Add substituters from tsinghua mirror site
  # nix.settings.substituters = lib.mkForce [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  # nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  # Storage optimization
  nix.optimise.automatic = true;

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_HK.UTF-8";
  
  # Input method setup
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-configtool
      fcitx5-chinese-addons
      fcitx5-gtk
    ];
  };

  # Fonts setting
  fonts.enableDefaultPackages = true;
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
  
  # For AMDGPU
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable KDE plasma 6.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #############################
  ## Programs configurations ##
  #############################
  ## Zsh 
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -alh";
    };
    # ohMyZsh = {
    # enable = true;
    # plugins = [ "git" ];
    # theme = "wedisagree";
    # };
  };

  ###################################
  # Binary packages execution Setup #
  ###################################
  ## nix-ld
  programs.nix-ld.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hisoka = {
    isNormalUser = true;
    description = "hisoka";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "disk" "input" ]; # if enable docker, add "docker"
    packages = with pkgs; [
      firefox
    ];
  };

  # home-manager setup
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "hisoka" = import ./home.nix;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow Unsupported system
  nixpkgs.config.allowUnsupportedSystem = true;

  # Emacs requiremet
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball https://github.com/nix-community/emacs-overlay/archive/master.tar.gz))
  # ];

  ######################
  #   Virtualisation   #
  ######################
  # Docker setup
  # virtualisation.docker.enable = true;
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  # };

  # Virtual machine setup
  virtualisation.libvirtd = {
  	enable = true;
  	qemu = {
  	  package = pkgs.qemu_kvm;
  	  runAsRoot = true;
  	  swtpm.enable = true;
  	  ovmf = {
  	    enable = true;
  	    packages = [(pkgs.OVMF.override {
  	      secureBoot = true;
  	      tpmSupport = true;
  	    }).fd];
  	  };
  	};
  };
  programs.virt-manager.enable = true;

  
  # Flatpak
  services.flatpak.enable = true;
  # Emacs
  services.emacs.enable = true;
  # Dae
  services.dae.enable = true;
  services.dae.configFile = "/usr/local/dae/config.dae";

  #########################
  # Packages Installation #
  #########################
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ############################
    # Bianry Environment Start #
    ############################
    (buildFHSUserEnv {
      name = "fhs";
      targetPkgs = pkgs: with pkgs; [
        # Basic system libraries
        glibc
        gcc-unwrapped
        zlib
        glib

	# NSS libraries
	nss
	nspr

	# D-bus library
	dbus

	# ATK libraries
	at-spi2-atk
	atk

	# CUPS library
	cups

	# DRM library
	libdrm

	# GTK3 library
	gtk3

	# Audio libraries
        alsa-lib
        pulseaudio

	# Add Kerberos libraries
        krb5
        libkrb5

	# Qt and dependencies
        qt5.full
        qt5.qtwayland
        libsForQt5.qt5.qtbase
        libsForQt5.qt5.qtwayland

        # Common dependencies
        openssl
        libxml2
        libxslt
	expat
	libsecret
	libxkbcommon

        # Graphics libraries
        xorg.libX11
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXi
	xorg.libXcomposite
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXrender
        xorg.libXtst
	xorg.xcbutilwm
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        xorg.xcbutilrenderutil
        wayland
        
	mesa
	mesa.drivers
        libGL
	libGLU

	# XCB library
	xorg.libxcb

        # Additional libraries that are often needed
        ncurses5
        stdenv.cc.cc.lib
	pango
	cairo
	gdk-pixbuf

        # Add any other libraries your specific binary might need
      ];
      multiPkgs = pkgs: with pkgs; [
        # Packages that need to be available for both 32-bit and 64-bit
        zlib
	nss
	dbus
	at-spi2-atk
	atk
	cups
	libdrm
	gtk3
	xorg.libXcomposite
	xorg.libxcb
        alsa-lib
	krb5
	libkrb5
	qt5.full
        qt5.qtwayland
        libsForQt5.qt5.qtbase
        libsForQt5.qt5.qtwayland
        wayland
      ];
      profile = ''
        export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
          pkgs.qt5.full
          pkgs.qt5.qtwayland
          pkgs.libsForQt5.qt5.qtbase
          pkgs.libsForQt5.qt5.qtwayland
          pkgs.xorg.libxcb
          pkgs.xorg.xcbutilwm
          pkgs.xorg.xcbutilimage
          pkgs.xorg.xcbutilkeysyms
          pkgs.xorg.xcbutilrenderutil
          pkgs.wayland
          pkgs.libGL
          pkgs.libGLU
          pkgs.mesa
          pkgs.mesa.drivers
          pkgs.glibc
          pkgs.nss
          pkgs.nspr
          pkgs.dbus
          pkgs.at-spi2-atk
          pkgs.atk
          pkgs.cups
          pkgs.libdrm
          pkgs.gtk3
          pkgs.xorg.libX11
          pkgs.xorg.libXcursor
          pkgs.xorg.libXrandr
          pkgs.xorg.libXi
          pkgs.xorg.libXcomposite
          pkgs.xorg.libXdamage
          pkgs.xorg.libXext
          pkgs.xorg.libXfixes
          pkgs.xorg.libXrender
          pkgs.xorg.libXtst
          pkgs.mesa
          pkgs.libGL
          pkgs.alsa-lib
          pkgs.pulseaudio
          pkgs.ncurses5
          pkgs.stdenv.cc.cc.lib
          pkgs.pango
          pkgs.cairo
          pkgs.gdk-pixbuf
          pkgs.krb5
          pkgs.libkrb5
          pkgs.sqlite
          pkgs.expat
          pkgs.libsecret
          pkgs.libxkbcommon
	 # Add other necessary libraries here
        ]}:$LD_LIBRARY_PATH
	
	export QT_PLUGIN_PATH=${pkgs.qt5.qtbase.outPath}/lib/qt-${pkgs.qt5.qtbase.version}/plugins
        export QT_QPA_PLATFORM_PLUGIN_PATH=${pkgs.qt5.qtbase.outPath}/lib/qt-${pkgs.qt5.qtbase.version}/plugins/platforms
        export XDG_DATA_DIRS=$XDG_DATA_DIRS:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}
        export QT_QPA_PLATFORM=xcb
      '';
      runScript = "bash";
    })
    ##########################
    # Binary Environment End #
    ##########################

    # Remote
    termius

    ###########
    # Editors #
    ###########
    neovim
    # Emacs
    emacs
    ripgrep
    coreutils
    fd
    clang

    # Office
    libreoffice-still

    # Internet tools
    wget
    curl
    git
    dnsmasq
    ebtables

    # File tool
    kdePackages.filelight

    # Zsh plugins
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions

    # Compilers & Interpreter
    gcc
    gnumake
    nodejs_22

    # Tools
    neofetch
    libsForQt5.yakuake
    tree
    file
    nmap
    btop
    pciutils
    inxi
    autoPatchelfHook
    tmux

    # Video tools
    kdePackages.kdenlive
    shotcut
    obs-studio
    
    # Communications
    telegram-desktop
    discord

    # Notes
    obsidian

    # WiFi driver
    linuxKernel.packages.linux_5_15.rtw89

    # NixOS home-manager
    home-manager

    #####################################
    ## Binary packages executions Setup #
    #####################################
    # (let base = pkgs.appimageTools.defaultFhsEnvArgs; in
    #  pkgs.buildFHSUserEnv (base // {
    #  name = "fhs";
    #  targetPkgs = pkgs: (
        # pkgs.buildFHSUserEnv 只提供一个最小的 FHS 环境，缺少很多常用软件所必须的基础包
        # 所以直接使用它很可能会报错
        #
        # pkgs.appimageTools 提供了大多数程序常用的基础包，所以我们可以直接用它来补充
    #    (base.targetPkgs pkgs) ++ [
    #      pkgs.pkg-config
    #      pkgs.ncurses
    #      pkgs.fuse
          # 如果你的 FHS 程序还有其他依赖，把它们添加在这里
    #    ]
    #  );
    #  profile = "export FHS=1";
    #  runScript = "bash";
    #  extraOutputsToInstall = ["dev"];
    #}))
  ];

  environment.variables = {
  	
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
  system.stateVersion = "23.11"; # Did you read the comment?

}
