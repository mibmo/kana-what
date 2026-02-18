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
  };

  outputs =
    inputs@{ self, conch, ... }:
    conch.load (
      { pkgs, ... }:
      let
        nodejs = pkgs.nodejs_25;
        pnpm = pkgs.pnpm_9;
        wasm-bindgen-cli = pkgs.wasm-bindgen-cli_0_2_108;
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

        shell.packages = with pkgs; [
          binaryen
          cargo-leptos
          leptosfmt
          nodejs
          playwright
          pnpm
          wasm-bindgen-cli
        ];
      }
    );
}
