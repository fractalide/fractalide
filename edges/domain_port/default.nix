{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    @0xbb7b3123b414d4bb;

     struct DomainPort {
             domainPort @0 :Text;
     }
  '';
}
