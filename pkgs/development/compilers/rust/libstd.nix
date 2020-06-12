{ buildPackages, rust, rustc, rustPlatform, stdenv }: rustTarget:

stdenv.mkDerivation rec {
  pname = "libstd";
  inherit (rustc)
    version src nativeBuildInputs buildInputs patches postPatch postConfigure
    dontFixLibtool dontUseCmakeConfigure setOutputFlags
    dontUpdateAutotoolsGnuConfigScripts stripDebugList requiredSystemFeatures;

  # This is similar to the rustc configure flags, but we can't simply inherit
  # them, because we use a different `rustPlatform`. Notably, rustc needs to
  # build itself with the previous version, but here we're simply building
  # libstd with the current version.
  configureFlags = let
    setBuild  = "--set=target.${rust.toRustTarget stdenv.buildPlatform}";
    setHost   = "--set=target.${rust.toRustTarget stdenv.hostPlatform}";
    setTarget = "--set=target.${rust.toRustTarget stdenv.targetPlatform}";
    ccForBuild  = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc";
    cxxForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}c++";
    ccForHost  = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";
    cxxForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++";
    ccForTarget  = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";
    cxxForTarget = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++";
  in [
    "--release-channel=stable"
    "--set=build.rustc=${rustPlatform.rust.rustc}/bin/rustc"
    "--set=build.cargo=${rustPlatform.rust.cargo}/bin/cargo"
    "--enable-rpath"
    "--enable-vendor"
    "--build=${rust.toRustTarget stdenv.buildPlatform}"
    "--host=${rust.toRustTarget stdenv.hostPlatform}"
    "--target=${rust.toRustTarget stdenv.targetPlatform}"

    "${setBuild}.cc=${ccForBuild}"
    "${setHost}.cc=${ccForHost}"
    "${setTarget}.cc=${ccForTarget}"

    "${setBuild}.linker=${ccForBuild}"
    "${setHost}.linker=${ccForHost}"
    "${setTarget}.linker=${ccForTarget}"

    "${setBuild}.cxx=${cxxForBuild}"
    "${setHost}.cxx=${cxxForHost}"
    "${setTarget}.cxx=${cxxForTarget}"
  ];

  # We can use a stage0 build, because we're only rebuilding libstd for the
  # currently installed Rust compiler.
  buildPhase = ''
    python x.py build --stage 0 --target ${rustTarget} src/libstd
  '';

  installPhase = ''
    mv build/${rust.toRustTarget stdenv.hostPlatform}/stage0-sysroot $out
  '';
}
