{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "CentRa-Linux";
    userEmail = "centra-linux@protonmail.com";
  };

  programs.gh = {
    enable = true;
    extensions = with pkgs; [gh-markdown-preview]; # オススメ
    settings = {
      editor = "nano";
    };
  };
}
