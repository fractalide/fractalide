{ subgraph, nodes, edges }:

let
  doc = import ../../doc {};
in
subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
    '${fs_path}:(path="${doc}/share/doc/fractalide/")' -> www_dir www(${web_server})
    '${net_protocol_domain_port}:(domainPort="localhost:8083")' -> domain_port www()
    '${net_url}:(url="/docs")' -> url www()
    '${prim_text}:(text="[*] serving: localhost:8083/docs/manual.html")' -> input disp(${io_print})
  '';
}
