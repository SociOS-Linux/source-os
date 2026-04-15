{ pkgs ? import <nixpkgs> {} }:
pkgs.runCommand "canary-x86_64-smoke" {} ''
  mkdir -p $out
  cat > $out/result.txt <<EOF
source-os canary-x86_64 smoke placeholder
EOF
''
