{
  version = "7.1.8";
  modDirVersion = "7.1.8-edge-sunxi64";

  image = {
    url = "https://apt.armbian.com/pool/main/l/linux-7.1.8/linux-image-edge-sunxi64_26.8.3_arm64__7.1.8-S25c7-D5397-Pb94a-Cec3b-H2153-HK01ba-Vc222-B4990-R448a.deb";
    sha256 = "0xbl6x0n9nqnh9f8hfvhzs6jpq5iab23q811i01plhmbd8s9j9qx";
  };
  dtb = {
    url = "https://apt.armbian.com/pool/main/l/linux-dtb-edge-sunxi64/linux-dtb-edge-sunxi64_26.8.3_arm64__7.1.8-S25c7-D5397-Pb94a-Cec3b-H2153-HK01ba-Vc222-B4990-R448a.deb";
    sha256 = "16lbbllw7q6ps4szgisx8lq3g4nxv8gkip1qkhix3afc7pywiw17";
  };
  headers = {
    url = "https://apt.armbian.com/pool/main/l/linux-headers-edge-sunxi64/linux-headers-edge-sunxi64_26.8.3_arm64__7.1.8-S25c7-D5397-Pb94a-Cec3b-H2153-HK01ba-Vc222-B4990-R448a.deb";
    sha256 = "1ncbj99ddy11y0adjrjqyymznhp8k856nigzwlv64x8lzmbdcf6k";
  };
  libcDev = {
    url = "https://apt.armbian.com/pool/main/l/linux-libc-dev-edge-sunxi64/linux-libc-dev-edge-sunxi64_26.8.3_arm64__7.1.8-S25c7-D5397-Pb94a-Cec3b-H2153-HK01ba-Vc222-B4990-R448a.deb";
    sha256 = "05qnzhky56yk0apy9l65f4l3972wlzxzmji08q0adrwphzbdwaz9";
  };
}
