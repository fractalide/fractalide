{ stdenv, buildFractalideSubnet, upkeepers
  , file_open
  , file_print
  , io_print
  , serialize_json_decode_extractKVfromVec
  , accumulate_keyValues
  ,...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
  'path:(path="/home/stewart/Downloads/deleteme/data/1032.json")' -> input file_open(${file_open}) output ->
      input get_airline(${serialize_json_decode_extractKVfromVec}) output -> input lb(${accumulate_keyValues}) output -> input io_print(${io_print})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: testing file for sjm";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/test/sjm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
