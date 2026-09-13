{
  description = "Armbian kernel + dtb + headers for the Tanix TX6, packaged as a Nix flake (AC200 Ethernet fix)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      # The kernel/dtb/headers themselves only make sense on the board
      # (aarch64-linux), but nothing in armbian-kernel.nix actually compiles
      # anything — it's just dpkg-deb -x and cp, which work fine regardless
      # of the host doing the building. Generating outputs for x86_64-linux
      # too means CI (GitHub's runners are x86_64) can run `nix run
      # .#update-sources` and `nix build .#armbian-kernel-tanix-tx6` to
      # verify a new pin, without needing QEMU/cross-compilation.
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      # `nix build .#armbian-kernel-tanix-tx6` — build the kernel standalone.
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          armbian-kernel-tanix-tx6 = pkgs.callPackage ./armbian-kernel.nix { };
          armbian-kernel-tanix-tx6-edge = pkgs.callPackage ./armbian-kernel.nix {
            sourcesFile = ./sources-edge.nix;
          };
          default = pkgs.callPackage ./armbian-kernel.nix { };
        }
      );

      # CachyOS-style linuxPackages attributes for direct use as
      # `boot.kernelPackages` in a consuming NixOS configuration.
      legacyPackages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          linuxPackages-tanix-tx6 = pkgs.linuxKernel.packagesFor (pkgs.callPackage ./armbian-kernel.nix { });
          linuxPackages-tanix-tx6-withHeaders = pkgs.linuxKernel.packagesFor (
            pkgs.callPackage ./armbian-kernel.nix { }
          );
          linuxPackages-tanix-tx6-latest = pkgs.linuxKernel.packagesFor (
            pkgs.callPackage ./armbian-kernel.nix {
              sourcesFile = ./sources-edge.nix;
            }
          );
          linuxPackages-tanix-tx6-latest-withHeaders = pkgs.linuxKernel.packagesFor (
            pkgs.callPackage ./armbian-kernel.nix {
              sourcesFile = ./sources-edge.nix;
            }
          );
        }
      );

      # For consuming this from another flake's own nixpkgs instance:
      #   nixpkgs.overlays = [ inputs.nix-tanix-tx6-armbian-kernel.overlays.default ];
      overlays.default = final: prev: {
        armbianKernelTanixTx6 = final.callPackage ./armbian-kernel.nix { };
        armbianKernelTanixTx6Edge = final.callPackage ./armbian-kernel.nix {
          sourcesFile = ./sources-edge.nix;
        };
        linuxPackages-tanix-tx6 = final.linuxKernel.packagesFor final.armbianKernelTanixTx6;
        linuxPackages-tanix-tx6-withHeaders = final.linuxPackages-tanix-tx6;
        linuxPackages-tanix-tx6-latest = final.linuxKernel.packagesFor final.armbianKernelTanixTx6Edge;
        linuxPackages-tanix-tx6-latest-withHeaders = final.linuxPackages-tanix-tx6-latest;
      };

      # Drop this straight into a NixOS config on the board:
      #   imports = [ inputs.nix-tanix-tx6-armbian-kernel.nixosModules.default ];
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.armbianKernel;
          kernel =
            if cfg.branch == "edge" then pkgs.armbianKernelTanixTx6Edge else pkgs.armbianKernelTanixTx6;
        in
        {
          options.armbianKernel = {
            branch = lib.mkOption {
              type = lib.types.enum [
                "stable"
                "edge"
              ];
              default = "stable";
              description = "Armbian kernel branch to install.";
            };

            headers.enable = lib.mkEnableOption "Armbian kernel headers";
          };

          config = {
            nixpkgs.overlays = [ self.overlays.default ];
            boot.kernelPackages =
              if cfg.branch == "edge" then pkgs.linuxPackages-tanix-tx6-latest else pkgs.linuxPackages-tanix-tx6;
            environment.systemPackages = lib.optional cfg.headers.enable kernel.dev;

            hardware.deviceTree = {
              enable = lib.mkDefault true;
              name = lib.mkDefault "allwinner/sun50i-h6-tanix-tx6.dtb";
            };
            hardware.enableRedistributableFirmware = lib.mkDefault true;
            zramSwap.enable = lib.mkDefault true;
            boot.loader.grub.enable = lib.mkDefault false;
            boot.loader.generic-extlinux-compatible = {
              enable = lib.mkDefault true;
              configurationLimit = lib.mkDefault 10;
              useGenerationDeviceTree = lib.mkDefault true;
            };
            boot.kernelParams = lib.mkAfter [ "video=HDMI-A-1:1920x1080@60" ];

            # Necessary because this kernel is repackaged from Armbian's
            # prebuilt binaries rather than built through nixpkgs' own kernel
            # machinery — see README for why.
            boot.initrd.includeDefaultModules = false;
            boot.initrd.systemd.enable = false;
          };
        };

      # `nix run .#update-sources` — check Armbian's repo for a newer build
      # and regenerate sources.nix with pinned URLs/hashes. Doesn't touch
      # any running system; just rewrites a text file for you to review.
      apps = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          update-sources = {
            type = "app";
            program = pkgs.lib.getExe (
              pkgs.writeShellApplication {
                name = "update-armbian-sources";
                runtimeInputs = with pkgs; [
                  curl
                  gzip
                  dpkg
                  gnused
                  gawk
                  coreutils
                  findutils
                  nix
                ];
                text = builtins.readFile ./update-sources.sh;
              }
            );
          };
        }
      );
    };
}
