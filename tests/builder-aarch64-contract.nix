{ pkgs ? import <nixpkgs> {} }:
pkgs.runCommand "builder-aarch64-contract" {
  nativeBuildInputs = [ pkgs.jq pkgs.gnugrep ];
} ''
  test -f ${../channels/dev.json}
  jq -e '.channel == "dev" and .capabilities["image-build"] == "0.1.0"' ${../channels/dev.json} >/dev/null
  grep -q 'channel = "dev"' ${../hosts/builder-aarch64/default.nix}
  grep -q 'role = "builder-aarch64"' ${../hosts/builder-aarch64/default.nix}
  mkdir -p $out
  echo validated > $out/result.txt
''
