We're not using flakes for windows, just home-manager via

```shell
home-manager switch -f home.nix
```

This means that the pkgs available are based on the nix-channel nixpkgs which can be updated with

```shell
nix-channel --update
```