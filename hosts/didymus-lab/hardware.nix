# hosts/didymus-lab/hardware.nix
# Physical disks for didymus-lab. Do not import this into QEMU or nixosTest.

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/didymus-root";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/didymus-boot";
    fsType = "vfat";
  };
}
