{
  description = "Didymus OS — a twin of NixOS. Declarative, verifiable, boring on purpose.";

  inputs = {
    # Current stable. 24.11 is EOL; this matches getboring/boring-agent-appliance.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Shared Didymus modules. Hardware stays on the host, not here.
      didymusModules = [
        ./modules/didymus.nix
        ./modules/boring.nix
        ./modules/twin.nix
      ];

      mkHost =
        extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = didymusModules ++ extraModules;
        };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "didymus-os";
        packages = with pkgs; [
          nixos-rebuild
          git
          jq
          age
        ];
        shellHook = ''
          echo "Didymus OS development shell"
          echo "  Clever breaks. Boring lasts."
          echo "  Eval:  nix eval .#nixosConfigurations.qemu-lab.config.system.build.toplevel.drvPath"
          echo "  Test:  nix build .#checks.x86_64-linux.didymus-lab -L"
          echo "  VM:    nix build .#qemu-vm && ./result/bin/run-didymus-qemu-vm"
        '';
      };

      nixosConfigurations = {
        # Physical lab host — needs labelled disks. Not for QEMU.
        didymus-lab = mkHost [
          ./hosts/didymus-lab/configuration.nix
          ./hosts/didymus-lab/hardware.nix
        ];

        # Same software, no physical disks. This is the cloud / laptop path.
        qemu-lab = mkHost [
          ./hosts/didymus-lab/configuration.nix
          ./hosts/qemu-lab/default.nix
        ];
      };

      packages.${system} = {
        default = self.nixosConfigurations.didymus-lab.config.system.build.toplevel;
        qemu-vm = self.nixosConfigurations.qemu-lab.config.system.build.vm;
        # ISO is opt-in: large, and not part of `nix flake check`.
        iso =
          (mkHost [
            ./iso/iso.nix
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ]).config.system.build.isoImage;
      };

      # Boots a VM and asserts the twin layer. Needs /dev/kvm.
      checks.${system}.didymus-lab = pkgs.testers.runNixOSTest {
        name = "didymus-lab";

        nodes.machine =
          { ... }:
          {
            imports = didymusModules ++ [ ./hosts/didymus-lab/configuration.nix ];
            virtualisation = {
              memorySize = 2048;
              cores = 2;
            };
          };

        testScript = ''
          machine.wait_for_unit("multi-user.target")
          machine.wait_for_unit("didymus-twin-init.service")
          machine.wait_for_unit("sshd.service")

          with subtest("identity is Didymus, not a nameless NixOS"):
              version = machine.succeed("cat /etc/didymus/version").strip()
              assert version == "0.1.0-scaffold", version
              hostname = machine.succeed("hostname").strip()
              assert hostname == "didymus-lab", hostname
              machine.succeed("test -f /etc/didymus/README")
              machine.succeed("test -f /etc/didymus/TWIN.md")
              machine.succeed("test -f /etc/didymus/TIRED-TEST.md")

          with subtest("the twin receipt directory was initialized"):
              machine.succeed("test -d /var/lib/didymus/receipts")
              machine.succeed("test -f /var/lib/didymus/receipts/.initialized")
              init = machine.succeed("cat /var/lib/didymus/receipts/.initialized")
              assert "stable-experimental" in init, init

          with subtest("twin init stays up after a oneshot"):
              machine.succeed("systemctl is-active didymus-twin-init.service")
        '';
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
