{ component, contracts }:

component {
  src = ./.;
  contracts = with contracts; [ path value_string ];
  depsSha256 = "01fgc8ys3m54rmm7kn67jlxasc8h4n2vz33qhvq30rfjv7k8ggr2";
}
