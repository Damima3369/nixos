{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver      # iHD: VAAPI decode/encode (primary для ADL-N)
      vpl-gpu-rt              # QSV/encode enhancements (11th+ gen)
      intel-compute-runtime   # OpenCL/Compute/Level Zero
      libvdpau-va-gl          # Если VDPAU нужен
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";  # Force modern driver
    NIXOS_OZONE_GFX_URL = "1";  # Включает аппаратное ускорение в Wayland для Electron/Java приложений
    GBM_BACKEND = "kms";        # Помогает драйверам Intel правильно инициализировать EGL дисплей
  };

  boot.kernelParams = [ "i915.force_probe=46d1" ];

  environment.variables = {
    VULKAN_DRIVER_NAME = "intel";  # Для Vulkan apps (optional, но полезно)
  };

  hardware.enableAllFirmware = true;

  environment.systemPackages = with pkgs; [
    libva-utils     # vainfo etc
    vulkan-tools    # vulkaninfo, vkcube
    intel-gpu-tools # intel_gpu_top для monitoring/widget
    mesa-demos      # glxinfo, glxgears для теста OpenGL
  ];
}