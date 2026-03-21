{
  lib,
  stdenv,
  fetchFromGitHub,
  openblasCompat,
  opennec,
  pkg-config,
  gfortran,
  runCommand
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "OpenNEC";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "maurymarkowitz";
    repo = "OpenNEC";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Cue0i9tT+7tEAX+WAGp5HkZ5jC3LNqs2+ySK8z3e1Z4=";
  };

  # BUILD.md says "use OpenBLAS for best performance".  It is supposed
  # to autodetect OpenBLAS, but we can specify it here to be sure.
  buildPhase = ''
    make clean
    make BACKEND=openblas
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/doc/onec $out/share/man/1
    cp onec $out/bin/
    cp LICENSE doc/* $out/share/doc/onec/
    cp -r test $out/share/doc/onec/test
    mv $out/share/doc/onec/onec.1 $out/share/man/1
  '';

  nativeBuildInputs = [
    openblasCompat
    pkg-config
    gfortran
  ];

  buildInputs = [
  ];

  passthru.tests = {
    simple = runCommand "${pname}-test" { } ''
      cp -r ${src}/ src
      chmod -R u+w src
      ${opennec}/bin/onec ${src}/test/example5.deck -o example5.out
      touch $out
    '';
  };

  meta = {
    description = "Antenna simulation library and command-line tool";
    longDescription = ''OpenNEC is an implementation of the NEC-2 code
      written in the C programming language. It is used to simulate
      the reception and transmission patterns of radio frequency
      antennas.
    '';
    homepage = "https://github.com/maurymarkowitz/OpenNEC";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      pdg137
    ];
  };
})
