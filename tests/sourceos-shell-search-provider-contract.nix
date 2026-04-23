{ pkgs ? import <nixpkgs> {} }:
pkgs.runCommand "sourceos-shell-search-provider-contract" {
  nativeBuildInputs = [ pkgs.gnugrep ];
} ''
  test -f ${../linux/desktop/sourceos-search-provider.conf}
  grep -q 'mode=launcher-bridge' ${../linux/desktop/sourceos-search-provider.conf}
  grep -q 'linux-file-provider=tracker3' ${../linux/desktop/sourceos-search-provider.conf}
  grep -q 'invariant=no_redundant_file_search' ${../linux/desktop/sourceos-search-provider.conf}
  grep -q 'apps=launcher' ${../linux/desktop/sourceos-search-provider.conf}
  grep -q 'files=linux-native-only' ${../linux/desktop/sourceos-search-provider.conf}
  grep -q 'web=browser-agent' ${../linux/desktop/sourceos-search-provider.conf}
  grep -q 'search-provider.json' ${../modules/nixos/sourceos-shell/default.nix}
  grep -q 'no_redundant_file_search' ${../modules/nixos/sourceos-shell/default.nix}
  mkdir -p $out
  echo validated > $out/result.txt
''
