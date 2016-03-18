{ stdenv, buildFractalideSubnet, upkeepers
  , fetchurl , unzip
  , fs_dir_list
  , dt_vector_split_by_outarr_count
  , example_wrangle_processchunk
  , example_wrangle_aggregate_triple
  , example_wrangle_anonymize
  , example_wrangle_stats
  , example_wrangle_print
  ,...}:

  let
  example-data = stdenv.mkDerivation rec {
    name = "example-data";
    src = fetchurl {
      url = "https://gitlab.com/fractalide/example_data/repository/archive.zip?ref=master";
      sha256 = "133pya78qij3jp8r8a1klv6gvwhmqpa27nplvpf6297r2m427wsh";
    };
    buildInputs = [ unzip ];
    buildCommand = ''
    mkdir -p $out
    unzip $src
    mv example_data-master-*/data $out
    '';
  };
  in
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   'path:(path="${example-data}/data")' -> input list_dir(${fs_dir_list}) output ->
        input split(${dt_vector_split_by_outarr_count}) output[0] ->
            input procchunk0(${example_wrangle_processchunk}) output -> input[0] aggr_triples(${example_wrangle_aggregate_triple})
             split() output[1] -> input procchunk1(${example_wrangle_processchunk}) output -> input[1] aggr_triples()
             split() output[2] -> input procchunk2(${example_wrangle_processchunk}) output -> input[2] aggr_triples()
             split() output[3] -> input procchunk3(${example_wrangle_processchunk}) output -> input[3] aggr_triples()
             split() output[4] -> input procchunk4(${example_wrangle_processchunk}) output -> input[4] aggr_triples()
             split() output[5] -> input procchunk5(${example_wrangle_processchunk}) output -> input[5] aggr_triples()
             split() output[6] -> input procchunk6(${example_wrangle_processchunk}) output -> input[6] aggr_triples()
             split() output[7] -> input procchunk7(${example_wrangle_processchunk}) output -> input[7] aggr_triples()
             split() output[8] -> input procchunk8(${example_wrangle_processchunk}) output -> input[8] aggr_triples()
             split() output[9] -> input procchunk9(${example_wrangle_processchunk}) output -> input[9] aggr_triples() output ->
                input anonymize(${example_wrangle_anonymize}) output ->
                    input stats(${example_wrangle_stats}) output ->
                        input print(${example_wrangle_print})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Demonstrate processing some 10000 JSON files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ sjmackenzie];
  };
}

/*
                        */
