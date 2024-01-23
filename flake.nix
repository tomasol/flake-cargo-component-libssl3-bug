{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          nativeBuildInputs = [ pkgs.nixpkgs-fmt ];
          buildInputs = with pkgs; [ rustToolchain openssl pkg-config  ];
        in
        {
          devShells.default = pkgs.mkShell {
            inherit buildInputs nativeBuildInputs ;
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl ]; # https://discourse.nixos.org/t/program-compiled-with-rust-cannot-find-libssl-so-3-at-runtime/27196/2
            shellHook = ''
              project_root="$(git rev-parse --show-toplevel 2>/dev/null)"
              export CARGO_INSTALL_ROOT="$project_root/.cargo"
              export PATH="$CARGO_INSTALL_ROOT/bin:$PATH"
              cargo_packages="cargo-component@0.6.0"
              cargo install --offline $cargo_packages 2>/dev/null || cargo install --debug $cargo_packages
              '';

          };
        }
      );
}
