{ hosts }:
let
  # Try HOSTNAME first (Linux), then HOST (macOS)
  hostname =
    let h = builtins.getEnv "HOSTNAME";
    in if h != "" then h else builtins.getEnv "HOST";

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
