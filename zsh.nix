{ config, lib, pkgs, ... }:

let defaultAliases = {
            kubeami = "kubectl config current-context";
            ll = "ls -lah";
            wthr = "curl wttr.in";
            ghpr = "gh pr create";
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
            PATH="$HOME/.cargo/bin:$HOME/.jenv/bin:$GOBIN:$PATH";
        };
        history = {
            ignoreSpace = true;
            ignoreDups = true;
            extended = true;
            share = false;
            size = 100000;
            save = 100000;
        };
	profileExtra = ''
if [ -e ''$HOME/.nix-profile/etc/profile.d/nix.sh ]; then . ''$HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

export NIX_PATH=''$HOME/.nix-defexpr/channels''${NIX_PATH:+:}''$NIX_PATH
	'';
        initExtraBeforeCompInit = ''
            #eval "$(jenv init -)"
            [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
            source ~/.keys/github_api_token.bash
        '';
    };
}
