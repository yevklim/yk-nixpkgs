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
  mergeLib' =
    lib1:
    lib2:
    lib1 // lib2 // {
      maintainers = lib1.maintainers // lib2.maintainers;
    }
  ;
  mergeLib =
    lib1:
    lib2:
    lib1.extend (self: super: lib2 // {
      maintainers = lib1.maintainers / lib2.maintainers;
    })
  ;
  scope1 = pkgs.lib.makeScope pkgs.newScope (self: {
    lib = mergeLib pkgs.lib self.lib';
    lib' = self.callPackage ./lib { };
  });
  scope2 = pkgs.lib.makeScope scope1.newScope (
    self:
    let
      _packages = let inherit (self) callPackage; in rec {
        slack = callPackage ./packages/slack { };
        gendesk = callPackage ./packages/gendesk { };
        flashplayer = callPackage ./packages/flashplayer { };
        flashplayer-standalone = callPackage ./packages/flashplayer-standalone { };
        flashplayer-standalone-debugger = flashplayer-standalone.override {
          debug = true;
        };
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
    _packages // {
      inherit _packages;
      overlay =
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
            self._packages
        )
      ;
    }
  );

  mkPackagesByPlatform =
    packages:
    let
      stage1 = builtins.mapAttrs (name: pkg: { inherit name pkg; }) packages;
      stage2 = builtins.attrValues stage1;
      output = builtins.foldl'
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
        stage2;
    in
    output
  ;
in
{
  lib = scope1.lib';
  inherit (scope2) overlay;
  packages = mkPackagesByPlatform scope2._packages;
}
