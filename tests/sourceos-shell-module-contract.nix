{ pkgs ? import <nixpkgs> {} }:
pkgs.runCommand "sourceos-shell-module-contract" {
  nativeBuildInputs = [ pkgs.gnugrep ];
} ''
  test -f ${../modules/nixos/sourceos-shell/default.nix}
  test -f ${../profiles/linux-dev/sourceos-shell.nix}
  test -f ${../linux/desktop/sourceos-shell.desktop}
  test -f ${../linux/desktop/sourceos-search-provider.conf}
  test -f ${../linux/systemd/sourceos-shell.service}
  test -f ${../linux/systemd/sourceos-router.service}
  test -f ${../linux/systemd/sourceos-pdf-secure.service}
  test -f ${../linux/systemd/sourceos-docd.service}
  grep -q '../../modules/nixos/sourceos-shell/default.nix' ${../profiles/linux-dev/sourceos-shell.nix}
  grep -q 'sourceos.shell' ${../modules/nixos/sourceos-shell/default.nix}
  grep -q 'sourceos-docd' ${../modules/nixos/sourceos-shell/default.nix}
  grep -q 'searchProvider' ${../modules/nixos/sourceos-shell/default.nix}
  grep -q 'no_redundant_file_search' ${../linux/desktop/sourceos-search-provider.conf}
  mkdir -p $out
  echo validated > $out/result.txt
''
