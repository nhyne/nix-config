{ pkgs, ... }:

{
  programs.nushell = {
    enable = true;
    settings = {
      edit_mode = "vi";
      completion_mode = "circular";
      no_auto_pivot = true;
      use_starship = true;
    };
  };

  programs.starship = {
    enable = true;
  };
}
