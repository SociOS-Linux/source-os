{ pkgs ? import <nixpkgs> {} }:
pkgs.runCommand "builder-aarch64-smoke" {} ''
  mkdir -p $out
  cat > $out/result.txt <<EOF
source-os builder-aarch64 smoke placeholder
EOF
''
