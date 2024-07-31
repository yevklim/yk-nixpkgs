{ stdenv
, lib
, fetchurl
, alsaLib
, atk
, bzip2
, cairo
, curl
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, glibc
, graphite2
, gtk2
, harfbuzz
, libICE
, libSM
, libX11
, libXau
, libXcomposite
, libXcursor
, libXdamage
, libXdmcp
, libXext
, libXfixes
, libXi
, libXinerama
, libXrandr
, libXrender
, libXt
, libXxf86vm
, libdrm
, libffi
, libglvnd
, libpng
, libvdpau
, libxcb
, libxshmfence
, nspr
, nss
, pango
, pcre
, pixman
, zlib
, unzip
, makeDesktopItem
, copyDesktopItems
, debug ? false
, permitInsecurePackage ? false
}:
let
  mainProgram = "flashplayer${lib.optionalString debug "debugger"}";
in
stdenv.mkDerivation {
  pname = "flashplayer-standalone";
  version = "32.0.0.465";

  src = fetchurl {
    url =
      if debug then
        "https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flash_player_sa_linux_debug.x86_64.tar.gz"
      else
        "https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flash_player_sa_linux.x86_64.tar.gz";
    hash =
      if debug then
        "sha256-GtvR8t8TDG9qXp1NoeI1E+bGgu7sDJFTvxe8vsofSsY="
      else
        "sha256-iD96ojMB/IDeh5UBFXUzpKzb/uByHtfFdnbcAy/flsM=";
  };

  nativeBuildInputs = [ unzip copyDesktopItems ];

  sourceRoot = ".";

  dontStrip = true;
  dontPatchELF = true;

  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -pv ${mainProgram} $out/bin

    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "$rpath" \
      $out/bin/${mainProgram}

    runHook postInstall
  '';

  rpath = lib.makeLibraryPath
    [
      stdenv.cc.cc
      alsaLib
      atk
      bzip2
      cairo
      curl
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      glibc
      graphite2
      gtk2
      harfbuzz
      libICE
      libSM
      libX11
      libXau
      libXcomposite
      libXcursor
      libXdamage
      libXdmcp
      libXext
      libXfixes
      libXi
      libXinerama
      libXrandr
      libXrender
      libXt
      libXxf86vm
      libdrm
      libffi
      libglvnd
      libpng
      libvdpau
      libxcb
      libxshmfence
      nspr
      nss
      pango
      pcre
      pixman
      zlib
    ];

  desktopItems = [
    (makeDesktopItem {
      name = mainProgram;
      desktopName = "Adobe Flash Player Standalone${lib.optionalString debug " - Debugger"}";
      genericName = "Flash Player";
      comment = "Player for using content created on the Adobe Flash platform";
      exec = mainProgram;
      icon = "flashplayer";
      categories = [ "Audio" "AudioVideo" "Graphics" "GTK" "Player" "Video" "Viewer" ];
      mimeTypes = [ "application/x-shockwave-flash" ];
    })
  ];

  meta = {
    description = "Adobe Flash Player standalone executable";
    homepage = "https://web.archive.org/web/20211029204201/https://www.adobe.com/support/flashplayer/debug_downloads.html";
    license = {
      fullName = "ADOBE Personal Computer Software License Agreement";
      url = "https://web.archive.org/web/20240628135259/https://www.adobe.com/products/eulas/pdfs/PlatformClients_PC_WWEULA-MULTI-20110809_1357.pdf";
      free = false;
    };
    maintainers = with lib.maintainers; [ yevklim ];
    platforms = [ "x86_64-linux" ];
    inherit mainProgram;
    knownVulnerabilities = lib.optionals (!permitInsecurePackage) [
      "CVE-2005-4708"
      "CVE-2008-1654"
      "CVE-2008-3873"
      "CVE-2010-0209"
      "CVE-2010-2213"
      "CVE-2010-2214"
      "CVE-2010-2215"
      "CVE-2010-2216"
      "CVE-2020-9746"
      "https://nvd.nist.gov/vuln/search/results?form_type=Advanced&results_type=overview&isCpeNameSearch=true&seach_type=all&query=cpe:2.3:a:adobe:flash_player:32.0.0.433:*:*:*:*:*:*:*"
    ];
  };
}
