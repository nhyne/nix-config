{ pkgs, ... }:

let
  baseImports = [
    ./git.nix
    ./zsh.nix
    ./vim.nix
  ];
  goPath = "developer/go";

in {
  programs.home-manager.enable = true;

  imports = baseImports;

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.go = {
    enable = true;
    inherit goPath;
    goBin = "${goPath}/bin";
  };
  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };
# need to limit to linux
#  services.caffeine.enable = true;
}
