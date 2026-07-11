{ stdenv, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "torrserver";
  version = "1.6.2";  # Проверь актуальную версию на GitHub
  src = fetchurl {
    url = "https://github.com/YouROK/TorrServer/releases/download/MatriX.136/TorrServer-linux-amd64";
    sha256 = "0igid20ym44cnd6r496mz3w84djp2yw82sy7c2qhfml2hp2wlyfw";  # Замени на hash (получи с nix-prefetch-url)
  };
  nativeBuildInputs = [ autoPatchelfHook ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/torrserver
    chmod +x $out/bin/torrserver
  '';
  meta = {
    description = "TorrServer for streaming torrents";
    homepage = "https://github.com/YouROK/TorrServer";
    platforms = [ "x86_64-linux" ];
  };
}
