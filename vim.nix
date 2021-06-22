{ pkgs, lib, ... }:

{
  programs.neovim = with pkgs.vimPlugins; {
    enable = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    plugins = [
      ale
      nerdtree
      vim-airline
      zenburn
    ];
    extraConfig = lib.fileContents ./vimrc;
  };
}
