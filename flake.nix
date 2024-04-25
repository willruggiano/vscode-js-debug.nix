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
    self,
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

    # TODO: We don't really need a "latest". We could just take the highest
    # version after building all of the versioned derivations.
    packages.${system} = let
      sources = import ./nix/sources.nix {};
      inherit (import ./patches) patches;

      versionNewer = a: b: (builtins.compareVersions a b) >= 0;

      mkName = lib.replaceStrings ["."] ["-"];
      mkPackage = version: src: let
        semver = lib.removePrefix "v" version;
        patchesToApply = builtins.filter (p: versionNewer semver p.since) patches;
      in
        dream2nix.lib.evalModules {
          packageSets.nixpkgs = pkgs;
          modules = [
            {
              config.deps = {
                inherit src version;
                patches = builtins.map (p: p.patch) patchesToApply;
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

      packages =
        lib.mapAttrs'
        (version: src: lib.nameValuePair (mkName version) (mkPackage version src))
        sources;
    in
      {
        default = self.packages.${system}.latest;
        latest =
          lib.foldl'
          (a: b:
            if (versionNewer (a.version or "") (b.version or ""))
            then a
            else b)
          {}
          (lib.attrValues packages);
      }
      // packages;
  };
}
