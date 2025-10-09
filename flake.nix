{
  description = "Kernel Build Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		flake-parts.url = "github:hercules-ci/flake-parts";
  };

	outputs = inputs@{ flake-parts, ... }:
		flake-parts.lib.mkFlake { inherit inputs; } {
			systems = [ "x86_64-linux" "aarch64-darwin" ];
			perSystem = { config, pkgs, system, ...}:
			let
				pkgsCross = import inputs.nixpkgs {
					localSystem = system;
					crossSystem = { config = "armv7l-unknown-linux-gnueabihf"; };
				};
			in
			{
				packages.kernel = pkgs.callPackage ./nix/kernel.nix {};
				packages.uboot = pkgs.callPackage ./nix/uboot.nix { pkgsCross = pkgsCross; };
				packages.flash-utils = pkgs.callPackage ./nix/scripts/package.nix {};

				devShells.default = pkgs.mkShell {
					buildInputs = with pkgs;
						[
							pkg-config
							ncurses
							qt5.qtbase
							pkgsCross.gcc9Stdenv.cc
							(hiPrio gcc9)
						]
						++ pkgs.linux.nativeBuildInputs;

						packages = [ config.packages.uboot config.packages.flash-utils ];
						shellHook = ''
										export ARCH=arm
										export hardeningDisable=all
										export CROSS_COMPILE=armv7l-unknown-linux-gnueabihf-
										export PKG_CONFIG_PATH="${pkgs.ncurses.dev}/lib/pkgconfig:${pkgs.qt5.qtbase.dev}/lib/pkgconfig"
										export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/lib/qt-${pkgs.qt5.qtbase.version}/plugins"
										export QT_QPA_PLATFORMTHEME=qt5ct
										[[ -d ./kernel ]] || {
										 cp -r ${config.packages.kernel} kernel
										 chmod -R +w kernel
										}
										exec zsh
						'';
				};
			};
		};
}
