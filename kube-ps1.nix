{ }:
let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  tar = builtins.fetchTarball {
    url =
      "https://github.com/jonmosco/kube-ps1/archive/${lock.nodes.kube-ps1.locked.rev}.tar.gz";
    sha256 = lock.nodes.kube-ps1.locked.narHash;
  };
  file = builtins.readFile "${tar}/kube-ps1.sh";
in {
  ps1 = file;
}
