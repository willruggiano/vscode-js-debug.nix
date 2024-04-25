import fileinput
import json
import semver
import subprocess

with open("nix/sources.json") as sources:
    latest = sorted(
        [semver.Version.parse(v.removeprefix("v")) for v in json.load(sources)]
    )[-1]

versions = []
for line in fileinput.input(encoding="utf-8"):
    version = semver.Version.parse(line.removeprefix("v"))
    if version > latest:
        versions.append(version)

for version in versions:
    subprocess.run(
        [
            "niv",
            "add",
            "microsoft/vscode-js-debug",
            "-n",
            f"v{version}",
            "-r",
            f"v{version}",
            "-t",
            "https://github.com/<owner>/<repo>/archive/refs/tags/<rev>.tar.gz",
        ]
    )
