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
    settings = {
        character.symbol = "➜";
        character.error_symbol = "✗";
        git_branch.style = "bold green";
        package.disabled = true;
        golang.symbol = "";
        kubernetes.disabled = true;
        kubernetes.symbol = "";
        ocaml.symbol = "";
        rust.symbol = "";
        java.disabled = true;
        aws.disabled = true;
        python.disabled = true;
        ruby.disabled = true;
        nodejs.disabled = true;
    };
  };
}
