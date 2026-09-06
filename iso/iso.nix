# iso/iso.nix
# Minimal Didymus OS installation ISO configuration

{ config, lib, pkgs, ... }:

{
  # Inherit Didymus identity
  didymus = {
    enable = true;
    version = "0.1.0-scaffold";
    hostname = "didymus-iso";
    twinMode = "stable-experimental";
    tiredTest = true;
  };

  # ISO-specific
  isoImage = {
    volumeID = "DIDYMUS_OS";
    isoName = "didymus-os-${config.didymus.version}-${pkgs.stdenv.hostPlatform.system}.iso";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  # Comfortable live environment
  services.getty.autologinUser = "nixos";  # or a didymus user later
  environment.systemPackages = with pkgs; [
    vim
    git
    # didymus installer helpers will go here
  ];

  # Message of the day
  environment.etc."motd".text = ''

    ██████╗ ██╗██████╗ ██╗   ██╗███╗   ███╗██╗   ██╗███████╗
    ██╔══██╗██║██╔══██╗╚██╗ ██╔╝████╗ ████║██║   ██║██╔════╝
    ██║  ██║██║██║  ██║ ╚████╔╝ ██╔████╔██║██║   ██║███████╗
    ██║  ██║██║██║  ██║  ╚██╔╝  ██║╚██╔╝██║██║   ██║╚════██║
    ██████╔╝██║██████╔╝   ██║   ██║ ╚═╝ ██║╚██████╔╝███████║
    ╚═════╝ ╚═╝╚═════╝    ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚══════╝

    Didymus OS — a twin of NixOS
    Clever breaks. Boring lasts.

    This is a live ISO. Install with the usual NixOS methods or the
    (coming) didymus-install helper.

  '';
}
