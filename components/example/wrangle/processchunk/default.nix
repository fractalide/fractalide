{ stdenv, buildFractalideSubnet, upkeepers
  , example_wrangle_processchunk_extract_keyvalue
  , example_wrangle_processchunk_iterate_paths
  , example_wrangle_processchunk_file_open
  , example_wrangle_processchunk_convert_json_vector
  , example_wrangle_processchunk_agg_chunk_triples
  , print_file_with_feedback
  ,...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   'value_string:(value="airline")' -> option extract_kvs(${example_wrangle_processchunk_extract_keyvalue})
   'list_triple:(triples = [])' -> acc aggregate_tuples(${example_wrangle_processchunk_agg_chunk_triples})

   input => input iterate_paths(${example_wrangle_processchunk_iterate_paths}) output ->
      input open_file(${example_wrangle_processchunk_file_open}) output ->
          input convert_json_vector(${example_wrangle_processchunk_convert_json_vector}) output ->
              input extract_kvs() output ->
                  input aggregate_tuples()
                            aggregate_tuples() next -> next iterate_paths()
                            aggregate_tuples() output => output
   '';

   meta = with stdenv.lib; {
    description = "Subnet: process some (10000 / fork-join ports) JSON files, demonstrating doing things in parallel.";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/processchunk;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ sjmackenzie];
  };
}
