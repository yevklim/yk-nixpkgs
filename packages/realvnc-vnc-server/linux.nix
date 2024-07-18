{ lib
, stdenv
, requireFile
, autoPatchelfHook
, dpkg
, xorg
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
      name = "VNC-Server-${finalAttrs.version}-Linux-${arch}.deb";
      url = "https://downloads.realvnc.com/download/file/vnc.files/${name}";
      inherit sha256;
      message= ''
        vnc-server can be downloaded from ${url},
        but the download link require captcha, thus if you wish to use this application,
        you need to download it manually and use follow command to add downloaded files into nix-store

        $ nix-prefetch-url --type sha256 file:///path/to/${name}
      '';
    };
  in {
    "x86_64-linux" = mkSource {
      arch = "x64";
      sha256 = "0vlbmkl0rf8xlzldm9gmx8nk4bxkz9c9dghnm9x4w1d52r1zwb63";
    };
    "aarch64-linux" = mkSource {
      arch = "ARM64";
      sha256 = "1xvxmz58j9y2qv7jangvila9k5gk3k1kn0c0ld2n87hl0carirfm";
    };
  }.${stdenv.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [ autoPatchelfHook dpkg copyDesktopItems ];
  buildInputs = [
    xorg.libX11
    xorg.libXext
    xorg.libXtst
    stdenv.cc.cc.libgcc or null
  ];

  desktopItems = [
    # (makeDesktopItem { # included in the rpm but not the deb package
    #   name = "realvnc-vncserver-scheme";
    #   desktopName = "VNC Viewer URL Handler";
    #   exec = "vncviewer -uri %u";
    #   mimeTypes = [ "x-scheme-handler/com.realvnc.vncviewer.connect" ];
    #   noDisplay = true;
    # })
  ];

  unpackPhase = ''
    dpkg --fsys-tarfile $src | tar --extract
  '';

  postPatch = ''
    # substituteInPlace ./usr/share/applications/realvnc-vncviewer.desktop \
    #   --replace-fail /usr/share/icons/hicolor/48x48/apps/vncviewer48x48.png vncviewer
    # substituteInPlace ./usr/share/mimelnk/application/realvnc-vncviewer-mime.desktop \
    #   --replace-fail /usr/share/icons/hicolor/48x48/apps/vncviewer48x48.png vncviewer
  '';

  installPhase = ''
    runHook preInstall

    mv usr $out

    runHook postInstall
  '';

  meta = meta // { mainProgram = "vncserver"; };
})
