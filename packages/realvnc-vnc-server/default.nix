{ lib
, stdenv
, yevklim
, callPackage
}:
let
  pname = "realvnc-vnc-server";
  version = "7.12.0";

  meta = with lib; {
    description = "VNC remote desktop server software by RealVNC";
    homepage = "https://www.realvnc.com/en/connect/download/vnc/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = {
      fullName = "VNC Connect End User License Agreement";
      url = "https://static.realvnc.com/media/documents/LICENSE-4.0a_en.pdf";
      free = false;
    };
    maintainers = [ yevklim ];
    platforms = [ "x86_64-linux" ];
    hydraPlatforms = [];
    mainProgram = "vncviewer";
  };
in
if stdenv.isDarwin then (throw "Unsupported system: ${stdenv.hostPlatform.system}")
else callPackage ./linux.nix { inherit pname version meta; }
