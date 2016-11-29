{ subnet, contracts, components }:

subnet {
  src = ./.;
  subnet = with contracts; with components; ''
  a => a nand(${maths_boolean_nand}) output -> input not(${maths_boolean_not}) output => output
  b => b nand()
  '';
}
