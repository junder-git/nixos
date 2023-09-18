{ config, pkgs, ... }:

{ 
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        };
      };
    plymouth = {
      enable = true;
      extraConfig = "DeviceScale=2";
      };
    initrd = {
      kernelModules          = [ "nvme" "ahci" ];
      network                = {
        enable = true;
      };
      systemd = {
        enable   = true;
      };
    };
    blacklistedKernelModules = [ "nouveau" "i915" ];
    kernelParams = [ "quiet" "nomodeset" ];
  };
  imports =
    [
      ./hardware-configuration.nix
    ];
  networking.extraHosts = let hostsPath = https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts;
  hostsFile = builtins.fetchurl hostsPath;
  in builtins.readFile "${hostsFile}";
  networking.hostName = "jtower";
  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
  # Set your time zone.
  time.timeZone = "Europe/London";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
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
  services = {
    dleyna-renderer.enable = false;
    dleyna-server.enable = false;
    power-profiles-daemon.enable = false;
    telepathy.enable = false;
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa   = {
        enable       = true;
        support32Bit = true;
      };
      pulse  = { enable = true; };
    };    
    xserver = {
      enable               = true;
      videoDrivers = [ "nvidia" ];
      layout = "gb";
      xkbVariant = "";
      desktopManager.gnome = { enable = true; };
      displayManager       = {
        autoLogin  = { enable = true; user = "j"; };
        gdm.enable = true;
        };
      };
    };
  # Configure console keymap
  console = {
    earlySetup = true;
    keyMap = "uk";
  };
  # Enable sound with pipewire.
  sound.enable = true;
  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable   = false;
    cpu.intel          = { updateMicrocode = true; };
    keyboard.uhk       = { enable = true; };
    opengl             = {
      driSupport      = true;
      driSupport32Bit = true;
      enable          = true;
      extraPackages   = with pkgs; [ libvdpau-va-gl vaapiIntel vaapiVdpau nvidia-vaapi-driver intel-media-driver ];
    };
    nvidia             = {
      modesetting.enable = true;
      nvidiaSettings  = true;
      powerManagement = {
        enable      = false;
        finegrained = false;
      };
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    pulseaudio         = { enable = false; };
  };
  security.rtkit.enable = true;
  users.users.j = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
    ];
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
     wget
     # Work around #159267
     (pkgs.writeShellApplication {
       name = "discord";
       text = "${pkgs.discord}/bin/discord --use-gl=desktop";
     })
     (pkgs.makeDesktopItem {
       name = "discord";
       exec = "discord";
       desktopName = "Discord";
     })
     solaar
     file
     unzip
     wl-clipboard
     pciutils
     usbutils
     wol
     lutris
     wineWowPackages.staging
     wineWowPackages.waylandFull
     winetricks
     git
  ];
  powerManagement.cpuFreqGovernor = "ondemand";
  programs = {
    nix-ld.enable = true; # https://unix.stackexchange.com/a/522823
    steam = {
      enable     = true;
      remotePlay = { openFirewall = true; };
    };
  };
  system.stateVersion = "23.05";
  systemd.services = {
    # https://github.com/NixOS/nixpkgs/issues/103746
    "getty@tty1".enable  = false;
    "autovt@tty1".enable = false;
  };
}