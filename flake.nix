{
  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    vscode-js-debug.url = "github:microsoft/vscode-js-debug/v1.78.0";
    vscode-js-debug.flake = false;
  };
  outputs = inputs:
    inputs.dream2nix.lib.makeFlakeOutputs {
      systems = ["x86_64-linux"];
      config.projectRoot = ./.;
      source = inputs.vscode-js-debug;
      projects = ./projects.toml;
    };
}
