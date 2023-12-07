import fileinput
import json
import semver
import subprocess

with open("nix/sources.json") as sources:
    latest = semver.Version.parse(json.load(sources)["latest"]["rev"].removeprefix("v"))

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

if len(versions) > 0:
    subprocess.run(["niv", "update", "latest", "-r", f"v{versions[-1]}"])
