{ pkgs, ... }:

let plugins = [
    "junegunn/vim-easy-align"
];
in
{
    programs.vim = {
        enable = true;
        settings = {
            number = true;
            expandtab = true;
            tabstop = 2;
            shiftwidth = 2;
        };
        extraConfig = ''
            set shell=bash\ --login
            filetype off
            colorscheme koehler
            :set ruler
            :set softtabstop=2
            :set smarttab
            :set autochdir
        '';
    };
}
