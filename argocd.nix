{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "argocd-1.8.7";

  src = pkgs.fetchurl {
    url = "https://github.com/argoproj/argo-cd/releases/download/v1.8.7/argocd-linux-amd64";
    sha256 = "1ac6p6zi1ai7mabiij3xg688b5vpxapwhn6y0wmz5mvc5n2f8ap5";
  };

  phases = ["installPhase" "patchPhase"];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/argocd
    chmod +x $out/bin/argocd
  '';
}
