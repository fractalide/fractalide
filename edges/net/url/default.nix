{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0x8c9f81d7489d6d29;

     struct Url {
             url @0 :Text;
     }
  '';
}
