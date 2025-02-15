{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  wrapGAppsHook3,
  intltool,
  itstool,
  libxml2,
  gobject-introspection,
  gtk3,
  goocanvas2,
  gtkspell3,
  isocodes,
  python3,
  tesseract4,
  extraOcrEngines ? [ ], # other supported engines are: ocrad gocr cuneiform
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocrfeeder";
  version = "0.8.5";

  src = fetchurl {
    url = "mirror://gnome/sources/ocrfeeder/${lib.versions.majorMinor finalAttrs.version}/ocrfeeder-${finalAttrs.version}.tar.xz";
    hash = "sha256-sD0qWUndguJzTw0uy0FIqupFf4OX6dTFvcd+Mz+8Su0=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    intltool
    itstool
    libxml2
    gobject-introspection
  ];

  postPatch = ''
    substituteInPlace configure \
      --replace-fail "import imp" "import importlib.util" \
      --replace-fail "imp.find_module" "importlib.util.find_spec" \
      --replace-fail "distutils" "setuptools._distutils"
  '';

  buildInputs = [
    gtk3
    goocanvas2
    gtkspell3
    isocodes
    (python3.withPackages (
      ps: with ps; [
        pyenchant
        sane
        pillow
        reportlab
        odfpy
        pygobject3
      ]
    ))
  ];
  patches = [
    # Compiles, but doesn't launch without this, see:
    # https://gitlab.gnome.org/GNOME/ocrfeeder/-/issues/83
    ./fix-launch.diff
  ];

  enginesPath = lib.makeBinPath (
    [
      tesseract4
    ]
    ++ extraOcrEngines
  );

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : "${finalAttrs.enginesPath}")
    gappsWrapperArgs+=(--set ISO_CODES_DIR "${isocodes}/share/xml/iso-codes")
  '';

  meta = {
    homepage = "https://gitlab.gnome.org/GNOME/ocrfeeder";
    description = "Complete Optical Character Recognition and Document Analysis and Recognition program";
    maintainers = with lib.maintainers; [ doronbehar ];
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
})
