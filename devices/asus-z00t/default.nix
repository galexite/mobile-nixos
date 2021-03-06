{ config, lib, pkgs, ... }:

{
  mobile.device.name = "asus-z00t";
  mobile.device.info = rec {
    format_version = "0";
    name = "Zenfone 2 Laser/Selfie (1080p)";
    manufacturer = "Asus";
    date = "";
    modules_initfs = "";
    arch = "aarch64";
    keyboard = false;
    external_storage = true;
    screen_width = "1080";
    screen_height = "1920";
    dev_touchscreen = "";
    dev_touchscreen_calibration = "";
    dev_keyboard = "";
    flash_method = "fastboot";
    kernel_cmdline = "androidboot.hardware=qcom ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 androidboot.selinux=permissive";
    generate_bootimg = true;
    bootimg_qcdt = true;
    flash_offset_base = "0x10000000";
    flash_offset_kernel = "0x00008000";
    flash_offset_ramdisk = "0x02000000";
    flash_offset_second = "0x00f00000";
    flash_offset_tags = "0x00000100";
    flash_pagesize = "2048";
    pm_name = "asus-z00t";

    # TODO : make kernel part of options.
    kernel = pkgs.callPackage ./kernel { kernelPatches = pkgs.defaultKernelPatches; };
    dtb = "${kernel}/dtbs/asus-z00t.img";
  };
  mobile.hardware = {
    # This could also be pre-built option types?
    soc = "qualcomm-msm8939";
    # 3GB for the specific revision supported.
    # When this will be actually used, this may be dropped to 2, and/or
    # document all ram types as a list and work with min/max of those.
    ram = 1024 * 3;
    screen = {
      width = 1080; height = 1920;
    };
  };

  mobile.system.type = "android";
}
