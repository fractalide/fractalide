{ buildFractalideContract, genName }:

buildFractalideContract rec {
    name = genName ./.;
    text = ./contract.capnp;
}

