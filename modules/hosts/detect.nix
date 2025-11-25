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
    else if hostname != "" then
      # Only show warning if hostname is set but not found
      builtins.trace
        "Warning: Hostname '${hostname}' not found in modules/hosts/definitions.nix. Available hosts: ${builtins.toString (builtins.attrNames hosts)}"
        ""
    else
      # Hostname not set - silently return empty (user is likely specifying host explicitly)
      "";
in
{
  inherit defaultHost;
}
