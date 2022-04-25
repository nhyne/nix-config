{ pkgs, lib, ... }:

{
  programs.neovim = with pkgs.vimPlugins; {
    enable = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    plugins = [
      ale
      idris2-vim
      nerdtree
      vim-airline
      vim-go
      vim-scala
      vim-terraform
      zenburn
    ];
    extraConfig = lib.fileContents ./vimrc;
  };
}
