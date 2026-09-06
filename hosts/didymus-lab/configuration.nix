# hosts/didymus-lab/configuration.nix
# Software config for the lab twin. Hardware is in hardware.nix (physical)
# or hosts/qemu-lab (VM). Keep this file bootable in either place.

{ pkgs, ... }:

{
  didymus = {
    enable = true;
    version = "0.1.0-scaffold";
    hostname = "didymus-lab";
    twinMode = "stable-experimental";
    tiredTest = true;
  };

  # Declarative lab user. Replace the password with an SSH key before any
  # network-facing install. PasswordAuthentication is already off.
  users.users.cody = {
    isNormalUser = true;
    description = "Cody Boring";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... cody@didymus" ];
    initialPassword = "didymus"; # CHANGE ME — scaffolding only
  };

  environment.systemPackages = with pkgs; [
    vim
    tmux
    ripgrep
    fd
    bat
  ];

  nixpkgs.config.allowUnfree = false;

  # First-install state version. Bump only on a real machine that already ran
  # 24.11; this tree has never been installed.
  system.stateVersion = "26.05";
}
