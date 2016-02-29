{ stdenv, buildFractalideComponent, filterContracts, genName, openssl, ...}:
let

  tls-openssl = stdenv.lib.overrideDerivation openssl (oldAttrs : {
    NIX_CFLAGS_COMPILE = " -fPIC -DPIC";
    });
in
buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["path" "domain_port" "url"];
  buildInputs = [ tls-openssl ];
  depsSha256 = "1hlznyvzhz19miif03khzvldxp2w3b2wm0qb7n1ppr0lb707z12s";

  meta = with stdenv.lib; {
    description = "Component:  web_server";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/web/server;
    longDescription = "Component: web_server
    example usage:
    'path:(path="/path/to/some/index.html")' -> www_dir www(web_server)
    'domain_port:(domainPort="localhost:8080")' -> domain_port www()
    'url:(url="/docs")' -> url www()
    ";
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
