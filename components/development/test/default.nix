{ stdenv, buildFractalideSubnet, upkeepers
  , web_server
  , maths_boolean_not
  , maths_boolean_and
  , maths_boolean_print
  , ...}:

let
doc = import ../../../doc {};
in
buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
'path:(path="${doc}/share/doc/fractalide/manual.html")' -> www_dir www(${web_server})
'domain_port:(domainPort="localhost:8080")' -> domain_port www()
'url:(url="/docs")' -> url www()

'maths_boolean:(boolean="true"' -> input not(${maths_boolean_not}) output -> input disp(${maths_boolean_print})

'maths_boolean:(boolean="true"' -> a and(${maths_boolean_and}) output -> input disp()
'maths_boolean:(boolean="true"' -> b and()
  '';

  meta = with stdenv.lib; {
    description = "Subnet: development testing file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
