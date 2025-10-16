{pkgs}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  name = "bb-flash-utilities";
  src = ./.;
  buildInputs = [pkgs.bash];

  phases = ["unpackPhase" "installPhase"];
  installPhase = ''
    mkdir -p $out/bin
    cp makekernel.sh $out/bin/makekernel
    chmod +x $out/bin/*
  '';
})
