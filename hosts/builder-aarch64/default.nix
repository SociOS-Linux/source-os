{ config, lib, pkgs, ... }:
{
  imports = [
    ../../profiles/linux-dev/default.nix
    # hardware-configuration.nix is device-specific.
    # After Asahi install, run `nixos-generate-config` on the device and
    # place the result at /etc/nixos/hardware-configuration.nix, or pass
    # it via `--impure` with a local path override.
  ];

  networking.hostName = "builder-aarch64";

  sourceos.build = {
    role = "builder-aarch64";
    channel = "dev";
  };

  # Apple Silicon hardware support (module wired in via flake.nix
  # nixosConfigurations.builder-aarch64 modules list).
  hardware.asahi = {
    enable = true;
    setupAsahiSound = true;
    experimentalGpuAcceleration = true;
  };

  # Boot via systemd-boot: Asahi installer places m1n1 + U-Boot which
  # expose an EFI stub. NixOS picks it up via systemd-boot.
  # canTouchEfiVariables = false is mandatory — modifying EFI vars on
  # Apple Silicon can prevent booting macOS.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # Flakes required for sourceos-syncd and prophet CLI
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Trusted substituters for the SourceOS binary cache (populated by Katello
  # after the content view is published)
  nix.settings.trusted-substituters = [
    "https://cache.nixos.org"
    "http://127.0.0.1:8101"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];

  users.users.sourceos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
    # Set password post-install via `passwd sourceos` — never commit credentials
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
