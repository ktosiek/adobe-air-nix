let
  nixpkgs = import <nixpkgs> {};
in with nixpkgs; rec {
   adobe-air-sdk = with pkgsi686Linux; callPackage ./adobe-air-sdk.nix {
     gtk2 = gnome.gtk;
     real_gcc = gcc.gcc;
   };

   adobe-air-launcher = callPackage ./adobe-air-launcher.nix {
     inherit adobe-air-sdk;
   };
}