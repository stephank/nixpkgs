{ lib, stdenv, fetchFromGitHub, rustPlatform, openssl, libiconv, darwin }:

rustPlatform.buildRustPackage rec {
  pname = "sentry-cli";
  version = "1.62.0";

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "sentry-cli";
    rev = version;
    sha256 = "1a66yrfx4zl88x0iq2hyljb1a01zy8hb7p2y6gqlpb9r30q2b6wy";
  };

  cargoSha256 = "06gak97w90i65ralx39q0zf4sb7gimndickjp778njqnz0k3s87c";

  buildInputs =
    if stdenv.isDarwin then (with darwin.apple_sdk.frameworks; [ Security libiconv ])
    else [ openssl ];

  doCheck = false; # Fails because it expects to run from a git repository.

  meta = with lib; {
    description = "A command line utility to work with Sentry.";
    homepage = "https://gitlab.com/getsentry/sentry-cli";
    license = licenses.bsd3;
    maintainers = with maintainers; [ stephank ];
    platforms = platforms.unix;
  };
}
