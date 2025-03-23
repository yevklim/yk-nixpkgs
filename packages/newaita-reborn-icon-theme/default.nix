{
  fetchFromGitHub,
  gitUpdater,
  lib,
  stdenvNoCC,

  kdePackages,
  gtk3,
  hicolor-icon-theme,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "newaita-reborn-icon-theme";
  version = "5b19f46a4ca918585038547b27810502a5997401";

  src = fetchFromGitHub {
    owner = "yevklim";
    repo = pname;
    rev = version;
    hash = "sha256-nA0l+xH9BlxID0lsXkojKvQRZgkJulSWsRinDre0oW8=";
  };

  nativeBuildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    kdePackages.breeze-icons
    hicolor-icon-theme
  ];

  dontWrapQtApps = true;
  dontDropIconThemeCache = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    mv Newaita-reborn* $out/share/icons

    for theme in $out/share/icons/*; do
      gtk-update-icon-cache --force $theme
    done

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "newaita-reborn-icon-theme";
    homepage = "https://github.com/yevklim/newaita-reborn";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.yevklim ];
  };
}