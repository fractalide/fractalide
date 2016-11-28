{ subnet, components, contracts }:

let
  doc = import ../../doc {};
in
subnet  {
  src = ./.;
  subnet = ''
  '${path}:(path="${doc}/share/doc/fractalide/")' -> www_dir www(${web_server})
  '${domain_port}:(domainPort="localhost:8083")' -> domain_port www()
  '${url}:(url="/docs")' -> url www()
  '${generic_text}:(text="[*] serving: localhost:8083/docs/manual.html")' -> input disp(${io_print})
  '';
}
