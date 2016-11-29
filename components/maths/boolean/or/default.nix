{ subnet, contracts, components }:

subnet {
  src = ./.;
  flowscript = with contracts; with components; ''
  a => input not2(${maths_boolean_not}) output -> b and(${maths_boolean_and})
  b => input not1(${maths_boolean_not}) output -> a and() output -> input not3(${maths_boolean_not}) output => output
  '';
}
