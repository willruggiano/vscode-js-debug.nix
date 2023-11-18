{
  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    nixpkgs.follows = "dream2nix/nixpkgs";
  };
  outputs = {
    dream2nix,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    inherit (nixpkgs) lib;
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [niv];
    };

    packages.${system} = let
      sources = import ./nix/sources.nix {};
    in
      lib.mapAttrs (version: src:
        dream2nix.lib.evalModules {
          packageSets.nixpkgs = pkgs;
          modules = [
            {
              config.deps.src = src;
              config.deps.version = version;
            }
            ./default.nix
            {
              paths.projectRoot = ./.;
              paths.projectRootFile = "flake.nix";
              paths.package = ./.;
            }
          ];
        })
      sources;
  };
}
