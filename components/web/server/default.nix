{ component, contracts, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ path domain_port url ];
  buildInputs = with pkgs; [ openssl ];
  depsSha256 = "01260pbn4dciqgsb1xyfk5jd3wsi8cdvfs107kh2d9wy5imac9an";
}
