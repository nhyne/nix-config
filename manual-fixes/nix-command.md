When using a non-nixos machine you'll need to enable flakes and the nix-command by running the following:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```
