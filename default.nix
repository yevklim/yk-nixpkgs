{
  pkgs ? import <nixpkgs> {
    system = "x86_64-linux";
    config.allowUnfree = true;
  },
  ...
}:
let 
  yevklim = {
    name = "yevklim";
    email = "64846678+yevklim@users.noreply.github.com";
    github = "yevklim";
    githubId = 64846678;
  };
  maintainers = {
    inherit yevklim;
  };
  callPackage = pkgs.lib.callPackageWith (pkgs // packages // maintainers);
  packages = {
    newaita-reborn-icon-theme = callPackage ./packages/newaita-reborn-icon-theme { };
    papirus-newaita-icon-theme = callPackage ./packages/papirus-newaita-icon-theme { };
    viber = callPackage ./packages/viber { };
  };
in packages
