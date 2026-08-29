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
