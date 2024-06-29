{ lib
, stdenvNoCC
, requireFile
, undmg
, pname
, version
, meta
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version meta;

  src = requireFile rec {
      name = "VNC-Viewer-${finalAttrs.version}-MacOSX-universal.dmg";
      url = "https://downloads.realvnc.com/download/file/viewer.files/${name}";
      sha256 = "sha256-haD2QsBF9Dps1V/2tkkALAc7+kUY3PSNj7BjTIqnNcU=";
      message= ''
        vnc-viewer can be downloaded from ${url},
        but the download link require captcha, thus if you wish to use this application,
        you need to download it manually and use follow command to add downloaded files into nix-store

        $ nix-prefetch-url --type sha256 file:///path/to/${name}
      '';
  };
  sourceRoot = ".";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';
})
