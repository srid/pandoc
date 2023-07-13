# For guidance on how to work with this flake, see
# https://zero-to-flakes.com/haskell-flake
{
  description = "Pandoc development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # TODO: Go back to nixpkgs-unstable after the haskell-updates branch is
    # merged; see
    # https://github.com/jgm/pandoc/issues/8818#issuecomment-1616587079
    # nixpkgs.url = "github:nixos/nixpkgs/haskell-updates";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    haskell-flake.url = "github:srid/haskell-flake";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.haskell-flake.flakeModule ];

      perSystem = { config, self', pkgs, ... }: {
        packages.default = self'.packages.pandoc;

        haskellProjects.default = {
          # Uncomment this if you want to debug haskell-flake behaviour.
          # debug = true;
          defaults.packages = {};  # Disable cabal.project parsing
          packages = {
            # Local packages go here.
            pandoc.source = inputs.self;
            pandoc-lua-engine.source = inputs.self + /pandoc-lua-engine;
            pandoc-server.source = inputs.self + /pandoc-server;
            pandoc-cli.source = inputs.self + /pandoc-cli;

            # Dependency source/version overrides go here
            hslua-repl.source = "0.1.1";
            hslua-core.source = "2.3.1";
            lua.source = "2.3.1";
            tasty-hslua.source = "1.1.0";
            tasty-lua.source = "1.1.0";
            hslua-marshalling.source = "2.3.0";
            hslua-objectorientation.source = "2.3.0";
            hslua-classes.source = "2.3.0";
            hslua-aeson.source = "2.3.0.1";
            hslua-packaging.source = "2.3.0";
            hslua-module-system.source = "1.1.0.1";
            hslua-module-text.source = "1.1.0.1";
            hslua-module-version.source = "1.1.0";
            hslua-module-path.source = "1.1.0";
            hslua.source = "2.3.0";
            pandoc-lua-marshal.source = "0.2.2";
            connection.source = "0.3.1";
            tls.source = "1.7.0";
          };
          settings = {
            # Cabal overrides of all packages go here.
            pandoc.justStaticExecutables = true;
            crypton-x509 = {
              broken = false;
              check = false;
            };
            hslua-typing = {
              broken = false;
              jailbreak = true;
            };
            tls.check = false;
          };
          devShell = {
            mkShellArgs.buildInputs = with pkgs.haskellPackages; [
              hlint
              ghcid
              ormolu
              stylish-haskell
              weeder
              servant-server
              hslua
              pkgs.bashInteractive
            ];
          };
        };
      };
    };
}
