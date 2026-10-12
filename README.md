# nix-tanix-tx6-armbian-kernel

Nix flake that packages Armbian's prebuilt kernel, device tree and headers for
the Tanix TX6 (Allwinner H6).

The TX6's Ethernet goes through an AC200 PHY whose driver was never merged into
mainline Linux, so stock NixOS kernels can't bring it up. Armbian carries the
patches; this flake repackages their already-built `.deb`s (nothing is compiled)
and pins them by hash. GitHub Actions bumps the pins daily.

## Usage

Add the flake and its overlay:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    tanix-tx6-kernel.url = "github:j-a-sunny/nix-tanix-tx6-armbian-kernel";
  };

  outputs = { nixpkgs, tanix-tx6-kernel, ... }: {
    nixosConfigurations.tanix-tx6 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        { nixpkgs.overlays = [ tanix-tx6-kernel.overlays.default ]; }
        ./configuration.nix
      ];
    };
  };
}
```

Then in `configuration.nix`:

```nix
{
  boot.kernelPackages = pkgs.linuxPackages-tanix-tx6;         # stable
  # boot.kernelPackages = pkgs.linuxPackages-tanix-tx6-latest; # edge

  hardware.deviceTree = {
    enable = true;
    name = "allwinner/sun50i-h6-tanix-tx6.dtb";
  };
  hardware.enableRedistributableFirmware = true;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible = {
    enable = true;
    useGenerationDeviceTree = true;
  };

  # Required by this prebuilt kernel (see Limitations)
  boot.initrd.systemd.enable = false;
  boot.initrd.includeDefaultModules = false;
}
```

`-withHeaders` variants (`linuxPackages-tanix-tx6-withHeaders`,
`linuxPackages-tanix-tx6-latest-withHeaders`) are aliases of the above; the
`dev` output with headers is always present.

Standalone build:

```bash
nix build .#armbian-kernel-tanix-tx6        # or ...-edge
```

## Updating pins

CI runs `update-stable.yml` and `update-edge.yml` daily. Each one updates its
pin, checks that it builds, and commits it. They run independently, so one
failing doesn't block the other. To update by hand:

```bash
nix run .#update-sources                                             # stable
BRANCH=edge SOURCES_NIX=./sources-edge.nix nix run .#update-sources  # edge
```

## Limitations

- Scripted initrd only. The kernel isn't built through nixpkgs, so
  `boot.initrd.systemd.enable` can't inspect its config.
- Default initrd modules include x86 drivers that don't exist in Armbian's
  ARM build. SD/eMMC support is built in, so nothing needs replacing.
- Audio is untested.
- The dtb path is hardcoded for the Tanix TX6.
- If Armbian moves its package index, update `PACKAGES_PATH` in
  `update-sources.sh`.

## Credits

The AC200 EPHY driver comes from Jernej Skrabec's ~2019 patches, carried in
Armbian's build tree. This repo only repackages Armbian's binaries.
