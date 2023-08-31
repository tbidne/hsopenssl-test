{
  description = "A flake for daiseeai";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs =
    inputs@{ flake-parts
    , self
    , nixpkgs
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem = { pkgs, ... }:
        let
          hlib = pkgs.haskell.lib;
          ghcVersion = "ghc945";
          compiler = pkgs.haskell.packages."${ghcVersion}";

          stack-wrapped = pkgs.symlinkJoin {
            name = "stack";
            paths = [ pkgs.stack ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/stack --add-flags "--no-nix --system-ghc"
            '';
          };

          buildTools = [
            compiler.ghc
            pkgs.zlib
            stack-wrapped
          ];

          otherDeps = [
            pkgs.openssl.dev
            pkgs.pkg-config # optional
          ];
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = buildTools ++ otherDeps;
          };
        };
      systems = [
        "x86_64-darwin"
        "x86_64-linux"
      ];
    };
}
