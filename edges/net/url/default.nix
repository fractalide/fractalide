{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct Url {
           url @0 :Text;
    }
  '';
}
