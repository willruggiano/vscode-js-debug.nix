{
  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "dream2nix/nixpkgs";
  };

  nixConfig = {
    extra-substituters = ["https://vscode-js-debug.cachix.org"];
    extra-trusted-public-keys = ["vscode-js-debug.cachix.org-1:R9DqPqQ4TZxvhStSu5v+6KcJ548NkUBXUVonqtkLl8g="];
  };

  outputs = {
    dream2nix,
    flake-utils,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    apps.${system}.update-sources = flake-utils.lib.mkApp {
      drv = pkgs.callPackage ./scripts/update-sources {};
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [niv pkgs.python3.pkgs.semver ruff-lsp];
    };

    formatter.${system} = pkgs.alejandra;

    packages.${system} = let
      sources = import ./nix/sources.nix {};
      patches = import ./patches;
      mkName = lib.replaceStrings ["."] ["-"];
      mkPackage = srcVersion: src:
        dream2nix.lib.evalModules {
          packageSets.nixpkgs = pkgs;
          modules = [
            {
              config.deps = let
                version =
                  if srcVersion == "latest"
                  then src.rev
                  else srcVersion;
              in {
                inherit src version;
                patches = patches.${version} or [];
              };
            }
            ./default.nix
            {
              paths = {
                projectRoot = ./.;
                projectRootFile = "flake.nix";
                package = ./.;
              };
            }
          ];
        };
    in
      lib.mapAttrs' (
        version: src:
          lib.nameValuePair (mkName version) (mkPackage version src)
      )
      sources;
  };
}
