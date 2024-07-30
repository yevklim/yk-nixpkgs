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
  _overlay =
    final:
    prev:
    (
      builtins.mapAttrs
        (
          name:
          pkg:
          let
            package_exists = builtins.hasAttr name prev;
            prev_pkg = prev.${name};
          in
          if !package_exists # if package doesn't exists
          then pkg
          else
            (
              if !(prev.lib.isDerivation prev_pkg) # if package is not a derivation
              then builtins.throw ''Failed to overwrite "${name}". It's forbidden to overwrite a non-derivation with a derivation.''
              else
                (
                  let
                    version_comparison = builtins.compareVersions prev_pkg.version or (throw ''Package "${name}" doesn't have a version.'') pkg.version;
                  in
                  {
                    "-1" = pkg;
                    "0" = prev.lib.warn ''Package "${name}": original version matches the overwriting version "${pkg.version}"'' pkg;
                    "1" = prev_pkg;
                  }.${toString version_comparison}
                )
            )
        )
        _packages
    )
  ;
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
  overlay = _overlay;
}
