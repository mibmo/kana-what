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
        wasm-bindgen-cli = pkgs.wasm-bindgen-cli_0_2_100;
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
            binaryen
            cargo-sort
            leptosfmt
            nodejs
            playwright
            pnpm
            trunk
            wasm-bindgen-cli
          ];
        };
      }
    );
}
