{ buildFractalideSubnet, genName, ...}:

buildFractalideSubnet rec {
    name = genName ./.;
    text = ./lib.subnet;
}
