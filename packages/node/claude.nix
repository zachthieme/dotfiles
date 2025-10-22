{ lib, buildNpmPackage, fetchurl }:

buildNpmPackage rec {
  pname = "claude-code";
  version = "2.0.25";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/${pname}/-/${pname}-${version}.tgz";
    sha256 = "0bc5sgdgb16v99wqcxpsxqnkmybvbvygdmk9hsqljkm3749sybln";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  meta = {
    description = "Official Claude Code CLI for interacting with Anthropic's assistant";
    homepage = "https://github.com/anthropics/claude-code";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "claude";
  };
}
