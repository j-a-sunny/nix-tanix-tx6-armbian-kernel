{
  version = "7.3.1";
  modDirVersion = "7.3.1-edge-sunxi64";

  image = {
    url = "https://apt.armbian.com/pool/main/l/linux-7.3.1/linux-image-edge-sunxi64_26.8.14_arm64__7.3.1-S79a9-D68f5-P02ae-C4af3-Hb11b-HK01ba-Vc222-B0577-R448a.deb";
    sha256 = "0a20vz1gmn1mwzr7afp5hamghh3pa4a7mv9zl1d6z6b1idpyzbnl";
  };
  dtb = {
    url = "https://apt.armbian.com/pool/main/l/linux-dtb-edge-sunxi64/linux-dtb-edge-sunxi64_26.8.14_arm64__7.3.1-S79a9-D68f5-P02ae-C4af3-Hb11b-HK01ba-Vc222-B0577-R448a.deb";
    sha256 = "1p9bwzllp1sg22zi7l0pfk7gwh114hrgl7k936v4gxxp7zdz1d1h";
  };
  headers = {
    url = "https://apt.armbian.com/pool/main/l/linux-headers-edge-sunxi64/linux-headers-edge-sunxi64_26.8.14_arm64__7.3.1-S79a9-D68f5-P02ae-C4af3-Hb11b-HK01ba-Vc222-B0577-R448a.deb";
    sha256 = "082hb9cbl47dsv8lpadbrzd1hz8sc5aypib0rnby5f265k79gyrv";
  };
  libcDev = {
    url = "https://apt.armbian.com/pool/main/l/linux-libc-dev-edge-sunxi64/linux-libc-dev-edge-sunxi64_26.8.14_arm64__7.3.1-S79a9-D68f5-P02ae-C4af3-Hb11b-HK01ba-Vc222-B0577-R448a.deb";
    sha256 = "03gwzqldqdc5k6q7qcr5xxcpynfwbrq8s008djvgy3sk647037ii";
  };
}
