{ buildFractalideComponent, genName, filterContracts }:

buildFractalideComponent rec {
    name = genName ./.;
    src = ./.;
    contracts = filterContracts ["number"];
    depsSha256 = "0y9hpvx8dqbrypvdral9wrc4q84mvr0nc6w87ykzch3xnwxwbkkl";
}
