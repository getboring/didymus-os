# iso/iso.nix
# Minimal Didymus OS installation ISO configuration

{ config, pkgs, ... }:

{
  didymus = {
    enable = true;
    version = "0.1.0-scaffold";
    hostname = "didymus-iso";
    twinMode = "stable-experimental";
    tiredTest = true;
  };

  isoImage = {
    volumeID = "DIDYMUS_OS";
    isoName = "didymus-os-${config.didymus.version}-${pkgs.stdenv.hostPlatform.system}.iso";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  services.getty.autologinUser = "nixos";
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  system.stateVersion = "26.05";

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
