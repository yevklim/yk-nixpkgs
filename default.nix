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
  packages = rec {
    jellyfin = callPackage ./packages/jellyfin { };
    jellyfin-web = callPackage ./packages/jellyfin-web { };

    slack = callPackage ./packages/slack { };
    gendesk = callPackage ./packages/gendesk { };
    flashplayer = callPackage ./packages/flashplayer { };
    yubioath-flutter = callPackage ./packages/yubioath-flutter { };
    realvnc-vnc-viewer = callPackage ./packages/realvnc-vnc-viewer { };

    newaita-reborn-icon-theme = callPackage ./packages/newaita-reborn-icon-theme { };
    papirus-newaita-icon-theme = callPackage ./packages/papirus-newaita-icon-theme { };
    viber = callPackage ./packages/viber { };

    ttf-ms-win11-auto = callPackage ./packages/ttf-ms-win11-auto { };
    ttf-ms-win11-auto-japanese = ttf-ms-win11-auto.japanese;
    ttf-ms-win11-auto-korean = ttf-ms-win11-auto.korean;
    ttf-ms-win11-auto-sea = ttf-ms-win11-auto.sea;
    ttf-ms-win11-auto-thai = ttf-ms-win11-auto.thai;
    ttf-ms-win11-auto-zh_cn = ttf-ms-win11-auto.zh_cn;
    ttf-ms-win11-auto-zh_tw = ttf-ms-win11-auto.zh_tw;
    ttf-ms-win11-auto-other = ttf-ms-win11-auto.other;

    wallpapers = callPackage ./packages/wallpapers { };
  };
in packages
