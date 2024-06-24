{
  lib,
  buildGoModule,
  fetchFromGitHub,
  testers,
  spicetify-cli,
}:

buildGoModule rec {
  pname = "spicetify-cli";
  version = "2.36.13";

  src = fetchFromGitHub {
    owner = "spicetify";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-0etyVzYL8F1GOAHEcpSfOoKe3GsGmAqVufVauqPDV1w=";
  };

  vendorHash = "sha256-po0ZrIXtyK0txK+eWGZDEIGMI1/cwyLVsGUVnTaHKP0=";

  ldflags = [
    "-s -w"
    "-X 'main.version=${version}'"
  ];

  postInstall = ''
    mv $out/bin/cli $out/bin/spicetify
    ln -s $out/bin/spicetify $out/bin/spicetify-cli

    # Used at runtime, but not installed by default
    cp -r ${src}/{jsHelper,CustomApps,Extensions,Themes} $out/bin/
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/spicetify --help > /dev/null
  '';

  passthru.tests.version = testers.testVersion { package = spicetify-cli; };

  meta = {
    description = "Command-line tool to customize Spotify client";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      jonringer
      mdarocha
    ];
    mainProgram = "spicetify";
  };
}
