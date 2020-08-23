{ pkgs, ... }:

let goPath = "developer/go";
in
{
    home.packages = with pkgs; [
        go
    ];

    programs.go = {
        enable = true;
        inherit goPath;
        goBin = "${goPath}/bin";
    };
}
