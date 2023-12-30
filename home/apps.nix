{pkgs, ...}: {
  home.packages = with pkgs; [
    # インターネッツで遊ぶのに必要なものたち
    discord
    spotify
    slack
    parsec-bin
    floorp
    betterbird
    teams-for-linux
    libsForQt5.kclock

    # editor
    kate
    vscode

    # shell
    xonsh
    zoxide
    starship
    any-nix-shell

    gitAndTools.gh

    # misc
    pingu
    noisetorch
    appimage-run
  ];
  programs.obs-studio = {
    enable = true;
  };
}
