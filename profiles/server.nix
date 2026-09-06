# profiles/server.nix — minimal durable server profile
{ config, lib, pkgs, ... }:
{
  # No GUI
  services.xserver.enable = false;

  # Lean
  environment.systemPackages = with pkgs; [
    neovim
    tmux
    htop
    iotop
    nethogs
  ];

  # Headless friendly
  console.enable = true;
}
