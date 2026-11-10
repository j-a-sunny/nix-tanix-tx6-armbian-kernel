{
  version = "7.3.3";
  modDirVersion = "7.3.3-edge-sunxi64";

  image = {
    url = "https://apt.armbian.com/pool/main/l/linux-7.3.3/linux-image-edge-sunxi64_26.11.1_arm64__7.3.3-Sd50d-D59fc-Pa063-C4af3-Hb11b-HK01ba-Vc222-Bdf9b-R448a.deb";
    sha256 = "15yd52zjm2bypda4jqmi46748ljn0dnv6n9l8w6yylwayn4kf87q";
  };
  dtb = {
    url = "https://apt.armbian.com/pool/main/l/linux-dtb-edge-sunxi64/linux-dtb-edge-sunxi64_26.11.1_arm64__7.3.3-Sd50d-D59fc-Pa063-C4af3-Hb11b-HK01ba-Vc222-Bdf9b-R448a.deb";
    sha256 = "1min8bpd83j555zaa3ngs0vvdck27jllhlmsdwdnfnhigvcaikgm";
  };
  headers = {
    url = "https://apt.armbian.com/pool/main/l/linux-headers-edge-sunxi64/linux-headers-edge-sunxi64_26.11.1_arm64__7.3.3-Sd50d-D59fc-Pa063-C4af3-Hb11b-HK01ba-Vc222-Bdf9b-R448a.deb";
    sha256 = "19ific2s4sanqi3bq6b64ssvc4vz5vmg6ba8xzsfnxvnqxnazcsq";
  };
  libcDev = {
    url = "https://apt.armbian.com/pool/main/l/linux-libc-dev-edge-sunxi64/linux-libc-dev-edge-sunxi64_26.11.1_arm64__7.3.3-Sd50d-D59fc-Pa063-C4af3-Hb11b-HK01ba-Vc222-Bdf9b-R448a.deb";
    sha256 = "1f4nca8r97j63xqmyv2mxwpgh8gm3hnpzlj4pdw06a5n5f494wjr";
  };
}
