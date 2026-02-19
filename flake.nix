{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    conch-rust = {
      url = "github:mibmo/conch-rust";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        conch.follows = "conch";
        rust-overlay.follows = "rust-overlay";
      };
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane";
  };

  outputs =
    inputs@{ self, conch, ... }:
    conch.load (
      {
        config,
        lib,
        pkgs,
        system,
        ...
      }:
      let
        inherit (lib.fileset)
          fileFilter
          intersection
          toSource
          unions
          ;

        project-name = "kana-what";
        version = self.shortRev or "dirty";

        nodejs = pkgs.nodejs_25;
        pnpm = pkgs.pnpm_10;
        wasm-bindgen-cli = pkgs.wasm-bindgen-cli_0_2_100;

        craneLib = (inputs.crane.mkLib pkgs).overrideToolchain (
          p:
          p.rust-bin.nightly.latest.default.override {
            inherit (config.rust) targets;
          }
        );

        commonArgs = {
          inherit version;
          strictDeps = true;
          cargoExtraArgs = "--target wasm32-unknown-unknown";
        };

        cargoArtifacts = craneLib.buildDepsOnly (
          commonArgs
          // {
            pname = project-name;

            src = toSource {
              root = ./.;
              fileset = unions [
                ./Cargo.lock
                ./Cargo.toml
              ];
            };
          }
        );

        frontend = craneLib.buildPackage (
          commonArgs
          // {
            pname = "${project-name}-frontend";
            inherit cargoArtifacts;

            doCheck = false;

            src = toSource {
              root = ./.;
              fileset = unions [
                (fileFilter (file: file.hasExt "rs") ./.)
                ./Cargo.lock
                ./Cargo.toml
                ./index.html
              ];
            };

            nativeBuildInputs = [
              pkgs.trunk
              wasm-bindgen-cli
            ];

            installPhase = ''
              runHook preInstall

              cp "${stylesheet}" style.css

              trunk build --release --dist "$out"

              runHook postInstall
            '';
          }
        );

        stylesheet = pkgs.stdenv.mkDerivation (finalAttrs: {
          pname = "${project-name}-stylesheet";
          inherit version;

          src = toSource {
            root = ./.;
            fileset = unions [
              ./package.json
              ./pnpm-lock.yaml
              ./postcss.config.js
              ./style
            ];
          };

          nativeBuildInputs = [
            nodejs
            pkgs.pnpmConfigHook
            pnpm
          ];

          pnpmDeps = pkgs.fetchPnpmDeps {
            inherit (finalAttrs) pname version src;
            fetcherVersion = 3;
            hash = "sha256-8Vlf9zQHSAZhifWC3Qp3epV+EU5JlgCqZBSS+KOreKo=";
          };

          installPhase = ''
            runHook preInstall

            pnpm exec postcss style/main.css > $out

            runHook postInstall
          '';
        });

        site-artifacts = pkgs.stdenv.mkDerivation (finalAttrs: {
          pname = "${project-name}-site-artifacts";
          inherit version;

          src = ./public;

          installPhase = ''
            runHook preInstall

            # symlink stylesheet and frontend files
            mkdir -p "$out"
            find "${frontend}" -type f | while read -r file; do
              ln -s "$file" "$out/$(basename "$file")"
            done

            # create directory structure
            find . -type d -exec mkdir -p "$out/{}" \;
            # symlink public artifacts
            find . -type f | sed 's|^\./||' | while read -r file; do
              ln -s "$src/$file" "$out/$file"
            done

            runHook postInstall
          '';
        });
      in
      {
        imports = [
          inputs.conch-rust.conchModules.rust
        ];

        rust = {
          enable = true;
          channel = "nightly";
          profile = "complete";
          targets = [ "wasm32-unknown-unknown" ];
        };

        shell = {
          environment.RUSTFLAGS = ''--cfg getrandom_backend="wasm_js"'';
          packages = with pkgs; [
            bacon
            cargo-sort
            leptosfmt
            nodejs
            playwright
            pnpm
            trunk
            wasm-bindgen-cli
          ];
        };

        flake.packages.${system} = {
          inherit
            stylesheet
            frontend
            site-artifacts
            ;
        };
      }
    );
}
