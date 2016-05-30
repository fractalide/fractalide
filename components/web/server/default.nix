{ stdenv, buildFractalideComponent, filterContracts, genName, openssl, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["path" "domain_port" "url"];
  buildInputs = [ openssl ];
  depsSha256 = "1d0vsvj85fdw1fpqk5k477l1asy6kcp3zj9k2b8gm34xhgap2xv6";

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
