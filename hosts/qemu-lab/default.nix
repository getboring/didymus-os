# hosts/qemu-lab/default.nix
# Same software as didymus-lab, no physical disks.
# Build: nix build .#qemu-vm
# Run:   ./result/bin/run-didymus-qemu-vm
# No real disk is touched.

{
  lib,
  modulesPath,
  ...
}:

{
  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  networking.hostName = lib.mkForce "didymus-qemu";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoFormat = true;
  };

  # Serial console: graphics = false, so this is how you log in without SSH keys.
  services.getty.autologinUser = "cody";

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 2;
      graphics = false;
      diskSize = 8192;
    };
  };
}
