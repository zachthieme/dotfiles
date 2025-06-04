# Linux (x86_64) architecture specific configuration
{ pkgs, lib, ... }:

{
  # Set platform for Linux
  nixpkgs.hostPlatform = "x86_64-linux";

  # Linux-specific packages
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
  ];

  # No homebrew on Linux
  homebrew.enable = lib.mkForce false;
