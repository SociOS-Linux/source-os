{ pkgs ? import <nixpkgs> {} }:
pkgs.runCommand "stable-x86_64-contract" {
  nativeBuildInputs = [ pkgs.jq pkgs.gnugrep ];
} ''
  test -f ${../channels/stable.json}
  jq -e '.channel == "stable" and .capabilities["image-build"] == "0.1.0"' ${../channels/stable.json} >/dev/null
  grep -q 'channel = "stable"' ${../hosts/stable-x86_64/default.nix}
  grep -q 'role = "stable-x86_64"' ${../hosts/stable-x86_64/default.nix}
  mkdir -p $out
  echo validated > $out/result.txt
''
