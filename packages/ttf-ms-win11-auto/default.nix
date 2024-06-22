{
  yevklim,

  lib,
  stdenvNoCC,
  fetchgit,
  fetchurl,

  pacman,
  libarchive,
  gnupatch,
  fakeroot,
  sudo,
  coreutils,
  zstd,

  udisks,
  p7zip,
  httpdirfs,

  ...
}:
let
  arch-pkg = {
    version = "10.0.22631.2428";
    release = "2";
    revision = "aee165d1396b34000b07294d36f9c19812a186f7";
    revision-hash = "sha256-3QZP5j/q/BTwBLSULVACKJ7DRVh3w/wxKEOZc1Fo9Io=";
    makedepends = [ udisks p7zip httpdirfs ];
    iso-url = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso";
    iso-hash = "sha256-yNvJa2HQTIsB+vbOB5T98zllx7NQ6qPrHmaXAZkClFw=";
  };
  iso-file = fetchurl {
    url = arch-pkg.iso-url;
    hash = arch-pkg.iso-hash;
  };
  patch-file = ./PKGBUILD.patch;
in
stdenvNoCC.mkDerivation rec {
  pname = "ttf-ms-win11-auto";
  version = "${arch-pkg.version}-${arch-pkg.release}";

  src = fetchgit {
    url = "https://aur.archlinux.org/ttf-ms-win11-auto.git";
    rev = arch-pkg.revision;
    hash = arch-pkg.revision-hash;
  };

  nativeBuildInputs = [ pacman libarchive gnupatch fakeroot sudo zstd ] ++ arch-pkg.makedepends;

  dontPatch = true;
  dontConfigure = true;
  # dontBuild = true;
  doCheck = false;
  dontFixup = true;

  outputs = [
    "out"
    "japanese"
    "korean"
    "sea"
    "thai"
    "zh_cn"
    "zh_tw"
    "other"
  ];

  buildPhase = ''
    patch -u ./PKGBUILD -i ${patch-file}
    substituteInPlace ./PKGBUILD \
      --replace-fail "makedepends=(udisks2 p7zip httpdirfs)" "makedepends=()" \
      --replace-fail "/usr/bin/true" "${coreutils}/bin/true" \
      --replace-fail '_iso="${arch-pkg.iso-url}"' '_iso="file://${iso-file}";_iso_file="${iso-file}"'
    MAKEPKG_CONF="${pacman}/etc/makepkg.conf" makepkg
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/truetype/      pkg/${pname}/usr/share/fonts/TTF/*
    install -Dm644 -t $japanese/share/fonts/truetype/ pkg/${pname}-japanese/usr/share/fonts/TTF/*
    install -Dm644 -t $korean/share/fonts/truetype/   pkg/${pname}-korean/usr/share/fonts/TTF/*
    install -Dm644 -t $sea/share/fonts/truetype/      pkg/${pname}-sea/usr/share/fonts/TTF/*
    install -Dm644 -t $thai/share/fonts/truetype/     pkg/${pname}-thai/usr/share/fonts/TTF/*
    install -Dm644 -t $zh_cn/share/fonts/truetype/    pkg/${pname}-zh_cn/usr/share/fonts/TTF/*
    install -Dm644 -t $zh_tw/share/fonts/truetype/    pkg/${pname}-zh_tw/usr/share/fonts/TTF/*
    install -Dm644 -t $other/share/fonts/truetype/    pkg/${pname}-other/usr/share/fonts/TTF/*

    install -Dm644 -t $out/share/licenses/${pname}/               pkg/${pname}/usr/share/licenses/${pname}/*
    install -Dm644 -t $japanese/share/licenses/${pname}-japanese/ pkg/${pname}-japanese/usr/share/licenses/${pname}-japanese/*
    install -Dm644 -t $korean/share/licenses/${pname}-korean/     pkg/${pname}-korean/usr/share/licenses/${pname}-korean/*
    install -Dm644 -t $sea/share/licenses/${pname}-sea/           pkg/${pname}-sea/usr/share/licenses/${pname}-sea/*
    install -Dm644 -t $thai/share/licenses/${pname}-thai/         pkg/${pname}-thai/usr/share/licenses/${pname}-thai/*
    install -Dm644 -t $zh_cn/share/licenses/${pname}-zh_cn/       pkg/${pname}-zh_cn/usr/share/licenses/${pname}-zh_cn/*
    install -Dm644 -t $zh_tw/share/licenses/${pname}-zh_tw/       pkg/${pname}-zh_tw/usr/share/licenses/${pname}-zh_tw/*
    install -Dm644 -t $other/share/licenses/${pname}-other/       pkg/${pname}-other/usr/share/licenses/${pname}-other/*

    runHook postInstall
  '';

  meta = {
    description = "Microsoft Windows 11 TrueType fonts";
    homepage = "https://aur.archlinux.org/packages/ttf-ms-win11-auto";
    license = lib.licenses.unfree;
    maintainers = [ yevklim ];
    platforms = lib.platforms.all;
    outputsToInstall = outputs;
  };
}
