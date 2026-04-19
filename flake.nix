{
  description = "SourceOS Linux realization root";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # SourceOS fork of Albert (dev branch) including the `plugins/sourceos` action bus plugin.
    # Use git fetcher with submodules enabled because Albert relies on many submodules.
    albert_src = {
      url = "git+https://github.com/SociOS-Linux/albert?ref=dev&submodules=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, albert_src }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
    in {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in rec {
          meshd = pkgs.callPackage ./packages/mesh/meshd.nix { };
          meshd-linkd = pkgs.callPackage ./packages/mesh/meshd-linkd.nix { };
          meshd-exitd = pkgs.callPackage ./packages/mesh/meshd-exitd.nix { };

          # Nix lane for Workstation v0: build Albert from our fork so the SourceOS plugin ships.
          # This keeps clean installs from depending on distro packaging including our plugin.
          albert-sourceos = pkgs.albert.overrideAttrs (old: {
            src = albert_src;
            version = "${old.version or "0.0.0"}-sourceos";
          });

          default = meshd;
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Workstation v0 CLI toolset (best-effort).
          # We intentionally tolerate missing attrs to avoid breaking flake evaluation.
          workstationV0Names = [
            # baseline
            "git" "jq" "nixpkgs-fmt"

            # nav/shell
            "fzf" "atuin" "bat" "zoxide" "yazi" "eza" "gum" "direnv" "tldr" "fd" "ripgrep"

            # find/replace
            "sd"

            # git
            "lazygit" "gh" "diff-so-fancy" "tig" "svu"

            # process/ops
            "tmux" "sesh" "mprocs" "procs" "lazydocker" "k9s" "btop"

            # json
            "jnv" "gojq" "fx" "jless" "jqp"

            # disk
            "dua" "dust" "kondo"

            # docs/bench/watch
            "glow" "hyperfine" "entr" "curlie"

            # file motion
            "rclone" "rsync" "minio-client"

            # launcher (optional)
            "albert"
          ];

          haveAttr = n: builtins.hasAttr n pkgs;
          missing = lib.filter (n: !(haveAttr n)) workstationV0Names;
          presentPkgs = lib.filter (p: p != null) (map (n: if haveAttr n then pkgs.${n} else null) workstationV0Names);
          missingStr = lib.concatStringsSep " " missing;
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [ git jq nixpkgs-fmt ];
            shellHook = ''
              echo "SourceOS Linux development shell"
              echo "See docs/repository-layout.md, docs/agentplane-integration.md, and docs/mesh/README.md"
            '';
          };

          workstation-v0 = pkgs.mkShell {
            packages = presentPkgs;
            shellHook = ''
              echo "SourceOS Workstation v0 dev shell"
              echo "See docs/workstation/README.md"
              if [ -n "${missingStr}" ]; then
                echo "NOTE: missing nixpkgs attrs (not added): ${missingStr}"
              fi
              echo "Nix lane: build/install Albert with SourceOS plugin via: nix profile install .#albert-sourceos"
            '';
          };
        });

      nixosConfigurations = {
        builder-aarch64 = lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit self; };
          modules = [ ./hosts/builder-aarch64/default.nix ];
        };

        canary-x86_64 = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit self; };
          modules = [ ./hosts/canary-x86_64/default.nix ];
        };

        stable-x86_64 = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit self; };
          modules = [ ./hosts/stable-x86_64/default.nix ];
        };

        exit-x86_64 = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit self; };
          modules = [ ./hosts/exit-x86_64/default.nix ];
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

          exit-x86_64-smoke =
            if system == "x86_64-linux"
            then import ./tests/exit-x86_64-contract.nix { inherit pkgs; }
            else pkgs.runCommand "exit-x86_64-smoke-skip" {} ''
              mkdir -p $out
            '';

          mesh-module-contract = import ./tests/mesh-module-contract.nix { inherit pkgs; };
          mesh-runtime-contract = import ./tests/mesh-runtime-contract.nix { inherit pkgs; };
          mesh-package-contract = import ./tests/mesh-package-contract.nix { inherit pkgs; };
          mesh-host-runtime-contract = import ./tests/mesh-host-runtime-contract.nix { inherit pkgs; };

          meshd-package = self.packages.${system}.meshd;
          meshd-linkd-package = self.packages.${system}.meshd-linkd;
          meshd-exitd-package = self.packages.${system}.meshd-exitd;
        });

      sourceos = {
        channels = [ "dev" "candidate" "stable" ];
        notes = "This flake is the Linux realization root. Control-plane semantics live in SocioProphet/agentplane and shared channel/capability schemas live in SocioProphet/socioprophet-agent-standards.";
      };
    };
}
