# System configuration for QEMU/KVM hypervisor using a realtime kernel.

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the gummiboot efi boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [ "intel_iommu=on" ];
  boot.kernelModules = [ "vfio-pci" ];
  boot.kernelPackages = pkgs.linuxPackages_custom {
    version = "4.1.12-rt13";
    configfile = ./kernel.config;
    src = pkgs.fetchurl {
      url = "http://sar.audio/linux-4.1.12-rt13.tar.xz";
      sha256 = "1nhp1w84hcd9p35if84nmksvbby5gi5xwcl4nwdswi7x79wa19br";
    };
  };

  networking.hostName = "cast-hv"; # Define your hostname.

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget vim qemu tmux unzip links2 git
    usbutils bridge-utils tunctl linuxPackages.perf dwm dmenu
    chromium 
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 5900 25565 ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.xserver = {
    enable = true;
    videoDrivers = [ "intel" ];
    desktopManager.xterm.enable = false;
    desktopManager.default = "none";
  };

  users.extraUsers.eiz = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";
}
