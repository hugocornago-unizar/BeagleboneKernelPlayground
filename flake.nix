{
  description = "Kernel Build Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    pkgsCross = import nixpkgs {
      system = "x86_64-linux";
      crossSystem = {config = "armv7l-unknown-linux-gnueabihf";};
    };

    kernel-sources = pkgs.stdenv.mkDerivation {
      name = "kernel-sources";
      src = pkgs.fetchzip {
        url = "https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-6.5.2.tar.xz";
        hash = "sha256-nXEtRgQZPX76aYpjYUcmBo+VrlPeyIMKyFP0tQIgHZM=";
      };

      rtpatch = pkgs.fetchurl {
        url = "https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.5/patch-6.5.2-rt8.patch.xz";
        hash = "sha256-9zFDuMnH1t6nSnrEONqFe8G7bwiq32F8z7pGTyspISo=";
      };

      phases = ["unpackPhase" "buildPhase" "installPhase"];

      buildPhase = ''
        # apply rtpatch
        xzcat $rtpatch | patch -p1
      '';

      installPhase = ''
        mkdir -p $out
        cp -r * $out
      '';
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs;
        [
          pkg-config
          ncurses
          qt5.qtbase
          # new gcc usually causes issues with building kernel so use an old
          # one
          pkgsCross.gcc9Stdenv.cc
          (hiPrio gcc9)
        ]
        ++ pkgs.linux.nativeBuildInputs;

      shellHook = ''
              export ARCH=arm
              export hardeningDisable=all
              export CROSS_COMPILE=armv7l-unknown-linux-gnueabihf-
              export PKG_CONFIG_PATH="${pkgs.ncurses.dev}/lib/pkgconfig:${pkgs.qt5.qtbase.dev}/lib/pkgconfig"
              export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/lib/qt-${pkgs.qt5.qtbase.version}/plugins"
              export QT_QPA_PLATFORMTHEME=qt5ct
							[[ -d ./kernel ]] || {
							 cp -r ${kernel-sources} kernel
							 chmod -R +w kernel
							}
              exec zsh
      '';
    };
  };
}
