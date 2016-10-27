{ stdenv, buildFractalideComponent, genName, openssl
  , path
  , domain_port
  , url
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ path domain_port url ];
  buildInputs = [ openssl ];
  depsSha256 = "1fp2b77h5cy9i9dm5b770anp8379nilmi8ffhagw3pxdnf7cccx0";

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
