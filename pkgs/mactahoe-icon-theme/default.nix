{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
  hicolor-icon-theme,
  jdupes,
}:

# Not in nixpkgs. Packaged like the sibling whitesur-icon-theme
# (pkgs/by-name/wh/whitesur-icon-theme/package.nix): unlike the KDE
# theme's installer, this one already accepts a --dest flag rather than
# hardcoding /usr vs $HOME, so no UID/path patching is needed — just
# point it at $out/share/icons. install.sh installs the cursor theme
# (bundled in this same repo, under cursors/) as the last step of a
# normal run, so one invocation covers both icons and cursors.
stdenvNoCC.mkDerivation rec {
  pname = "mactahoe-icon-theme";
  version = "unstable-2026-08-29";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "MacTahoe-icon-theme";
    rev = "63cdd37ee8b629dc4dacc404b6695b93b84d930f";
    hash = "sha256-chsVKiRKh84drSXiIYmsNbyxi3cICtNF2fClBFNfK8c=";
  };

  nativeBuildInputs = [
    gtk3
    jdupes
  ];

  buildInputs = [ hicolor-icon-theme ];

  # These fixup steps are slow and unnecessary for a static icon set.
  dontPatchELF = true;
  dontRewriteSymlinks = true;
  dontDropIconThemeCache = true;

  postPatch = ''
    patchShebangs install.sh
  '';

  installPhase = ''
    runHook preInstall
    ./install.sh --dest $out/share/icons --name MacTahoe --theme blue
    jdupes --link-soft --recurse $out/share

    # install_cursors_scalable ignores --theme and always drops the cursor set
    # under the untinted "MacTahoe[-dark|-light]" names, leaving those dirs
    # with no index.theme or icon set of their own -- only "MacTahoe-blue-*"
    # got real icons. mactahoe-kde-theme's look-and-feel defaults hardcode
    # "MacTahoe-dark" as both Icons.Theme and cursorTheme (the name upstream's
    # own default -- non-blue -- install would have produced with icons and
    # cursors merged into one directory), so fold the cursor files into the
    # real (blue) icon theme under that name and alias it there instead of
    # leaving two half-populated theme directories plasma-apply-lookandfeel
    # can't resolve.
    for variant in dark light; do
      cp -r $out/share/icons/MacTahoe-$variant/cursors $out/share/icons/MacTahoe-blue-$variant/cursors
      cp -r $out/share/icons/MacTahoe-$variant/cursors_scalable $out/share/icons/MacTahoe-blue-$variant/cursors_scalable
      rm -rf $out/share/icons/MacTahoe-$variant
      ln -s MacTahoe-blue-$variant $out/share/icons/MacTahoe-$variant
    done

    runHook postInstall
  '';

  # Drop dangling symlinks from the upstream icon set.
  postFixup = ''
    find $out/share/icons -xtype l -delete
  '';

  meta = {
    description = "MacOS Tahoe style icon and cursor theme for Linux desktops";
    homepage = "https://github.com/vinceliuice/MacTahoe-icon-theme";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
