{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

# Not in nixpkgs. Packaged the same way nixpkgs packages the sibling
# whitesur-kde theme (pkgs/by-name/wh/whitesur-kde/package.nix): the
# upstream install.sh branches on `$UID` to decide whether to write to
# /usr/share/... (root) or $HOME/.local/share/... (user) — neither of
# which is a sensible target from inside a Nix build. Forcing the root
# branch and substituting /usr -> $out turns the imperative installer
# into a normal build that drops files under $out/share/{color-schemes,
# plasma/{desktoptheme,look-and-feel},Kvantum,aurorae/themes,wallpapers}.
stdenvNoCC.mkDerivation rec {
  pname = "mactahoe-kde-theme";
  version = "unstable-2026-08-16";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "MacTahoe-kde";
    rev = "cbf6a1f71b591d143184855d62f6272ce533e7c3";
    hash = "sha256-atdHgr9pCfg/VE8GGWF+4MZu6nRmVCz9TiylVATAwzs=";
  };

  postPatch = ''
    patchShebangs install.sh

    substituteInPlace install.sh \
      --replace-fail '"$UID" -eq "$ROOT_UID"' true \
      --replace-fail /usr $out
  '';

  installPhase = ''
    runHook preInstall
    # stdenv exports $name (pname-version) as an env var, which shadows
    # the script's own name-or-THEME_NAME default — clear it so the
    # theme lands as "MacTahoe*", not the store-path derivation name.
    name= ./install.sh
    runHook postInstall
  '';

  meta = {
    description = "MacOS Tahoe like theme for KDE Plasma desktop";
    homepage = "https://github.com/vinceliuice/MacTahoe-kde";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
