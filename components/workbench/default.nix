{ pkgs
  , support
  , contracts
  , components
  , stdenv
  , buildFractalideSubnet
  , fetchFromGitHub
  , generic_text
  , ...}:
  let
  repo = fetchFromGitHub {
    owner = "dmichiels";
    repo = "frac_net_http";
    rev = "064c5a2cec0c1bdf189339bbeac272ece0cad2d5";
    sha256 = "1fy0zwkfzyxxkpyb1ljcp0dkbcapli5gwkkdlcrwkbfss7fgihws";
  };
  /* repo = /home/denis/dev/frac/frac_net_hyper;*/
  net_http = import repo {inherit pkgs support contracts components; fractalide = null;};
in
   buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   net_http(${net_http.http})
   '${net_http.c_address}:(address="0.0.0.0:8000")' -> listen net_http()

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
