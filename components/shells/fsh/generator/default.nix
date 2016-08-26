{ stdenv, buildFractalideSubnet, upkeepers
  , shells_fsh_generator_nix
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input generator(${shells_fsh_generator_nix}) output => output
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Fractalide Shell";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
