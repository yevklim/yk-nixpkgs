let
  inherit (builtins.fromJSON (builtins.readFile ./flake.lock)) nodes;
  # Fetch using flake lock, for legacy compat
  fromFlake = name:
    let inherit (nodes.${name}) locked;
    in builtins.getFlake "${locked.type}:${locked.owner}/${locked.repo}/${locked.rev}";
in
{ inputs ? {
    nixpkgs = fromFlake "nixpkgs";
  }
, nixpkgs ? inputs.nixpkgs
, pkgs ? import nixpkgs {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "qtwebengine-5.15.19" # for jellyfin-media-player
      ];
    };
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
        gendesk = callPackage ./packages/gendesk { };
        flashplayer-standalone = callPackage ./packages/flashplayer-standalone { };
        flashplayer-standalone-debugger = flashplayer-standalone.override {
          debug = true;
        };
        realvnc-vnc-viewer = pkgs.realvnc-vnc-viewer.overrideAttrs (prev: {
          postPatch =
            assert prev.version == "7.12.1";
            ''
              substituteInPlace ./usr/share/applications/realvnc-vncviewer.desktop \
                --replace-fail /usr/share/icons/hicolor/48x48/apps/vncviewer48x48.png vncviewer
              substituteInPlace ./usr/share/mimelnk/application/realvnc-vncviewer-mime.desktop \
                --replace-fail /usr/share/icons/hicolor/48x48/apps/vncviewer48x48.png vncviewer
            '';
        });
        jellyfin-media-player = pkgs.jellyfin-media-player.overrideAttrs (prev: {
          postInstall =
            assert prev.version == "1.12.0";
            prev.postInstall + pkgs.lib.optionalString pkgs.stdenv.isLinux  ''
              substituteInPlace $out/share/applications/com.github.iwalton3.jellyfin-media-player.desktop \
                --replace-fail "StartupWMClass=com.github.iwalton3.jellyfin-media-player" "StartupWMClass=${prev.meta.mainProgram}"
            '';
        });

        papirus-icon-theme = pkgs.papirus-icon-theme.overrideAttrs {
          version = "20250115";
          src = pkgs.fetchFromGitHub {
            owner = "yevklim";
            repo = "papirus-icon-theme";
            rev = "20250115";
            hash = "sha256-Eya94M41NK1Dtrde/jyYMq5GSoCcZt/pW04rjja1OmA=";
          };
        };
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
                        "0" = prev.lib.warn ''yk-nixpkgs.overlay: yk-nixpkgs."${name}".version == nixpkgs."${name}".version == "${pkg.version}". yk-nixpkgs."${name}" will overwrite nixpkgs."${name}".'' pkg;
                        "1" = prev.lib.warn ''nixpkgs."${name}" is newer (${prev_pkg.version}) than yk-nixpkgs."${name}" (${pkg.version}). yk-nixpkgs."${name}" will not overwrite nixpkgs."${name}".'' prev_pkg;
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
