{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
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
      extraConfig = "DeviceScale=1";
    };
    initrd = {
      kernelModules = [ "nvme" "ahci" ];
      network.enable = true;
      systemd.enable   = true;
    };
    blacklistedKernelModules = [ "nouveau" "i915" ];
    kernelParams = [ "quiet" "nomodeset" ];
  };
  security.rtkit.enable = true;
  console = { earlySetup = true; keyMap = "uk"; };
  networking.extraHosts = let hostsPath = https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts;
  hostsFile = builtins.fetchurl hostsPath;
  in builtins.readFile "${hostsFile}";
  networking.hostName = "jtower";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; #Discord in wayland
  };
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
      forceFullCompositionPipeline = true; #=>pop os has forceCompositionPipeline no "full"
      nvidiaSettings  = true;
      powerManagement = {
        enable      = true;
        finegrained = false;
      };
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    pulseaudio.enable = false;
  };
  services.openssh.enable = true;
  services.xserver = {
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
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  users.users.j = { # Define a user account. Don't forget to set a password with ‘passwd’ from nixos-enter.
    isNormalUser = true;
    description = "j";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  nixpkgs.config.allowUnfree = true;
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
  # Base
    networkmanager iwd libnotify xwayland wayland
    pciutils usbutils wget file unzip 
    wl-clipboard wol wmctrl solaar
  # Development
    tmux sshpass git
    (python3.withPackages(ps: with ps; [       
      tk tkinter pandas requests numpy
      pendulum pillow moviepy pyqt5 pyqt6
      pytest #briefcase
      ]))
     (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
      bbenoist.nix
      ms-python.python
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "remote-ssh-edit";
        publisher = "ms-vscode-remote";
        version = "0.47.2";
        sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      }];})
    ## Beeware dependencies
    build-essential pkg-config python3-dev python3-venv libgirepository1.0-dev libcairo2-dev gir1.2-webkit2-4.0 libcanberra-gtk3-module
  # Gaming
    lutris firefox-wayland discord wineWowPackages.staging wineWowPackages.waylandFull
    winetricks
  ];
   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };
  system.stateVersion = "23.05"; # Did you read the comment?
  systemd.services = {
    # https://github.com/NixOS/nixpkgs/issues/103746
    "getty@tty1".enable  = false;
    "autovt@tty1".enable = false;
  };
  powerManagement.cpuFreqGovernor = "ondemand";
}