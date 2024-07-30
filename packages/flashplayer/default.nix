{ lib, callPackage, permitInsecurePackage ? false }:
let
  pname = "flashplayer";
  version = "32.0.0.465";

  meta = {
    description = "Adobe Flash Player Standalone (A.K.A. Adobe Flash Player Projector)";
    homepage = "https://web.archive.org/web/20211029204201/https://www.adobe.com/support/flashplayer/debug_downloads.html";
    license = {
      fullName = "ADOBE Personal Computer Software License Agreement";
      url = "https://web.archive.org/web/20240628135259/https://www.adobe.com/products/eulas/pdfs/PlatformClients_PC_WWEULA-MULTI-20110809_1357.pdf";
      free = false;
    };
    maintainers = [ lib.maintainers.yevklim ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
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

  final = callPackage ./linux.nix { inherit pname version meta; };
in final
