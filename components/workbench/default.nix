{ pkgs
  , support
  , contracts
  , components
  , stdenv
  , buildFractalideSubnet
  , fetchFromGitHub
  , generic_text
  , net_http_address
  , ...}:
  let
  repo = fetchFromGitHub {
    owner = "fractalide";
    repo = "frac_net_http";
    rev = "6bb7246d18d420b57a7c8e1f67bd7bafbfb7b19f";
    sha256 = "14z603f2g2niphsqhclnzkr7i6nx8f3db1dci9h7vy5dq5fmb27j";
  };
  /*
  repo = /home/denis/dev/frac/frac_net_hyper;
  */
  net_http = import repo {inherit pkgs support contracts components; fractalide = null;};
in
   buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   net_http(${net_http.http})
   '${net_http_address}:(address="0.0.0.0:8000")' -> listen net_http()

   '${generic_text}:(text="Hello world")' -> option world(${net_http.raw_text})
   '${generic_text}:(text="Hello fractalide")' -> option fractalide(${net_http.raw_text})
   '${generic_text}:(text="Hello fractalide with ID")' -> option fractalideID(${net_http.raw_text})
   '${generic_text}:(text="Hello fractalide with Post!")' -> option fractalideP(${net_http.raw_text})

   net_http() GET[^/$] -> input world() output -> response net_http()
   net_http() GET[^/frac] -> input fractalide() output -> response net_http()
   net_http() GET[^/frac/.+] -> input fractalideID() output -> response net_http()

   net_http() POST[/frac] -> input fractalideP() output -> response net_http()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
