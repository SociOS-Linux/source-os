{ pkgs ? import <nixpkgs> {} }:
pkgs.runCommand "sourceos-shell-keyboard-module-contract" {
  nativeBuildInputs = [ pkgs.gnugrep ];
} ''
  grep -q 'keyboard = {' ${../modules/nixos/sourceos-shell/default.nix}
  grep -q 'mode = lib.mkOption' ${../modules/nixos/sourceos-shell/default.nix}
  grep -q 'platformModel = lib.mkOption' ${../modules/nixos/sourceos-shell/default.nix}
  grep -q 'terminalModel = lib.mkOption' ${../modules/nixos/sourceos-shell/default.nix}
  grep -q 'keyboard-equivalence.json' ${../modules/nixos/sourceos-shell/default.nix}
  grep -q 'gui_terminal_split_explicit' ${../modules/nixos/sourceos-shell/default.nix}
  mkdir -p $out
  echo validated > $out/result.txt
''
