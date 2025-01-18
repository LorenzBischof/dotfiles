{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kmod,
  ...
}:

stdenv.mkDerivation rec {
  name = "asustor-platform-driver-${version}-${kernel.version}";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "mafredri";
    repo = "asustor-platform-driver";
    rev = "9ae2030a88b7d22f7eea6a1c537ffb54a8d5ed1e";
    hash = "sha256-T7v7a27zligDU1h4Kv77B0Iv9x69zvWECpsgUIoiYc4=";
  };
  #src = ./.;

  hardeningDisable = [
    "pic"
    "format"
  ];
  # Install kmod for depmod dependency if we need it
  #nativeBuildInputs = kernel.moduleBuildDependencies ++ [ kmod ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildFlags = [
    "KERNEL_MODULES=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
  ];
  installFlags = [
    "KERNEL_MODULES=${placeholder "out"}/lib/modules/${kernel.modDirVersion}"
  ];

  # TODO: check if we need depmod.
  preConfigure = ''
    sed -i 's|depmod|#depmod|' Makefile
    sed -i 's|/usr/bin/install|install|' Makefile
  '';

  meta = with lib; {
    description = "A kernel module to support Asustor devices";
    homepage = "https://github.com/mafredri/asustor-platform-driver";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
