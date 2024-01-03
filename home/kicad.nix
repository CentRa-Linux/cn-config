{pkgs, ...}: {
  home.packages = with pkgs; {
    kicad,
    kicadAddons.kikit,
    kicadAddons.kikit-library,
    kikit
  };
}
