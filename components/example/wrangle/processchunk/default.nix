{ stdenv, buildFractalideSubnet, upkeepers
  , dt_vector_extract_keyvalue
  , example_wrangle_processchunk_iterate_paths
  , fs_file_open
  , example_wrangle_processchunk_convert_json_vector
  , example_wrangle_processchunk_aggregate_tuple
  ,...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   // receive 1000 paths
   // convert each path into kv_list
   // send out kv_list

   // IIP
   'value_string:(value="airline")' -> option extract_kvs(${dt_vector_extract_keyvalue})

   input => input iterate_paths(${example_wrangle_processchunk_iterate_paths}) output ->
      input open_file(${fs_file_open}) output -> input convert_json_vector(${example_wrangle_processchunk_convert_json_vector}) output ->
        input extract_kvs() output ->
          input aggregate_tuples(${example_wrangle_processchunk_aggregate_tuple})
   aggregate_tuples() next -> next iterate_paths()
   aggregate_tuples() output => output
   '';

   meta = with stdenv.lib; {
    description = "Subnet: process 1000 of the 10000 JSON files, demonstrating doing things in parallel.";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/processchunk;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ sjmackenzie];
  };
}
