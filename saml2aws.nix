{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "saml2aws-2.28.4";

  src = builtins.fetchurl {
    url =
      "https://github.com/Versent/saml2aws/releases/download/v2.28.4/saml2aws_2.28.4_linux_amd64.tar.gz";
    sha256 = "0dl26q7a0qkc3g30f92qaskh3fnqpnx8c04ik4havw3n397zz7nj";
  };

  phases = [ "installPhase" "patchPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    tar -xzvf $src -C $out
    mv $out/saml2aws $out/bin/saml2aws
    chmod +x $out/bin/saml2aws
  '';
}
