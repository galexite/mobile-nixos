let
  # Selection of the device can be made either through the environment or through
  # using `--argstr device [...]`.
  deviceFromEnv = builtins.getEnv "MOBILE_NIXOS_DEVICE";

  # Selection of the configuration can by made either through NIX_PATH,
  # through local.nixx or as a parameter.
  default_configuration =
    let
      configPathFromNixPath = (builtins.tryEval <mobile-nixos-configuration>).value;
    in
    if configPathFromNixPath != false then [ configPathFromNixPath ]
    else if (builtins.pathExists ./local.nix) then [ (import ./local.nix) ]
    else []
  ;

  # "a" nixpkgs we're using for its lib.
  pkgs' = import <nixpkgs> {};
in
{
  # The identifier of the device this should be built for.
  # (This gets massaged later on)
  # This allows using `default.nix` as a pass-through function.
  # See usage in examples folder.
  device ? null
, configuration ? default_configuration
}:
let
  inherit (pkgs'.lib) optional;

  # Either use:
  #   The given `device`.
  #   The environment variable.
  final_device = if device != null then device
    else if deviceFromEnv == "" then
    throw "Please pass a device name or set the MOBILE_NIXOS_DEVICE environment variable."
    else deviceFromEnv
  ;

  # Evaluates NixOS, mobile-nixos and the device config with the given
  # additional modules.
  evalWith = modules: import ./lib/eval-config.nix {
    modules = [
      (import (./. + "/devices/${final_device}" ))
    ] ++ modules;
  };

  # The "default" eval.
  eval = evalWith configuration;

  # This is used by the `-A installer` shortcut.
  installer-eval = evalWith [
    ./profiles/installer.nix
  ];
in
{
  # The build artifacts from the modules system.
  inherit (eval.config.system) build;

  # The evaluated config
  inherit (eval) config;

  # The final pkgs set, usable as -A pkgs.[...] on the CLI.
  inherit (eval) pkgs;

  # The whole (default) eval
  inherit eval;

  # Shortcut to allow building `nixos` from the same channel revision.
  # This is used by `./nixos/default.nix`
  # Any time `nix-build nixos` is used upstream, it can be used here.
  nixos = import <nixpkgs/nixos>;

  # `mobile-installer` will, when possible, contain the installer build for the
  # given system. It usually is an alias for a disk-image type build.
  installer = installer-eval.config.system.build.mobile-installer;

  # Evaluating this whole set is counter-productive.
  # It'll put a *bunch* of build products from the misc. inherits we added.

  # (We're also using `device` to force the other throw to happen first.)
  # TODO : We may want to produce an internal list of available outputs, so that
  #        each platform can document what it makes available. This would allow
  #        the message to be more user-friendly by displaying a choice.
  __please-fail = throw ''
    Cannot directly build for ${final_device}...

    Building this whole set is counter-productive, and not likely to be what
    is desired.

    You can try to build the `installer` attribute (-A installer) if your system
    provides an installer.

    Please refer to your platform's documentation for usage.
  '';
}
