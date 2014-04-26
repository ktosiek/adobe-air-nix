{stdenv, coreutils, unzip, adobe-air-sdk}:

stdenv.mkDerivation {
  name = "adobe-air-launcher";
  src = ./.;

  buildPhase = ''
    cp adobe-air-launcher.template adobe-air-launcher
    sed -i 's:@COREUTILS@:${coreutils}:g;
            s:@UNZIP@:${unzip}:g;
            s:@ADOBE_AIR_SDK_HOME@:${adobe-air-sdk}/opt/adobe-air-sdk:g' \
      adobe-air-launcher
  '';

  installPhase = ''
    install -D -m 755 adobe-air-launcher "$out/bin/adobe-air-launcher"
  '';
}