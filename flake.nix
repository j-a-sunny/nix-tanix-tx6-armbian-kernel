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
          default = pkgs.callPackage ./armbian-kernel.nix { };
        }
      );

      # For consuming this from another flake's own nixpkgs instance:
      #   nixpkgs.overlays = [ inputs.nix-tanix-tx6-armbian-kernel.overlays.default ];
      overlays.default = final: prev: {
        armbianKernelTanixTx6 = final.callPackage ./armbian-kernel.nix { };
      };

      # Drop this straight into a NixOS config on the board:
      #   imports = [ inputs.nix-tanix-tx6-armbian-kernel.nixosModules.default ];
      nixosModules.default =
        { pkgs, ... }:
        {
          nixpkgs.overlays = [ self.overlays.default ];
          boot.kernelPackages = pkgs.linuxPackagesFor pkgs.armbianKernelTanixTx6;

          # Necessary because this kernel is repackaged from Armbian's
          # prebuilt binaries rather than built through nixpkgs' own kernel
          # machinery — see README for why.
          boot.initrd.includeDefaultModules = false;
          boot.initrd.systemd.enable = false;
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
