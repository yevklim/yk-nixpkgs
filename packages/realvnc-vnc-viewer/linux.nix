{ lib
, stdenv
, requireFile
, autoPatchelfHook
, dpkg
, libX11
, libXext
, pname
, version
, meta
, makeDesktopItem
, copyDesktopItems
}:

stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  src = let
    mkSource = { arch, sha256 }: requireFile rec {
      name = "VNC-Viewer-${finalAttrs.version}-Linux-${arch}.deb";
      url = "https://downloads.realvnc.com/download/file/viewer.files/${name}";
      inherit sha256;
      message= ''
        vnc-viewer can be downloaded from ${url},
        but the download link require captcha, thus if you wish to use this application,
        you need to download it manually and use follow command to add downloaded files into nix-store

        $ nix-prefetch-url --type sha256 file:///path/to/${name}
      '';
    };
  in {
    "x86_64-linux" = mkSource {
      arch = "x64";
      sha256 = "sha256-ptBA2jWmjw1q6kvBxwoAv/R/7l8GxfeMPifnGm6+mvg=";
    };
    "aarch64-linux" = mkSource { # rpm is not available for aarch64
      arch = "ARM64";
      sha256 = "sha256-WoeAE1/lLUbkdA91TE9Qu3VEn4xcsd75o+442Mrizcs=";
    };
  }.${stdenv.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [ autoPatchelfHook dpkg copyDesktopItems ];
  buildInputs = [ libX11 libXext stdenv.cc.cc.libgcc or null ];

  desktopItems = [
    (makeDesktopItem { # included in the rpm but not the deb package
      name = "realvnc-vncviewer-scheme";
      desktopName = "VNC Viewer URL Handler";
      exec = "vncviewer -uri %u";
      mimeTypes = [ "x-scheme-handler/com.realvnc.vncviewer.connect" ];
      noDisplay = true;
    })
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  postPatch = ''
    substituteInPlace ./usr/share/applications/realvnc-vncviewer.desktop \
      --replace-fail /usr/share/icons/hicolor/48x48/apps/vncviewer48x48.png vncviewer
    substituteInPlace ./usr/share/mimelnk/application/realvnc-vncviewer-mime.desktop \
      --replace-fail /usr/share/icons/hicolor/48x48/apps/vncviewer48x48.png vncviewer
  '';

  installPhase = ''
    runHook preInstall

    mv usr $out

    runHook postInstall
  '';

  meta = meta // { mainProgram = "vncviewer"; };
})
