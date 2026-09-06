# modules/twin.nix
# The twin generation + receipt system (v0.1 scaffold)

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.didymus;
  twinCfg = config.didymus.twin;
in
{
  options.didymus.twin = {
    enable = mkOption {
      type = types.bool;
      default = cfg.twinMode != "disabled";
      description = "Enable twin generation management";
    };

    keepGenerations = mkOption {
      type = types.int;
      default = 8;
      description = "How many generations to keep (enough for stable + experimental twins)";
    };

    receiptDir = mkOption {
      type = types.str;
      default = "/var/lib/didymus/receipts";
      description = "Where twin receipts live";
    };

    # Future: signing key, ScopeBlind integration, etc.
  };

  config = mkIf (cfg.enable && twinCfg.enable) {

    # Keep more generations so twins have room
    boot.loader.systemd-boot.configurationLimit = mkDefault twinCfg.keepGenerations;
    boot.loader.grub.configurationLimit = mkDefault twinCfg.keepGenerations;

    # Create the receipt directory structure
    systemd.tmpfiles.rules = [
      "d ${twinCfg.receiptDir} 0750 root root -"
      "d /var/lib/didymus 0750 root root -"
      "d /var/lib/didymus/twins 0750 root root -"
    ];

    # Placeholder twin service (will become real later)
    systemd.services.didymus-twin-init = {
      description = "Didymus twin system initialization";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writeShellScript "didymus-twin-init" ''
          set -euo pipefail
          echo "Didymus twin layer active (mode: ${cfg.twinMode})"
          mkdir -p ${twinCfg.receiptDir}
          if [ ! -f ${twinCfg.receiptDir}/.initialized ]; then
            cat > ${twinCfg.receiptDir}/.initialized <<INNER
Didymus twin receipts directory initialized
Mode: ${cfg.twinMode}
Version: ${cfg.version}
INNER
            echo "Twin receipts ready at ${twinCfg.receiptDir}"
          fi
        ''}";
      };
    };

    # Document the twin concept
    environment.etc."didymus/TWIN.md".text = ''
      # Didymus Twin System (v0.1)

      Mode: ${cfg.twinMode}

      ## Stable twin / Experimental twin
      - The **stable twin** is the last known-good generation you marked as stable.
      - The **experimental twin** is the current working generation.
      - You can always boot either from the bootloader menu.

      ## Receipts
      Every successful switch that is twin-aware will leave a receipt in:
        ${twinCfg.receiptDir}

      Receipts will eventually be:
      - content-addressed
      - Ed25519 signed (ScopeBlind-compatible)
      - human-readable + machine-verifiable

      ## Commands (coming)
        didymus switch      # rebuild + twin update
        didymus twin        # show / promote / demote twins
        didymus receipts    # list / verify / show
        didymus verify      # check current system against last receipt

      For now use standard nixos-rebuild; the twin layer is scaffolding only.
    '';

    # Future CLI will live here
    # environment.systemPackages = [ pkgs.didymus-cli ];
  };
}
