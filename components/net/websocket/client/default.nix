{ stdenv, buildFractalideComponent, genName, upkeepers
  , protocol_domain_port
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ protocol_domain_port ];
  depsSha256 = "1fmgksz1ps2cwd5s76bvk14w79dm7a08ks8rmd5lhd11yhlb8p11";
  meta = with stdenv.lib; {
    description = "Component: Socket input";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/in;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
