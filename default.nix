{
  config,
  dream2nix,
  ...
}: {
  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    inherit (config.deps) src;
    buildPhase = ''
      gulp compile && gulp vsDebugServerBundle:webpack-bundle
    '';
  };

  deps = {nixpkgs, ...}: {
    inherit
      (nixpkgs)
      libsecret
      pkg-config
      stdenv
      ;
  };

  nodejs-granular-v3 = {
    deps = {
      keytar."7.7.0" = {
        mkDerivation = {
          nativeBuildInputs = [config.deps.pkg-config];
          buildInputs = [config.deps.libsecret];
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
