{
  version = "6.18.44";
  modDirVersion = "6.18.44-current-sunxi64";

  image = {
    url = "https://apt.armbian.com/pool/main/l/linux-6.18.44/linux-image-current-sunxi64_26.8.3_arm64__6.18.44-S1efe-D5397-P5708-C4e0c-H2153-HK01ba-Vc222-B4990-R448a.deb";
    sha256 = "09bb8bsrsgz6p0sb7h7s9ji5mj4217pmj4ndj13ykyyifwx2bjfh";
  };
  dtb = {
    url = "https://apt.armbian.com/pool/main/l/linux-dtb-current-sunxi64/linux-dtb-current-sunxi64_26.8.3_arm64__6.18.44-S1efe-D5397-P5708-C4e0c-H2153-HK01ba-Vc222-B4990-R448a.deb";
    sha256 = "0x7c3p2k042wrnvzs3axqzbxgnkrj0s41g9wij9p5snlvp46b9vs";
  };
  headers = {
    url = "https://apt.armbian.com/pool/main/l/linux-headers-current-sunxi64/linux-headers-current-sunxi64_26.8.3_arm64__6.18.44-S1efe-D5397-P5708-C4e0c-H2153-HK01ba-Vc222-B4990-R448a.deb";
    sha256 = "17ajgg44nw65wj76y29mld26iqva2pv2ddr6q83df9sp3xadk6vj";
  };
  libcDev = {
    url = "https://apt.armbian.com/pool/main/l/linux-libc-dev-current-sunxi64/linux-libc-dev-current-sunxi64_26.8.3_arm64__6.18.44-S1efe-D5397-P5708-C4e0c-H2153-HK01ba-Vc222-B4990-R448a.deb";
    sha256 = "0h4impjgmv1skk4bh0b17crr154pgppy3cfv9a872yhhwl6kn4ci";
  };
}
