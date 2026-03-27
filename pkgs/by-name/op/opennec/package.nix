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
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "maurymarkowitz";
    repo = "OpenNEC";
    # tag = "v${finalAttrs.version}";
    rev = "cc709f6243f6fefde1dc9b8205cf3895045e8cc4";
    hash = "sha256-leAk1Gy3V5vMqRmv9WTMglJBZdUWBflzaAeVccueZ/g=";
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
      set -e
      cp -r ${src}/ src
      chmod -R u+w src
      pass=1
      for file in `find ${src}/test/ -name '*.nec' -or -name '*.deck'`
      do
        echo Testing $file...
        if ${opennec}/bin/onec $file -o `basename $file`.out
        then
          pass=0
          echo FAIL
          echo
        else
          echo PASS
          echo
        fi
      done
      if [ $pass -eq 1 ]
      then
        touch $out
      fi
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
