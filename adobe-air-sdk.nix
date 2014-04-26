{stdenv, fetchurl, file, which, patchelf,
 # i686 packages
 glibc, real_gcc, nss, qt3, nspr, zlib, libxml2, libxslt, ncurses, gtk2}:

stdenv.mkDerivation {
  name = "adobe-air-sdk";
  src = fetchurl {
    url = "http://airdownload.adobe.com/air/lin/download/latest/AdobeAIRSDK.tbz2";
    sha256 = "00bm024aqhljpyxf3fl40frffwisfjscqjhzvr4spjvvg732z4aq";
  };

  buildInputs = [file which patchelf
    nss qt3 nspr zlib libxml2 libxslt ncurses gtk2];

  dontPatchELF = 1;

  setSourceRoot = ''
    export sourceRoot=$PWD
  '';

  buildPhase = ''
    RPATH=$(echo $NIX_LDFLAGS |tr ' ' '\n'|grep '^-L'|sed 's/-L//'|tr '\n' ':')
    RPATH="$RPATH:$out/opt/adobe-air-sdk/runtimes/air/linux/Adobe AIR/Versions/1.0/Resources/"
    RPATH="$RPATH:${glibc}/lib/"
    RPATH="$RPATH:${real_gcc}/lib/"

    INTERPRETER=$(patchelf --print-interpreter $(which qmake))
    echo $(which qmake)
    echo $INTERPRETER

    find -type f | while read file; do
       if [[ "$file" != *.so ]]; then
         patchelf --set-interpreter "$INTERPRETER" "$file" || true
       fi
       patchelf --set-rpath "$RPATH" "$file" || true
     done
  '';

  # From https://aur.archlinux.org/packages/ad/adobe-air-sdk/PKGBUILD
  installPhase = ''
    SDK_HOME="$out/opt/adobe-air-sdk/"

    find . ! -name AdobeAIRSDK.tbz2 ! -name AIR\ SDK\ license.pdf | sed -e 's/\.\///g' | while read file; do
        if [ -d "$file" ]; then
            install -d "$SDK_HOME/$file"
        elif [ -h "$file" ]; then
            if [ $(file "$file" | grep 'broken' -c) = "0" ]; then
                ln -s $(echo $(file "$file" | grep -o -e \`[^\']*) | sed -e "s/\`//g") "$SDK_HOME/$file"
            fi
        else
            if [ -x "$file" ]; then
               mode=755
            else
               mode=644
            fi
            install -m "$mode" -D "$file" "$SDK_HOME/$file"
        fi
    done
    install -D -m644 ./AIR\ SDK\ license.pdf "$out"/usr/share/licenses/adobe-air-sdk/sdk-license.pdf

    # Helper for wrapping ld-loader sensitive binaries
    wrap_ld() {
      dynlinker="$(cat $NIX_GCC/nix-support/dynamic-linker)"
      binary="$1"

      wrapped="$(dirname "$binary")/.wrapped-$(basename "$binary")"

      mv "$binary" "$wrapped"

      cat > "$binary" <<EOF
#!${stdenv.shell}
$dynlinker "$wrapped" "\$@"
EOF
      chmod +x "$binary"
    }

    BINARIES=(
      "$SDK_HOME/lib/nai/bin/naip"
      "$SDK_HOME/bin/adl"
    )

    for binary in "''${BINARIES[@]}"; do
      wrap_ld "$binary"
    done
  '';
}