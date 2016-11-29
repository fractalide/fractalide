{ subnet, contracts, components }:

subnet {
  src = ./.;
  flowscript = with contracts; with components; ''
  input => input clone(${ip_clone})
  clone() clone[1] -> a nand(${maths_boolean_nand}) output => output
  clone() clone[2] -> b nand()
  '';
}
