{
  description = "Armbian kernel + dtb + headers for the Tanix TX6, packaged as a Nix flake (AC200 Ethernet fix)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # `nix build .#armbian-kernel-tanix-tx6` — build the kernel standalone.
      # Note: this only extracts pre-built ARM binaries (dpkg-deb -x + cp),
      # it doesn't compile anything, so it builds fine on an x86_64 host too
      # (e.g. in CI) without needing QEMU/binfmt cross-compilation support.
      packages.${system} = {
        armbian-kernel-tanix-tx6 = pkgs.callPackage ./armbian-kernel.nix { };
        default = self.packages.${system}.armbian-kernel-tanix-tx6;
      };

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
      apps.${system}.update-sources = {
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
    };
}
