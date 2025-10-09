
{ pkgs }:
pkgs.stdenv.mkDerivation(finalAttrs: {
	name = "bb-flash-utilities";
	src = ./.;
	buildInputs = [ pkgs.bash ];

	# scripts.makekernel = pkgs.writeShellScriptBin {
	# 	name = "makekernel";
	# 	text = builtins.readFile ./makekernel.sh;
	# 	executable = true;
	# 	destination = "/bin/makekernel";
	# };
	#
	# scripts.flashkernel = pkgs.writeShellScriptBin {
	# 	name = "flashkernel";
	# 	text = builtins.readFile ./flashkernel.sh;
	# 	executable = true;
	# 	destination = "/bin/flashkernel";
	# };

	phases = ["installPhase"];
	installPhase = ''
		mkdir -p $out/bin
		cp makekernel.sh $out/bin/makekernel
		cp flashkernel.sh $out/bin/flashkernel
		chmod +x $out/bin/*
	'';
})
