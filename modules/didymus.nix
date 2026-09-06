# modules/didymus.nix
# Core Didymus OS options and identity

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.didymus;
in
{
  options.didymus = {
    enable = mkEnableOption "Didymus OS core" // {
      default = true;
      description = "Enable the Didymus twin layer on top of NixOS";
    };

    version = mkOption {
      type = types.str;
      default = "0.1.0-scaffold";
      description = "Didymus OS release version";
    };

    hostname = mkOption {
      type = types.str;
      default = "didymus";
      description = "Default hostname for Didymus machines";
    };

    twinMode = mkOption {
      type = types.enum [ "stable-experimental" "primary-mirror" "disabled" ];
      default = "stable-experimental";
      description = ''
        How the twin system behaves:
        - stable-experimental: keep a stable twin + an experimental twin
        - primary-mirror: every generation has a verified mirror
        - disabled: plain NixOS generations only
      '';
    };

    tiredTest = mkOption {
      type = types.bool;
      default = true;
      description = "Enforce Tired Test friendly defaults (simple naming, clear recovery paths)";
    };
  };

  config = mkIf cfg.enable {
    # Identity
    networking.hostName = mkDefault cfg.hostname;
    system.nixos.label = "didymus-${cfg.version}";

    # Make Didymus visible
    environment.etc."didymus/version".text = cfg.version;
    environment.etc."didymus/README".text = ''
      Didymus OS ${cfg.version}
      Twin of NixOS. Clever breaks. Boring lasts.
      See: /etc/didymus/ and the didymus CLI (coming soon).
    '';

    # Basic packages that always make sense
    environment.systemPackages = with pkgs; [
      git
      jq
      curl
      htop
      tree
      # twin tools will live here later
    ];

    # Nix settings that favor reproducibility and clarity
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      # Keep more generations so the twin has room to breathe
      # (actual twin logic is in twin.nix)
    };

    # Documentation that a tired person can find
    documentation.nixos.enable = true;
    documentation.man.enable = true;
  };
}
