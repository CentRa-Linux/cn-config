{
  imports = [
    ./apps.nix
    ./git.nix
    ./xonsh.nix
    ./starship.nix
  ];
  home = rec {
    username="centra";
    homeDirectory = "/home/${username}";
    stateVersion = "23.11";
  };
  programs.home-manager.enable = true;
}
