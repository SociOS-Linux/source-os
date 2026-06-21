# SourceOS GNOME desktop profile — the clean end-user target installed from the
# public ISO. Deliberately does NOT pull in the server machinery (sourceos-syncd,
# Katello, sops, mesh): a fresh install must boot with zero enrollment.
#
# The imperative GNOME "polish" layer (profiles/linux-dev/workstation-v0) can be
# applied on top after first boot via its apply.sh; it is not required to boot.
{ lib, pkgs, ... }:
let
  release = "26.11";
in
{
  # ── Desktop ───────────────────────────────────────────────────────────────
  services.xserver.enable = true;            # X/Xwayland + keymap plumbing
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb.layout = "us";

  # Audio (PipeWire) + printing — expected on a desktop.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.printing.enable = true;

  # ── Networking ──────────────────────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ── Default user ──────────────────────────────────────────────────────────────
  # Password is set interactively during install (install-image.sh runs passwd),
  # so no password is baked into the image.
  users.users.sourceos = {
    isNormalUser = true;
    description = "SourceOS";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };
  # Wheel may sudo; lock down later if desired.
  security.sudo.wheelNeedsPassword = lib.mkDefault true;

  # ── Base apps + Nix UX ─────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    firefox git curl vim gnome-tweaks
  ];

  # GNOME pulls a lot of default apps; trim the most universally unwanted.
  environment.gnome.excludePackages = with pkgs; [ gnome-tour epiphany geary ];

  # ── Boot (generic UEFI; Apple Silicon uses its own module, not this profile) ──
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  time.timeZone = lib.mkDefault "UTC";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  system.stateVersion = release;
}
