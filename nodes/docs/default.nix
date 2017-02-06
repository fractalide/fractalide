{ subgraph, imsgs, nodes, edges }:

let
  doc = import ../../doc {};
in
subgraph rec {
  src = ./.;
  imsg = imsgs {
    edges = with edges; [ FsPath NetProtocolDomainPort NetUrl PrimText];
  };
  flowscript = with nodes; ''
    '${imsg}.FsPath:(path="${doc}/share/doc/fractalide/")' -> www_dir www(${web_server})
    '${imsg}.NetProtocolDomainPort:(domainPort="localhost:8083")' -> domain_port www()
    '${imsg}.NetUrl:(url="/docs")' -> url www()
    '${imsg}.PrimText:(text="[*] serving: localhost:8083/docs/manual.html")' -> input disp(${io_print})
  '';
}
