{
  description = "An implementation of the Double Ratchet cryptographic ratchet";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  # We can't use the current stable release because of
  # https://github.com/emscripten-core/emscripten/issues/16913
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.npmlock2nix = {
    url = "github:nix-community/npmlock2nix";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, npmlock2nix }:
   (
      # some systems cause issues, e.g. i686-linux is unsupported by gradle,
      # which causes "nix flake check" to fail. Investigate more later, but for
      # now, we will just allow x86_64-linux
      flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                npmlock2nix = final.callPackage npmlock2nix {};
              })
            ];
          };
          node_modules = pkgs.npmlock2nix.node_modules { src = ./javascript; };
        in
          rec {
            checks.gcc-cmake = pkgs.gccStdenv.mkDerivation {
              name = "olm";

              buildInputs = [ pkgs.cmake ];

              src = ./.;

              buildPhase = ''
                cmake . -Bbuild
                cmake --build build
              '';

              doCheck = true;
              checkPhase = ''
                cd build/tests
                ctest .
                cd ../..
              '';
            };

            checks.clang-cmake = pkgs.clangStdenv.mkDerivation {
              name = "olm";

              buildInputs = [ pkgs.cmake ];

              src = ./.;

              buildPhase = ''
                cmake . -Bbuild
                cmake --build build
              '';

              doCheck = true;
              checkPhase = ''
                cd build/tests
                ctest .
                cd ../..
              '';
            };

            checks.gcc-make = pkgs.gccStdenv.mkDerivation {
              name = "olm";

              src = ./.;

              buildPhase = ''
                make
              '';

              doCheck = true;
              checkPhase = ''
                make test
              '';

              installPhase = ''
                make install PREFIX=$out
              '';
            };

            packages.javascript = pkgs.buildEmscriptenPackage {
              pname = "olm";
              inherit (builtins.fromJSON (builtins.readFile ./javascript/package.json)) version;

              buildInputs = with pkgs; [ gnumake python3 nodejs ];

              src = ./.;

              postPatch = ''
                patchShebangs .
              '';

              configurePhase = "";

              buildPhase = ''
                export EM_CACHE=$TMPDIR
                make javascript/exported_functions.json
                make js
              '';

              output = [ "out" ];

              installPhase = ''
                mkdir -p $out/javascript
                cd javascript
                echo sha256: > checksums.txt
	              sha256sum olm.js olm_legacy.js olm.wasm >> checksums.txt
	              echo sha512: >> checksums.txt
	              sha512sum olm.js olm_legacy.js olm.wasm >> checksums.txt
                cp package.json olm.js olm.wasm olm_legacy.js index.d.ts README.md checksums.txt $out/javascript
                cd ..
              '';

              checkPhase = ''
                cd javascript
                export HOME=$TMPDIR
                ln -s ${node_modules}/node_modules ./node_modules
                npm test
                cd ..
              '';
            };

            packages.default = packages.javascript;
          }
      )
   );
}
