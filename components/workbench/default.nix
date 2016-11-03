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
    rev = "04292f7a020a9f700a48fb805536b8b05da3267b";
    sha256 = "03m7mr3j27msk3jnnb317kymw6v1b3gm1131mpx20lb9q6rg8rkz";
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
