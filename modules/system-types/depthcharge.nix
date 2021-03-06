{ config, pkgs, lib, ... }:

let
  device_config = config.mobile.device;
  enabled = config.mobile.system.type == "depthcharge";

  build = pkgs.callPackage ../../systems/depthcharge {
    inherit device_config;
    initrd = config.system.build.initrd;
    system = config.system.build.rootfs;
  };
in
{
  config = lib.mkMerge [
    { mobile.system.types = [ "depthcharge" ]; }

    (lib.mkIf enabled {
      system.build = {
        inherit (build) disk-image kpart;
        # installer shortcut; it's a depthcharge disk-image build.
        mobile-installer = build.disk-image;
      };
    })
  ];
}
