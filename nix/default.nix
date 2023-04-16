{
	pkgs,
	ocaml-ng, ocamlPackagesOverride ? ocaml-ng.ocamlPackages_4_13,
}:
let
	ocamlPackages = ocamlPackagesOverride;
        srcs = {
          "spdx_licenses" = builtins.fetchurl {
            url = "https://github.com/kit-ty-kate/spdx_licenses/archive/c6ba0493c25ce4d9ff8cb45b228ce412f4444aa0.tar.gz";
            sha256 = "011r84db5mwjyjwbrbf8vajy9fnbmzyxjk15avglq0550dqjgv5z";
          };
          # These were copied from nixpkgs/pkgs/development/tools/ocaml/opam/default.nix (they are not exposed):
          "0install-solver" = builtins.fetchurl {
            url = "https://github.com/0install/0install/releases/download/v2.17/0install-v2.17.tbz";
            sha256 = "08q95mzmf9pyyqs68ff52422f834hi313cxmypwrxmxsabcfa10p";
          };
          "opam-0install" = builtins.fetchurl {
            url = "https://github.com/ocaml-opam/opam-0install-solver/releases/download/v0.4.2/opam-0install-cudf-v0.4.2.tbz";
            sha256 = "10wma4hh9l8hk49rl8nql6ixsvlz3163gcxspay5fwrpbg51fmxr";
          };
        };
in
let
	ocaml = ocamlPackages.ocaml;
	callOcamlPackage = ocamlPackages.newScope {
		inherit ocaml ocamlPackages;
		dune_2 = ocamlPackages.dune_2;
		fileutils = ocamlPackages.fileutils.overrideAttrs (o: {
			# disable tests, workaround for https://github.com/timbertson/opam2nix/issues/47
			configureFlags = [];
			doCheck = false;
		});
                inherit (ocamlPackages) opam-core opam-format opam-repository opam-solver opam-state opam-file-format;
                opam-installer = pkgs.opam.installer;

		zeroinstall-solver = callOcamlPackage ({ buildDunePackage }:
			buildDunePackage {
				useDune2 = true;
				pname = "0install-solver";
				version = "master";
				src = srcs."0install-solver";
			}
		) {};
		
		opam-0install = callOcamlPackage ({ buildDunePackage, fmt, cmdliner, opam-state, zeroinstall-solver }:
			buildDunePackage {
				pname = "opam-0install";
				src = srcs.opam-0install;
				version = "master";
				useDune2 = true;
				propagatedBuildInputs = [fmt cmdliner opam-state zeroinstall-solver];
			}
		) {};

		spdx_licenses = callOcamlPackage ({buildDunePackage}:
			buildDunePackage {
				pname = "spdx_licenses";
				version = "main";
				src = srcs.spdx_licenses;
				useDune2 = true;
			}
		) {};
	};

in callOcamlPackage ./opam2nix.nix {
	opam2nixSrc = ../.;
}
