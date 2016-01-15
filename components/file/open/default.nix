{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["file" "path" "file_error"];
  depsSha256 = "1gdl266fp5pgr89yp5dpfbgkvqhcqg7ypjc0jpd9z81n447msg4j";
}
