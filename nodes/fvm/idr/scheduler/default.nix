{ support, edges, mods }:

support.idr.agent {
  src = ./.;
  edges = with edges; [ ];
  mods = with mods.idr; [ prelude ];
}
