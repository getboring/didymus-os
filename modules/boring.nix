# modules/boring.nix
# Tired Test defaults — things that still make sense at 2 a.m.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.didymus;
in
{
  config = mkIf (cfg.enable && cfg.tiredTest) {

    # Keep boot simple and recoverable
    boot.loader.timeout = mkDefault 5;
    boot.tmp.cleanOnBoot = true;

    # Clear, boring networking defaults
    networking.useDHCP = mkDefault true;
    networking.firewall.enable = mkDefault true;
    networking.firewall.allowPing = true;

    # Time & locale that don't surprise anyone
    time.timeZone = mkDefault "America/New_York";  # Cody is in TN; override per host
    i18n.defaultLocale = mkDefault "en_US.UTF-8";

    # Users: make root usable but not reckless
    users.mutableUsers = mkDefault false;  # declarative users only (tired-test friendly)
    # (hosts still define actual users)

    # Services that are quiet and reliable
    services.openssh = {
      enable = mkDefault true;
      settings = {
        PasswordAuthentication = mkDefault false;
        PermitRootLogin = mkDefault "prohibit-password";
        KbdInteractiveAuthentication = false;
      };
    };

    # Journal and logs that don't fill the disk while still being useful
    services.journald.extraConfig = ''
      SystemMaxUse=500M
      MaxRetentionSec=1month
    '';

    # Security baseline that is boring and effective
    security.sudo.wheelNeedsPassword = true;
    security.polkit.enable = true;

    # Make recovery obvious
    environment.etc."didymus/TIRED-TEST.md".text = ''
      # Tired Test checklist for this machine

      1. Can I boot into the previous generation from the boot menu?
      2. Is there a twin generation I can switch to?
      3. Where are the receipts?  →  /var/lib/didymus/receipts/
      4. Is SSH reachable with my key?
      5. Does `didymus status` (or `nixos-rebuild list-generations`) tell me the truth?

      If the answer to any of these is "I don't know", the configuration failed the Tired Test.
    '';

    # Helpful aliases that reduce cognitive load
    environment.shellAliases = {
      nrb = "sudo nixos-rebuild switch --flake .#";
      nrt = "sudo nixos-rebuild test --flake .#";
      nrl = "sudo nixos-rebuild list-generations";
      didymus-status = "cat /etc/didymus/version && nixos-rebuild list-generations";
    };
  };
}
