{ pkgs ? import <nixpkgs> {} }:
pkgs.runCommand "canary-x86_64-contract" {
  nativeBuildInputs = [ pkgs.jq pkgs.gnugrep ];
} ''
  test -f ${../channels/candidate.json}
  jq -e '.channel == "candidate" and .capabilities["image-build"] == "0.1.0"' ${../channels/candidate.json} >/dev/null
  grep -q 'channel = "candidate"' ${../hosts/canary-x86_64/default.nix}
  grep -q 'role = "canary-x86_64"' ${../hosts/canary-x86_64/default.nix}
  mkdir -p $out
  echo validated > $out/result.txt
''
