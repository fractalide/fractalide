{ subgraph, imsg, nodes, edges }:

let
  doc = import ../../../doc {};
  FsPath = imsg {
    class = edges.FsPath;
    text = ''(path="${doc}/share/doc/fractalide/")'';
  };
  NetProtocolDomainPort = imsg {
    class = edges.NetProtocolDomainPort;
    text = ''(domainPort="localhost:8083")'';
  };
  NetUrl = imsg {
    class = edges.NetUrl;
    text = ''(url="/docs")'';
  };
  PrimText = imsg {
    class = edges.PrimText;
    text = ''(text="[*] serving: localhost:8083/docs/manual.html")'';
  };
in
subgraph {
  src = ./.;
  flowscript = with nodes.rs; ''
    '${FsPath}' -> www_dir www(${web_server})
    '${NetProtocolDomainPort}' -> domain_port www()
    '${NetUrl}' -> url www()
    '${PrimText}' -> input disp(${io_print})
  '';
}
