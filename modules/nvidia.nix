# NVIDIA proprietary driver configuration for Wayland / Hyprland
{ config, pkgs, ... }:

{
  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Modesetting is required for Wayland compositors
    modesetting.enable = true;

    # Use the proprietary NVIDIA driver (set open = true for Ampere+ open kernel module)
    open = false;

    # Enable the NVIDIA settings menu (nvidia-settings)
    nvidiaSettings = true;

    # Power management — disable unless suspend/resume is tested and stable
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Use the stable driver package
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Environment variables needed for NVIDIA + Wayland
  environment.sessionVariables = {
    # Fix cursor rendering on NVIDIA
    WLR_NO_HARDWARE_CURSORS = "1";

    # Ensure proper NVIDIA Wayland backend
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";

    # Enable Wayland in Mozilla / Electron apps
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
