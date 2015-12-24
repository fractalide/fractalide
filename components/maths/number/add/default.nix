{ buildFractalideComponent, filterContracts }:

buildFractalideComponent rec {
    name = (baseNameOf ./.);
    src = ./.;
    contracts = filterContracts ["number" "number2"];
    depsSha256 = "0y9hpvx8dqbrypvdral9wrc4q84mvr0nc6w87ykzch3xnwxwbkkl";
}
