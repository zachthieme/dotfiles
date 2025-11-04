{ hosts }:
let
  hostname = builtins.getEnv "HOSTNAME";

  # Use actual hostname if it exists in definitions.nix
  defaultHost =
    if hostname != "" && builtins.hasAttr hostname hosts then
      hostname
    else
      # Provide helpful error message if hostname not found
      builtins.trace
        "Warning: Hostname '${hostname}' not found in modules/hosts/definitions.nix. Available hosts: ${builtins.toString (builtins.attrNames hosts)}"
        "";
in
{
  inherit defaultHost;
}
