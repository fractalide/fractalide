{ stdenv, buildFractalideSubnet, upkeepers
  , io_print
  , web_server
  # contracts
  , path
  , domain_port
  , url
  , generic_text
  , ...}:

let
doc = import ../../doc {};
in
buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
'${path}:(path="${doc}/share/doc/fractalide/")' -> www_dir www(${web_server})
'${domain_port}:(domainPort="localhost:8083")' -> domain_port www()
'${url}:(url="/docs")' -> url www()
'${generic_text}:(text="[*] serving: localhost:8083/docs/manual.html")' -> input disp(${io_print})
  '';

  meta = with stdenv.lib; {
    description = "Subnet: Fractalide manual";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/docs;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
