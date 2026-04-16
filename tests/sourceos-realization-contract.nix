{ pkgs ? import <nixpkgs> {} }:
let
  builder = import ../hosts/builder-aarch64/default.nix {};
  canary = import ../hosts/canary-x86_64/default.nix {};
  stable = import ../hosts/stable-x86_64/default.nix {};
in pkgs.runCommand "sourceos-realization-contract" {
  nativeBuildInputs = [ pkgs.jq ];
} ''
  test "${builder.networking.hostName}" = "builder-aarch64"
  test "${builder.sourceos.build.role}" = "builder-aarch64"
  test "${builder.sourceos.build.channel}" = "dev"

  test "${canary.networking.hostName}" = "canary-x86_64"
  test "${canary.sourceos.build.role}" = "canary-x86_64"
  test "${canary.sourceos.build.channel}" = "candidate"

  test "${stable.networking.hostName}" = "stable-x86_64"
  test "${stable.sourceos.build.role}" = "stable-x86_64"
  test "${stable.sourceos.build.channel}" = "stable"

  jq -e '.channel == "dev"' ${../channels/dev.json} >/dev/null
  jq -e '.channel == "candidate"' ${../channels/candidate.json} >/dev/null
  jq -e '.channel == "stable"' ${../channels/stable.json} >/dev/null

  mkdir -p $out
  echo validated > $out/result.txt
''
