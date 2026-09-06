{
  description = "Didymus OS — a twin of NixOS. Declarative, verifiable, boring on purpose.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # Uncomment for unstable when needed:
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Hardware support (optional, for real machines later)
    # nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Home Manager can be added later as a twin layer
    # home-manager.url = "github:nix-community/home-manager/release-24.11";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Shared Didymus modules
      didymusModules = [
        ./modules/didymus.nix
        ./modules/boring.nix
        ./modules/twin.nix
      ];
    in
    {
      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        name = "didymus-os";
        packages = with pkgs; [
          nixos-rebuild
          git
          jq
          age
          # later: didymus-cli
        ];
        shellHook = ''
          echo "Didymus OS development shell"
          echo "  Clever breaks. Boring lasts."
          echo "  Run: nix build .#nixosConfigurations.didymus-lab.config.system.build.toplevel"
        '';
      };

      # Example host configuration
      nixosConfigurations = {
        didymus-lab = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = didymusModules ++ [
            ./hosts/didymus-lab/configuration.nix
          ];
        };

        # Placeholder for future hosts
        # didymus-server = ...
        # didymus-desktop = ...
      };

      # ISO builder (skeleton — will produce a bootable twin ISO later)
      packages.${system}.iso = (nixpkgs.lib.nixosSystem {
        inherit system;
        modules = didymusModules ++ [
          ./iso/iso.nix
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
      }).config.system.build.isoImage;

      # Default package for convenience
      packages.${system}.default = self.nixosConfigurations.didymus-lab.config.system.build.toplevel;

      # Formatter
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
