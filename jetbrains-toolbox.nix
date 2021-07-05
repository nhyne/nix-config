{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "jetbrains-toolbox-1.20";

  src = pkgs.fetchurl {
    url = "https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.20.8804.tar.gz";
    sha256 = "3b76620cbe5118b457931cfb4605ca4d8df488f543a1b8c63f63214500872e5d";
  };

  phases = ["installPhase" "patchPhase"];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/jetbrains-toolbox
    chmod +x $out/bin/jetbrains-toolbox
  '';
}
