{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
    name = genName ./.;
    src = ./.;
    contracts = filterContracts ["boolean"];
    depsSha256 = "0xia9d6iz8vymlljryk3f9q0pypb1jj1c8n37qwbzhsdrdzhd6g4";
}
