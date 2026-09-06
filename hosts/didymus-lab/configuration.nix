# hosts/didymus-lab/configuration.nix
# Example Didymus OS host — the lab twin

{ config, lib, pkgs, ... }:

{
  imports = [
    # hardware-configuration.nix would go here on a real machine
    # ./hardware-configuration.nix
  ];

  # Didymus core (already imported via flake, but we can override)
  didymus = {
    enable = true;
    version = "0.1.0-scaffold";
    hostname = "didymus-lab";
    twinMode = "stable-experimental";
    tiredTest = true;
  };

  # Bootloader (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Filesystem placeholder — replace with real hardware-config
  fileSystems."/" = {
    device = "/dev/disk/by-label/didymus-root";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/didymus-boot";
    fsType = "vfat";
  };

  # User for the lab (declarative)
  users.users.cody = {
    isNormalUser = true;
    description = "Cody Boring";
    extraGroups = [ "wheel" "networkmanager" ];
    # Add your SSH key here:
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... cody@didymus" ];
    initialPassword = "didymus";  # CHANGE ME immediately — only for first boot scaffolding
  };

  # Lab-friendly packages
  environment.systemPackages = with pkgs; [
    vim
    tmux
    ripgrep
    fd
    bat
  ];

  # Allow unfree if needed later (keep default false for boring purity)
  nixpkgs.config.allowUnfree = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "24.11";
}
