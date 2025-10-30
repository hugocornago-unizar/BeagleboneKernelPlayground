{
  pkgs,
  pkgsCross,
}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  name = "uboot";
  src = pkgs.fetchFromGitHub {
    owner = "u-boot";
    repo = "u-boot";
    tag = "v2023.10";
    hash = "sha256-f0xDGxTatRtCxwuDnmsqFLtYLIyjA5xzyQcwfOy3zEM=";
  };

  buildInputs = with pkgs; [
    flex
    bison
    openssl
    bc
    pkgsCross.gcc9Stdenv.cc
    (hiPrio gcc9)
  ];

  dontFixup = true;

  buildPhase = ''
    runHook preBuild

    export hardeningDisable=all
    export CROSS_COMPILE=armv7l-unknown-linux-gnueabihf-
    export DEVICE_TREE=am335x-boneblack
    make -j$(nproc) am335x_evm_defconfig
    make -j$(nproc)

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';
})
