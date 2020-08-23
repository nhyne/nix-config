{ pkgs, ... }:

{
    home.packages = with pkgs; [
        opam
        ocaml
    ];

    programs.opam = {
        enable = true;
        enableZshIntegration = true;
    };
}
