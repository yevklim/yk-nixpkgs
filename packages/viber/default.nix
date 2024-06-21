{
  yevklim,

  appimageTools,
  fetchurl,
  lib,
  makeWrapper,
  ...
}:
let
  pname = "viber";
  version = "21.8.0.11";
  src = fetchurl {
    url = "https://web.archive.org/web/20240517170128/https://download.cdn.viber.com/desktop/Linux/viber.AppImage";
    hash = "sha256-re4VI2aW+vd8ImHt6UiRvjFZwy0zOI/eStVHljWoaDI=";
  };
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    cp -dR ${appimageContents}/usr/* $out/
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=Viber' 'Exec=${pname}'
    
    source "${makeWrapper}/nix-support/setup-hook"
    wrapProgram $out/bin/Viber \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath ["$out/lib"]} \
      --set PATH ${lib.makeBinPath ["$out/lib" "$out/lib/gstreamer-1.0"]} \
      --set QT_QPA_PLATFORM "xcb" \
      --set QT_PLUGIN_PATH "$out/plugins" \
      --set QML2_IMPORT_PATH "$out/qml"
  '';

  meta = {
    description = "Instant messaging and Voice over IP (VoIP) app";
    homepage = "https://www.viber.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ yevklim ];
    mainProgram = pname;
  };
}
