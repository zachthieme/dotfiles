{ hosts }:
let
  hostname = builtins.getEnv "HOSTNAME";
  system = builtins.getEnv "NIX_SYSTEM";
  isAarch64Darwin = builtins.match "aarch64-darwin" system != null;
  defaults =
    if builtins.hasAttr hostname hosts then
      hostname
    else if builtins.match "zthieme.*" hostname != null then
      "zthieme34911"
    else if isAarch64Darwin then
      "cortex"
    else
      "malv2";
in
{
  defaultHost = defaults;
}
