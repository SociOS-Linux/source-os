{
  description = "SourceOS Linux realization root";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f system);
    in {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [ git jq nixpkgs-fmt ];
            shellHook = ''
              echo "SourceOS Linux development shell"
              echo "See docs/repository-layout.md and docs/agentplane-integration.md"
            '';
          };
        });

      sourceos = {
        channels = [ "dev" "candidate" "stable" ];
        notes = "This flake is the Linux realization root. Control-plane semantics live in SocioProphet/agentplane and shared channel/capability schemas live in SocioProphet/socioprophet-agent-standards.";
      };
    };
}
