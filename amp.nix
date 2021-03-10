{ config, lib, pkgs, ... }:
{
    amp = {
        enableDefaults = true;
        home-manager.enable = false;
        niv.enable = false;
        jq.enable = false;
        git = {
            userName = "nhyne";
        };
    };
}