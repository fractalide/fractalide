{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xd9a3ed03c95db4cc;

     struct ValueString {
         value @0 :Text;
     }
  '';
}
