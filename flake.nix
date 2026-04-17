{
  description = "SourceOS Linux realization root";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
    in {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [ git jq nixpkgs-fmt ];
            shellHook = ''
              echo "SourceOS Linux development shell"
              echo "See docs/repository-layout.md, docs/agentplane-integration.md, and docs/mesh/README.md"
            '';
          };
        });

      nixosConfigurations = {
        builder-aarch64 = lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ ./hosts/builder-aarch64/default.nix ];
        };

        canary-x86_64 = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/canary-x86_64/default.nix ];
        };

        stable-x86_64 = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/stable-x86_64/default.nix ];
        };
      };

      checks = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in lib.optionalAttrs (system == "x86_64-linux" || system == "aarch64-linux") {
          builder-aarch64-smoke =
            if system == "aarch64-linux"
            then import ./tests/builder-aarch64-contract.nix { inherit pkgs; }
            else pkgs.runCommand "builder-aarch64-smoke-skip" {} ''
              mkdir -p $out
            '';

          canary-x86_64-smoke =
            if system == "x86_64-linux"
            then import ./tests/canary-x86_64-contract.nix { inherit pkgs; }
            else pkgs.runCommand "canary-x86_64-smoke-skip" {} ''
              mkdir -p $out
            '';

          stable-x86_64-smoke =
            if system == "x86_64-linux"
            then import ./tests/stable-x86_64-contract.nix { inherit pkgs; }
            else pkgs.runCommand "stable-x86_64-smoke-skip" {} ''
              mkdir -p $out
            '';

          mesh-module-contract = import ./tests/mesh-module-contract.nix { inherit pkgs; };
          mesh-runtime-contract = import ./tests/mesh-runtime-contract.nix { inherit pkgs; };
        });

      sourceos = {
        channels = [ "dev" "candidate" "stable" ];
        notes = "This flake is the Linux realization root. Control-plane semantics live in SocioProphet/agentplane and shared channel/capability schemas live in SocioProphet/socioprophet-agent-standards.";
      };
    };
}
