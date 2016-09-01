{ stdenv, buildFractalideSubnet, upkeepers
  , fetchurl , unzip
  , fs_dir_list
  , ip_clone
  , dt_vector_split_by_outarr_count
  , example_wrangle_processchunk
  , example_wrangle_aggregate
  , example_wrangle_anonymize
  , example_wrangle_stats
  , example_wrangle_print
  # contracts
  , list_triple
  , path
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
    '${list_triple}:(triples = [])' -> acc aggr_triples(${example_wrangle_aggregate})

   '${path}:(path="${example-data}/data")' -> input list_dir(${fs_dir_list}) output ->
        input split(${dt_vector_split_by_outarr_count}) output[0] ->
            input procchunk0(${example_wrangle_processchunk}) output -> input[0] aggr_triples()
            // better to daisy chain, it's unfair allocation but better fits the programming paradigm
            // this example mainly demonstrates the ease of parallelism and concurrency in fractalide
             split() output[1] -> input procchunk1(${example_wrangle_processchunk}) output -> input[1] aggr_triples()
             split() output[2] -> input procchunk2(${example_wrangle_processchunk}) output -> input[2] aggr_triples()
             split() output[3] -> input procchunk3(${example_wrangle_processchunk}) output -> input[3] aggr_triples()
             split() output[4] -> input procchunk4(${example_wrangle_processchunk}) output -> input[4] aggr_triples()
             split() output[5] -> input procchunk5(${example_wrangle_processchunk}) output -> input[5] aggr_triples()
             split() output[6] -> input procchunk6(${example_wrangle_processchunk}) output -> input[6] aggr_triples()
             split() output[7] -> input procchunk7(${example_wrangle_processchunk}) output -> input[7] aggr_triples()
             split() output[8] -> input procchunk8(${example_wrangle_processchunk}) output -> input[8] aggr_triples()
             split() output[9] -> input procchunk9(${example_wrangle_processchunk}) output -> input[9] aggr_triples()
             split() output[10] -> input procchunk10(${example_wrangle_processchunk}) output -> input[10] aggr_triples()
             split() output[11] -> input procchunk11(${example_wrangle_processchunk}) output -> input[11] aggr_triples()
             split() output[12] -> input procchunk12(${example_wrangle_processchunk}) output -> input[12] aggr_triples()
             split() output[13] -> input procchunk13(${example_wrangle_processchunk}) output -> input[13] aggr_triples()
             split() output[14] -> input procchunk14(${example_wrangle_processchunk}) output -> input[14] aggr_triples()
             split() output[15] -> input procchunk15(${example_wrangle_processchunk}) output -> input[15] aggr_triples()
             split() output[16] -> input procchunk16(${example_wrangle_processchunk}) output -> input[16] aggr_triples()
             split() output[17] -> input procchunk17(${example_wrangle_processchunk}) output -> input[17] aggr_triples()
             split() output[18] -> input procchunk18(${example_wrangle_processchunk}) output -> input[18] aggr_triples()
             split() output[19] -> input procchunk19(${example_wrangle_processchunk}) output -> input[19] aggr_triples()
             split() output[20] -> input procchunk20(${example_wrangle_processchunk}) output -> input[20] aggr_triples()
             split() output[21] -> input procchunk21(${example_wrangle_processchunk}) output -> input[21] aggr_triples()
             split() output[22] -> input procchunk22(${example_wrangle_processchunk}) output -> input[22] aggr_triples()
             split() output[23] -> input procchunk23(${example_wrangle_processchunk}) output -> input[23] aggr_triples()
             split() output[24] -> input procchunk24(${example_wrangle_processchunk}) output -> input[24] aggr_triples()
             split() output[25] -> input procchunk25(${example_wrangle_processchunk}) output -> input[25] aggr_triples()
             split() output[26] -> input procchunk26(${example_wrangle_processchunk}) output -> input[26] aggr_triples()
             split() output[27] -> input procchunk27(${example_wrangle_processchunk}) output -> input[27] aggr_triples()
             split() output[28] -> input procchunk28(${example_wrangle_processchunk}) output -> input[28] aggr_triples()
             split() output[29] -> input procchunk29(${example_wrangle_processchunk}) output -> input[29] aggr_triples()
             split() output[30] -> input procchunk30(${example_wrangle_processchunk}) output -> input[30] aggr_triples()
             split() output[31] -> input procchunk31(${example_wrangle_processchunk}) output -> input[31] aggr_triples()
             split() output[32] -> input procchunk32(${example_wrangle_processchunk}) output -> input[32] aggr_triples()
             split() output[33] -> input procchunk33(${example_wrangle_processchunk}) output -> input[33] aggr_triples()
             split() output[34] -> input procchunk34(${example_wrangle_processchunk}) output -> input[34] aggr_triples()
             split() output[35] -> input procchunk35(${example_wrangle_processchunk}) output -> input[35] aggr_triples()
             split() output[36] -> input procchunk36(${example_wrangle_processchunk}) output -> input[36] aggr_triples()
             split() output[37] -> input procchunk37(${example_wrangle_processchunk}) output -> input[37] aggr_triples()
             split() output[38] -> input procchunk38(${example_wrangle_processchunk}) output -> input[38] aggr_triples()
             split() output[39] -> input procchunk39(${example_wrangle_processchunk}) output -> input[39] aggr_triples()
             split() output[40] -> input procchunk40(${example_wrangle_processchunk}) output -> input[40] aggr_triples()
             split() output[41] -> input procchunk41(${example_wrangle_processchunk}) output -> input[41] aggr_triples()
             split() output[42] -> input procchunk42(${example_wrangle_processchunk}) output -> input[42] aggr_triples()
             split() output[43] -> input procchunk43(${example_wrangle_processchunk}) output -> input[43] aggr_triples()
             split() output[44] -> input procchunk44(${example_wrangle_processchunk}) output -> input[44] aggr_triples()
             split() output[45] -> input procchunk45(${example_wrangle_processchunk}) output -> input[45] aggr_triples()
             split() output[46] -> input procchunk46(${example_wrangle_processchunk}) output -> input[46] aggr_triples()
             split() output[47] -> input procchunk47(${example_wrangle_processchunk}) output -> input[47] aggr_triples()
             split() output[48] -> input procchunk48(${example_wrangle_processchunk}) output -> input[48] aggr_triples()
             split() output[49] -> input procchunk49(${example_wrangle_processchunk}) output -> input[49] aggr_triples()
             aggr_triples() output ->
             input clone(${ip_clone}) clone[anonymous] -> input anonymize(${example_wrangle_anonymize}) output ->
                anonymous stats(${example_wrangle_stats}) anonymous -> anonymous print(${example_wrangle_print})
             clone() clone[raw] -> raw stats() raw -> raw print()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Demonstrate processing some 10000 JSON files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ sjmackenzie];
  };
}
