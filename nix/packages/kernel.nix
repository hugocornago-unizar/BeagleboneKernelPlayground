{ pkgs }:
pkgs.stdenv.mkDerivation(finalAttrs: {
	name = "kernel";
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
})
