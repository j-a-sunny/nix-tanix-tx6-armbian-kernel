{
  stdenv,
  lib,
  fetchurl,
  dpkg,
  runCommand,
  sourcesFile ? ./sources.nix,
  features ? { },
  ...
}:
let
  sources = import sourcesFile;

  # Fetch + extract all four .debs in one shared derivation, so the network
  # fetches are pinned/reproducible (via fixed sha256 hashes) and happen
  # only once regardless of how many outputs reference them.
  extracted =
    runCommand "armbian-kernel-extracted-${sources.modDirVersion}"
      {
        nativeBuildInputs = [ dpkg ];
      }
      ''
        mkdir -p $out
        dpkg-deb -x ${fetchurl { inherit (sources.image) url sha256; }} $out
        dpkg-deb -x ${fetchurl { inherit (sources.dtb) url sha256; }} $out
        dpkg-deb -x ${fetchurl { inherit (sources.headers) url sha256; }} $out
        dpkg-deb -x ${fetchurl { inherit (sources.libcDev) url sha256; }} $out
      '';
in
stdenv.mkDerivation rec {
  pname = "linux-armbian-tanix-tx6";
  version = sources.version;
  modDirVersion = sources.modDirVersion;

  outputs = [
    "out"
    "dev"
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out
    cp ${extracted}/boot/vmlinuz-${modDirVersion} $out/Image

    mkdir -p $out/dtbs
    cp -r ${extracted}/boot/dtb-${modDirVersion}/allwinner $out/dtbs/allwinner

    mkdir -p $out/lib/modules/${modDirVersion}
    cp -r ${extracted}/lib/modules/${modDirVersion}/kernel $out/lib/modules/${modDirVersion}/kernel
    cp ${extracted}/lib/modules/${modDirVersion}/modules.* $out/lib/modules/${modDirVersion}/

    # Headers, for building out-of-tree modules / DKMS against this kernel.
    mkdir -p $dev/lib/modules/${modDirVersion}
    headers_src="$(find ${extracted}/usr/src -maxdepth 1 -type d -name 'linux-headers-*')"
    cp -r "$headers_src" $dev/lib/modules/${modDirVersion}/build
    ln -s ./build $dev/lib/modules/${modDirVersion}/source

    # UAPI/libc headers, for userspace code that includes kernel headers directly.
    mkdir -p $dev/include
    cp -r ${extracted}/usr/include/. $dev/include/
  '';

  # Points directly into the shared extraction output — already
  # hash-verified via the fetchurl calls above, no separate fetch needed.
  configfile = "${extracted}/boot/config-${modDirVersion}";

  passthru = {
    inherit modDirVersion;
    isLTS = false;
    isZen = false;
    kernelOlder = lib.versionOlder version;
    kernelAtLeast = lib.versionAtLeast version;
    inherit features;
  };

  # The package contains aarch64 binaries, but its build phase only extracts
  # Debian packages and copies files, so it can be built on x86_64 hosts too.
  meta.platforms = [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
