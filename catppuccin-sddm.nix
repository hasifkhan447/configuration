{ pkgs }:

pkgs.stdenv.mkDerivation {
	name = "catppuccin-sddm";

	src = pkgs.fetchFromGitHub {
		owner = "catppuccin";
		repo = "sddm";
		rev = "v1.0.0";
		sha256 = "SdpkuonPLgCgajW99AzJaR8uvdCPi4MdIxS5eB+Q9WQ=";

	};
	installPhase= ''
		mkdir -p $out
		cp -R ./* $out/
	'';
}
