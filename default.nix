{
  config,
  dream2nix,
  lib,
  ...
}: {
  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    inherit (config.deps) patches src;
    buildPhase = ''
      gulp compile && gulp vsDebugServerBundle:webpack-bundle
    '';
  };

  deps = {nixpkgs, ...}: {
    inherit
      (nixpkgs)
      fetchFromGitHub
      libsecret
      pkg-config
      stdenv
      ;

    # https://github.com/microsoft/vscode-js-debug/commit/f33da847503857454d2abc6f35e72a9722115b46
    picomatch = nixpkgs.fetchFromGitHub {
      owner = "connor4312";
      repo = "picomatch";
      rev = "2fbe90b12eafa7dde816ff8c16be9e77271b0e0b";
      hash = "sha256-NWVzzTlGfyXG/N0z7wy3oZDjuGZ1uQHfwT/EEKGp73Q=";
    };
  };

  nodejs-granular-v3 = {
    deps = {
      keytar."7.7.0" = {
        mkDerivation = {
          nativeBuildInputs = [config.deps.pkg-config];
          buildInputs = [config.deps.libsecret];
        };
      };
      picomatch."2.3.1" = {
        mkDerivation = {
          src = lib.mkForce config.deps.picomatch;
        };
      };
      playwright."1.26.0" = {
        env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = 1;
      };
    };
  };

  nodejs-package-lock-v3 = {
    packageLockFile = "${config.mkDerivation.src}/package-lock.json";
  };

  name = "vscode-js-debug";
  inherit (config.deps) version;
}
