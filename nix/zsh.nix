{ config, lib, pkgs, ... }:

let shellAliases = {
            kubeami = "kubectl config current-context";
            zhistfix = "mv ~/.zsh_history ~/.zsh_history_bad; strings ~/.zsh_history_bad > ~/.zsh_history; fc -R ~/.zsh_history; rm ~/.zsh_history_bad;";
            ll = "ls -lah";
            wthr = "curl wttr.in";
            ghpr = "hub pull-request -p";
            pbcopy = "xclip -selection clipboard";
	        pbpaste = "xclip -selection clipboard -o";
        };
in
{
    home.packages = with pkgs; [
        xclip # for clipboard use
    ];

    programs.zsh = {
        enable = true;
        autocd = true;
        inherit shellAliases;
        enableCompletion = true;
        oh-my-zsh = {
            enable = true;
            theme = "robbyrussell";
        };
        sessionVariables = {
            EDITOR="vim";
            SDKMAN_DIR="$HOME/.sdkman";
            GOPATH="$HOME/developer/go";
            PATH="$HOME/.jenv/bin:$GOPATH/bin:$PATH";
        };
        history = {
            ignoreSpace = true;
            ignoreDups = true;
            extended = true;
            share = false;
            size = 100000;
            save = 100000;
        };
        initExtraBeforeCompInit = ''
            #eval "$(jenv init -)"
            [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
            source ~/.keys/github_api_token.bash
        '';
    };
}
