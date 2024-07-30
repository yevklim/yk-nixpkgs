{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "wallpapers";
  version = "2024-07-05";

  src = fetchFromGitHub {
    owner = "yevklim";
    repo = "wallpapers";
    rev = "8ce455a0f50fc6fb9185d10693b967b88cba7963";
    hash = "sha256-+mDgXv8L67CdNEbQla5jvrJUSwGBtt392OTnIxCMqj8=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/backgrounds
    cp -dR ./* $out/share/backgrounds
    runHook postInstall
  '';

  meta = {
    description = "YK's collection of wallpapers";
    homepage = "https://github.com/yevklim/wallpapers";
    platforms = lib.platforms.all;
  };
}
