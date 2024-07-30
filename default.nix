{ inputs ? {
    nixpkgs = <nixpkgs>;
  }
, nixpkgs ? inputs.nixpkgs
, pkgs ? import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  }
, ...
}:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // _packages // {
    lib = pkgs.lib // _lib // {
      maintainers = pkgs.lib.maintainers // _maintainers;
    };
  });
  _maintainers.yevklim = {
    name = "yevklim";
    email = "64846678+yevklim@users.noreply.github.com";
    github = "yevklim";
    githubId = 64846678;
  };
  _lib = {
    mkAutostartEntries = callPackage ./lib/mk-autostart-entries.nix { };
  };
  _packages = rec {
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
in
{
  lib = _lib;
  packages =
    let
      _1 = builtins.mapAttrs (name: pkg: { inherit name pkg; }) _packages;
      _2 = builtins.attrValues _1;
      _3 = builtins.foldl'
        (
          final:
          { name, pkg }:
          final // (
            pkgs.lib.genAttrs
              pkg.meta.platforms
              (
                platform:
                final.${platform} or { } // {
                  ${name} = pkg;
                }
              )
          )
        )
        { }
        _2;
    in
    _3
  ;
  # builtins.groupBy
}
