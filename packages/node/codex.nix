{ lib, buildNpmPackage, fetchurl }:

buildNpmPackage rec {
  pname = "codex";
  version = "0.2.3";

  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    sha256 = "1pn06s2vs1clhacxyh7salpb4vy1awbb6ksx4cykgm35l8fipjps";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  meta = {
    description = "Static site and code documentation generator CLI";
    homepage = "https://www.npmjs.com/package/codex";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "codex";
  };
}
