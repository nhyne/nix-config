{ pkgs, lib, ... }:

{
    programs.neovim = with pkgs.vimPlugins; {
        enable = true;
        vimAlias = true;
        viAlias = true;
        vimdiffAlias = true;
        plugins = [
            ale
            vim-airline
            coc-metals
            coc-nvim
            zenburn
        ];
        extraConfig = lib.fileContents ./vimrc;
    };
}
