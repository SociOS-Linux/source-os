{ pkgs ? import <nixpkgs> {} }:
pkgs.runCommand "stable-x86_64-smoke" {} ''
  mkdir -p $out
  cat > $out/result.txt <<EOF
source-os stable-x86_64 smoke placeholder
EOF
''
