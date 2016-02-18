{ stdenv, buildFractalideComponent, filterContracts, genName, openssl, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["path" "domain_port" "url"];
  buildInputs = [ openssl ];
  depsSha256 = "1lbh2lxkj7lz92595y1msk6g0yq2kj8mrd48r4s3yiay13fp79iy";

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
