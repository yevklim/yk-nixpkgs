{
  yevklim,

  lib,
  buildGoModule,
  fetchurl,

  ...
}:
buildGoModule rec {
  pname = "gendesk";
  version = "1.0.10";

  src = fetchurl {
    url = "https://gendesk.roboticoverlords.org/${pname}-${version}.tar.xz";
    hash = "sha256-MVzJw0iu+F7t/znHdLA6isU0EkasO7UDZWb/eufY2ug=";
  };

  vendorHash = null;

  meta = {
    description = "Utility for generating desktop files by specifying a minimum of information";
    homepage = "https://gendesk.roboticoverlords.org/";
    license = lib.licenses.mit;
    maintainers = [ yevklim ];
    platforms = [ "x86_64-linux" ];
  };
}
