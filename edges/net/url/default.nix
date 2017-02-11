{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct NetUrl {
           url @0 :Text;
    }
  '';
}
