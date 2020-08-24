{ pkgs, ... }:

{
    programs.neovim = with pkgs.vimPlugins; {
        enable = true;
        vimAlias = true;
        viAlias = true;
        vimdiffAlias = true;
        plugins = [
            ale
            vim-airline
            vim-airline-themes
            vim-polyglot
            zenburn
        ];
        extraConfig = ''
            syntax on
            colorscheme koehler
            set shell=bash\ --login
            set ruler
            set softtabstop=2
            set smarttab
            set autochdir
            set number
            set expandtab
            set tabstop=2
            set shiftwidth=2
        '';
    };
}
