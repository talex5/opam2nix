{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          opam2nix = import ./nix {
            inherit pkgs;
            ocaml-ng = pkgs.ocaml-ng;
          };
          default = opam2nix;
        };
      }
    );
}
