{
  writeShellApplication,
  gh,
  niv,
  python3,
}:
writeShellApplication {
  name = "update-sources";
  runtimeInputs = [
    gh
    niv
    (python3.withPackages (pkgs: with pkgs; [semver]))
  ];
  text = ''
    gh api repos/microsoft/vscode-js-debug/releases --jq '.[].tag_name' | python ${./update-sources.py}
  '';
}
