{ pname
, version
, meta

, stdenv
, fetchurl
, buildFHSEnv
, makeDesktopItem
, copyDesktopItems

, alsa-lib
, curl
, curlWithGnuTls
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk2
, libGL
, libgcc
, libvdpau
, nspr
, nss
, pango
, pulseaudio
, systemd
, xorg
}:
let
  src = fetchurl {
    url = "https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flash_player_sa_linux.x86_64.tar.gz";
    hash = "sha256-iD96ojMB/IDeh5UBFXUzpKzb/uByHtfFdnbcAy/flsM=";
    name = "${pname}-${version}.tar.gz";
  };
  sourceRoot = ".";
  exec = stdenv.mkDerivation {
    inherit pname version src sourceRoot;
    installPhase = ''
      runHook preInstall
      install -Dm755 "flashplayer" "$out"
      runHook postInstall
    '';
  };
  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Adobe Flash Player Standalone";
    genericName = "Flash Player";
    comment = "Player for using content created on the Adobe Flash platform";
    exec = pname;
    icon = pname;
    categories = [ "Audio" "AudioVideo" "Graphics" "GTK" "Player" "Video" "Viewer" ];
    mimeTypes = [ "application/x-shockwave-flash" ];
  };
  buildInputs = [
    alsa-lib
    curl
    curlWithGnuTls
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk2
    libGL
    libgcc
    libvdpau
    nspr
    nss
    pango
    pulseaudio
    systemd
    xorg.libX11
    xorg.libXcursor
    xorg.libXrender
  ];
  fhsenv = buildFHSEnv {
    inherit pname version;
    runScript = exec;
    multiPkgs = pkgs: buildInputs;
  };
  final = stdenv.mkDerivation (finalAttrs: {
    inherit pname version src sourceRoot buildInputs meta;
    nativeBuildInputs = [ copyDesktopItems ];
    desktopItems = [ desktopItem ];
    installPhase = ''
      runHook preInstall
      install -Dm755 "${fhsenv}/bin/${pname}" "$out/bin/${pname}"
      runHook postInstall
    '';
  });
in final
