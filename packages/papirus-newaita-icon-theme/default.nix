{
  lib,
  stdenvNoCC,
  gitUpdater,

  newaita-reborn-icon-theme,

  kdePackages,
  gtk3,
  hicolor-icon-theme,
  papirus-icon-theme,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "papirus-newaita-icon-theme";
  version = "${papirus-icon-theme.version}+${newaita-reborn-icon-theme.version}";

  src = ./src;

  nativeBuildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    newaita-reborn-icon-theme
    papirus-icon-theme
    kdePackages.breeze-icons
    hicolor-icon-theme
  ];

  dontDropIconThemeCache = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    mv ./* $out/

    ln -s "${papirus-icon-theme}/share/icons/Papirus-Dark" "$out/share/icons/Papirus-Dark"
    ln -s "${newaita-reborn-icon-theme}/share/icons/Newaita-reborn-dark" "$out/share/icons/Newaita-reborn-dark"
    ln -s "${newaita-reborn-icon-theme}/share/icons/Newaita-reborn-nord-dark" "$out/share/icons/Newaita-reborn-nord-dark"

    for theme in $out/share/icons/Papirus-Newaita/*; do
      gtk-update-icon-cache --force $theme
    done

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "papirus icon theme + newaita-reborn folders";
    homepage = "<none>";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.yevklim ];
  };
}