{ subnet, contracts, components }:

subnet {
  src = ./.;
  subnet = with contracts; with components; ''
  a => input clone1(${ip_clone})
  b => input clone2(${ip_clone})
  clone1() clone[2] -> input not1(${maths_boolean_not}) output -> a and2(${maths_boolean_and})
  clone2() clone[1] -> input not2(${maths_boolean_not}) output -> b and1(${maths_boolean_and})
  clone1() clone[1] -> a and1() output -> a or(${maths_boolean_or})
  clone2() clone[2] -> b and2() output -> b or() output => output
  '';
}
