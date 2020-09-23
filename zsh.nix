{ config, lib, pkgs, ... }:

let defaultAliases = {
            kubeami = "kubectl config current-context";
            ll = "ls -lah";
            wthr = "curl wttr.in";
            ghpr = "hub pull-request -p";
        };
        linuxAliases = {
          pbcopy = "xclip -selection clipboard";
	        pbpaste = "xclip -selection clipboard -o";
        };
        shellAliases = if (builtins.currentSystem == "x86_64-darwin")
            then defaultAliases else defaultAliases // linuxAliases;
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
            plugins = [
                "kubectl"
            ];
        };
        sessionVariables = {
            EDITOR="vim";
            SDKMAN_DIR="$HOME/.sdkman";
            PATH="$HOME/.jenv/bin:$GOBIN:$PATH";
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
